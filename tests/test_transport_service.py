import unittest
import os
import sys

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.transport_service import TransportationCostService

class TestTransportationCostService(unittest.TestCase):

    def setUp(self):
        self.service = TransportationCostService()

    def test_1_basic_transport_cost(self):
        """Test basic transport cost calculation (120 km, 30/km -> 3600 total)."""
        result = self.service.calculate_cost(distance_km=120, cost_per_km=30)
        
        self.assertEqual(result["distance_km"], 120.0)
        self.assertEqual(result["cost_per_km"], 30.0)
        self.assertEqual(result["total_transport_cost"], 3600.0)
        self.assertIsNone(result["supply_kg"])
        self.assertIsNone(result["transport_cost_per_kg"])

    def test_2_transport_cost_per_kg(self):
        """Test per-kg transport cost calculation (120 km, 30/km, 3769.56 kg -> ~0.96/kg)."""
        result = self.service.calculate_cost(
            distance_km=120,
            cost_per_km=30,
            supply_kg=3769.56
        )

        self.assertEqual(result["total_transport_cost"], 3600.0)
        self.assertEqual(result["supply_kg"], 3769.56)
        self.assertIsNotNone(result["transport_cost_per_kg"])
        self.assertAlmostEqual(result["transport_cost_per_kg"], 0.96, places=2)

    def test_3_calculation_without_supply(self):
        """Test that supply_kg=None results in transport_cost_per_kg=None."""
        result = self.service.calculate_cost(distance_km=50, cost_per_km=25)
        
        self.assertEqual(result["total_transport_cost"], 1250.0)
        self.assertIsNone(result["supply_kg"])
        self.assertIsNone(result["transport_cost_per_kg"])

    def test_4_zero_distance(self):
        """Test zero distance produces zero total cost."""
        result = self.service.calculate_cost(distance_km=0, cost_per_km=30, supply_kg=1000)
        
        self.assertEqual(result["total_transport_cost"], 0.0)
        self.assertEqual(result["transport_cost_per_kg"], 0.0)

    def test_5_invalid_negative_distance(self):
        """Test negative distance raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.calculate_cost(distance_km=-10, cost_per_km=30)

    def test_6_invalid_negative_cost_per_km(self):
        """Test negative cost per km raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.calculate_cost(distance_km=100, cost_per_km=-5)

    def test_7_invalid_zero_or_negative_supply(self):
        """Test zero or negative supply_kg raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.calculate_cost(distance_km=100, cost_per_km=30, supply_kg=0)
            
        with self.assertRaises(ValueError):
            self.service.calculate_cost(distance_km=100, cost_per_km=30, supply_kg=-500)

if __name__ == "__main__":
    unittest.main()
