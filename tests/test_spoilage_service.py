import unittest
import os
import sys

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.spoilage_service import SpoilageRiskService

class TestSpoilageRiskService(unittest.TestCase):

    def setUp(self):
        self.service = SpoilageRiskService()
        self.valid_input = {
            "fresh_probability": 0.9231,
            "shelf_life_hours": 48.0,
            "travel_time_hours": 6.0,
            "temperature_c": 30.0,
            "humidity_percent": 75.0,
            "supply_kg": 3769.56
        }

    def test_1_normal_valid_input(self):
        """Test normal valid input produces structured result dictionary."""
        result = self.service.calculate_risk(self.valid_input)
        
        self.assertIn("spoilage_risk", result)
        self.assertIn("spoilage_percentage", result)
        self.assertIn("risk_level", result)
        self.assertIn("estimated_spoiled_kg", result)
        self.assertIn("estimated_saleable_kg", result)

    def test_2_freshness_risk_calculation(self):
        """Test fresh_probability = 1.0 yields freshness_risk = 0.0."""
        data = self.valid_input.copy()
        data["fresh_probability"] = 1.0
        data["travel_time_hours"] = 0.0
        data["temperature_c"] = 5.0
        data["humidity_percent"] = 40.0
        
        result = self.service.calculate_risk(data)
        self.assertLess(result["spoilage_risk"], 0.15)

    def test_3_zero_freshness_probability(self):
        """Test fresh_probability = 0.0 is handled correctly."""
        data = self.valid_input.copy()
        data["fresh_probability"] = 0.0
        
        result = self.service.calculate_risk(data)
        self.assertGreaterEqual(result["spoilage_risk"], 0.40)

    def test_4_shelf_life_must_be_greater_than_zero(self):
        """Test shelf_life_hours <= 0 raises ValueError."""
        data = self.valid_input.copy()
        data["shelf_life_hours"] = 0.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

        data["shelf_life_hours"] = -10.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

    def test_5_negative_travel_time_raises_value_error(self):
        """Test travel_time_hours < 0 raises ValueError."""
        data = self.valid_input.copy()
        data["travel_time_hours"] = -5.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

    def test_6_humidity_out_of_bounds_raises_value_error(self):
        """Test humidity < 0 or > 100 raises ValueError."""
        data = self.valid_input.copy()
        data["humidity_percent"] = -1.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

        data["humidity_percent"] = 105.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

    def test_7_zero_or_negative_supply_raises_value_error(self):
        """Test supply_kg <= 0 raises ValueError."""
        data = self.valid_input.copy()
        data["supply_kg"] = 0.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

        data["supply_kg"] = -100.0
        with self.assertRaises(ValueError):
            self.service.calculate_risk(data)

    def test_8_risk_level_is_valid_category(self):
        """Test risk_level is one of ['low', 'medium', 'high', 'very_high']."""
        result = self.service.calculate_risk(self.valid_input)
        valid_levels = ["low", "medium", "high", "very_high"]
        self.assertIn(result["risk_level"], valid_levels)

    def test_9_spoiled_plus_saleable_equals_total_supply(self):
        """Test estimated_spoiled_kg + estimated_saleable_kg == supply_kg."""
        result = self.service.calculate_risk(self.valid_input)
        total = result["estimated_spoiled_kg"] + result["estimated_saleable_kg"]
        self.assertAlmostEqual(total, self.valid_input["supply_kg"], places=2)

    def test_10_spoilage_risk_remains_between_0_and_1(self):
        """Test spoilage_risk is strictly between 0.0 and 1.0."""
        result = self.service.calculate_risk(self.valid_input)
        self.assertGreaterEqual(result["spoilage_risk"], 0.0)
        self.assertLessEqual(result["spoilage_risk"], 1.0)
        self.assertAlmostEqual(result["spoilage_percentage"], result["spoilage_risk"] * 100.0, places=2)

    def test_11_temperature_thresholds(self):
        """Test temperature heuristic thresholds mapping."""
        self.assertEqual(self.service._get_temperature_risk(5.0), 0.05)
        self.assertEqual(self.service._get_temperature_risk(15.0), 0.15)
        self.assertEqual(self.service._get_temperature_risk(25.0), 0.35)
        self.assertEqual(self.service._get_temperature_risk(32.0), 0.60)
        self.assertEqual(self.service._get_temperature_risk(40.0), 0.80)

    def test_12_humidity_thresholds(self):
        """Test humidity heuristic thresholds mapping."""
        self.assertEqual(self.service._get_humidity_risk(40.0), 0.10)
        self.assertEqual(self.service._get_humidity_risk(60.0), 0.20)
        self.assertEqual(self.service._get_humidity_risk(80.0), 0.40)
        self.assertEqual(self.service._get_humidity_risk(90.0), 0.60)

if __name__ == "__main__":
    unittest.main()
