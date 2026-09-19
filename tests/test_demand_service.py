import unittest
import os
import sys

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.demand_service import DemandAnalysisService

class TestDemandAnalysisService(unittest.TestCase):

    def setUp(self):
        self.service = DemandAnalysisService()
        self.valid_input = {
            "commodity": "Onion",
            "market": "Ammapet",
            "buyer_name": "Buyer A",
            "demand_kg": 5000.0,
            "buyer_capacity_kg": 6000.0,
            "current_supply_kg": 3000.0
        }

    def test_1_normal_valid_input(self):
        """Test normal valid input returns dictionary containing all expected fields."""
        result = self.service.analyze_demand(self.valid_input)
        
        self.assertIsInstance(result, dict)
        self.assertEqual(result["commodity"], "Onion")
        self.assertEqual(result["market"], "Ammapet")
        self.assertEqual(result["buyer_name"], "Buyer A")
        self.assertEqual(result["demand_kg"], 5000.0)
        self.assertEqual(result["buyer_capacity_kg"], 6000.0)
        self.assertEqual(result["current_supply_kg"], 3000.0)
        self.assertIn("available_capacity_kg", result)
        self.assertIn("demand_coverage", result)
        self.assertIn("demand_status", result)
        self.assertIn("capacity_status", result)

    def test_2_available_capacity_calculation(self):
        """Test available capacity: 6000 - 3000 = 3000 kg."""
        result = self.service.analyze_demand(self.valid_input)
        self.assertEqual(result["available_capacity_kg"], 3000.0)

    def test_3_capacity_cannot_become_negative(self):
        """Test capacity = 2000, supply = 3000 results in available capacity = 0."""
        data = self.valid_input.copy()
        data["buyer_capacity_kg"] = 2000.0
        data["current_supply_kg"] = 3000.0
        
        result = self.service.analyze_demand(data)
        self.assertEqual(result["available_capacity_kg"], 0.0)

    def test_4_demand_coverage(self):
        """Test demand coverage: 3000 / 5000 = 0.60."""
        result = self.service.analyze_demand(self.valid_input)
        self.assertEqual(result["demand_coverage"], 0.60)

    def test_5_low_demand_classification(self):
        """Test coverage < 0.50 returns 'low_demand'."""
        data = self.valid_input.copy()
        data["current_supply_kg"] = 2000.0
        data["demand_kg"] = 5000.0  # 2000 / 5000 = 0.40
        
        result = self.service.analyze_demand(data)
        self.assertEqual(result["demand_status"], "low_demand")

    def test_6_moderate_demand_classification(self):
        """Test 0.50 <= coverage < 0.80 returns 'moderate_demand'."""
        data = self.valid_input.copy()
        data["current_supply_kg"] = 3500.0
        data["demand_kg"] = 5000.0  # 3500 / 5000 = 0.70
        
        result = self.service.analyze_demand(data)
        self.assertEqual(result["demand_status"], "moderate_demand")

    def test_7_high_demand_classification(self):
        """Test 0.80 <= coverage <= 1.00 returns 'high_demand'."""
        data = self.valid_input.copy()
        data["current_supply_kg"] = 4500.0
        data["demand_kg"] = 5000.0  # 4500 / 5000 = 0.90
        
        result = self.service.analyze_demand(data)
        self.assertEqual(result["demand_status"], "high_demand")

    def test_8_oversupplied_classification(self):
        """Test coverage > 1.00 returns 'oversupplied'."""
        data = self.valid_input.copy()
        data["current_supply_kg"] = 6000.0
        data["demand_kg"] = 5000.0  # 6000 / 5000 = 1.20
        
        result = self.service.analyze_demand(data)
        self.assertEqual(result["demand_status"], "oversupplied")

    def test_9_capacity_available(self):
        """Test available capacity > 0 returns 'capacity_available'."""
        result = self.service.analyze_demand(self.valid_input)
        self.assertEqual(result["capacity_status"], "capacity_available")

    def test_10_capacity_full(self):
        """Test available capacity == 0 returns 'capacity_full'."""
        data = self.valid_input.copy()
        data["buyer_capacity_kg"] = 3000.0
        data["current_supply_kg"] = 3000.0
        
        result = self.service.analyze_demand(data)
        self.assertEqual(result["capacity_status"], "capacity_full")

    def test_11_zero_demand_rejected(self):
        """Test demand_kg = 0 raises ValueError."""
        data = self.valid_input.copy()
        data["demand_kg"] = 0.0
        with self.assertRaises(ValueError):
            self.service.analyze_demand(data)

    def test_12_negative_values_rejected(self):
        """Test negative values for demand, capacity, current supply raise ValueError."""
        for field in ["demand_kg", "buyer_capacity_kg", "current_supply_kg"]:
            data = self.valid_input.copy()
            data[field] = -100.0
            with self.assertRaises(ValueError):
                self.service.analyze_demand(data)

    def test_13_invalid_string_values(self):
        """Test empty/whitespace values for commodity, market, buyer_name raise ValueError."""
        for field in ["commodity", "market", "buyer_name"]:
            data = self.valid_input.copy()
            data[field] = "   "
            with self.assertRaises(ValueError):
                self.service.analyze_demand(data)

    def test_14_invalid_numeric_types(self):
        """Test string/boolean types for numeric fields raise TypeError or ValueError."""
        for field in ["demand_kg", "buyer_capacity_kg", "current_supply_kg"]:
            data = self.valid_input.copy()
            data[field] = True  # boolean
            with self.assertRaises(TypeError):
                self.service.analyze_demand(data)

            data = self.valid_input.copy()
            data[field] = "INVALID_NUMERIC"
            with self.assertRaises(TypeError):
                self.service.analyze_demand(data)

    def test_15_result_consistency(self):
        """Verify output non-negativity and correct rounding."""
        result = self.service.analyze_demand(self.valid_input)
        self.assertGreaterEqual(result["available_capacity_kg"], 0.0)
        self.assertGreaterEqual(result["demand_coverage"], 0.0)
        self.assertEqual(result["demand_coverage"], round(3000.0 / 5000.0, 4))

if __name__ == "__main__":
    unittest.main()
