import unittest
import os
import sys

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.decision_service import MarketDecisionService

class TestMarketDecisionService(unittest.TestCase):

    def setUp(self):
        self.service = MarketDecisionService()
        self.supply_kg = 3769.56
        self.sample_markets = [
            {
                "market": "Market A",
                "buyer_name": "Buyer A",
                "predicted_price_per_kg": 3244.13,
                "transport_cost": 3600.0,
                "spoilage_percentage": 17.826,
                "demand_kg": 3000.0,
                "available_capacity_kg": 3500.0
            },
            {
                "market": "Market B",
                "buyer_name": "Buyer B",
                "predicted_price_per_kg": 3100.0,
                "transport_cost": 1800.0,
                "spoilage_percentage": 10.0,
                "demand_kg": 4000.0,
                "available_capacity_kg": 4000.0
            }
        ]

    def test_1_normal_valid_market_comparison(self):
        """Test normal valid market comparison returns structured dictionary."""
        result = self.service.compare_markets(self.sample_markets, self.supply_kg)
        
        self.assertIsInstance(result, dict)
        self.assertIn("supply_kg", result)
        self.assertIn("market_options", result)
        self.assertIn("recommended_market", result)
        self.assertEqual(len(result["market_options"]), 2)

    def test_2_correct_spoiled_quantity(self):
        """Test spoiled quantity: Supply = 1000, Spoilage = 10% -> 100 kg spoiled."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 1000.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["spoilage_quantity_kg"], 100.0)

    def test_3_correct_saleable_quantity(self):
        """Test saleable quantity: Supply = 1000, Spoilage = 10% -> 900 kg saleable."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 1000.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["saleable_quantity_kg"], 900.0)

    def test_4_sellable_quantity_limited_by_demand(self):
        """Test sellable quantity limited by demand: saleable=900, demand=500, capacity=1000 -> sellable=500."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 500.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["sellable_quantity_kg"], 500.0)

    def test_5_sellable_quantity_limited_by_buyer_capacity(self):
        """Test sellable quantity limited by buyer capacity: saleable=900, demand=1000, capacity=400 -> sellable=400."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 1000.0,
            "available_capacity_kg": 400.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["sellable_quantity_kg"], 400.0)

    def test_6_sellable_quantity_limited_by_saleable_supply(self):
        """Test sellable quantity limited by saleable supply: saleable=300, demand=1000, capacity=1000 -> sellable=300."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 70.0,  # 1000 * 0.7 = 700 spoiled -> 300 saleable
            "demand_kg": 1000.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["sellable_quantity_kg"], 300.0)

    def test_7_correct_gross_revenue(self):
        """Test gross revenue: sellable=500, price=10 -> gross revenue=5000."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 500.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["gross_revenue"], 5000.0)

    def test_8_correct_net_expected_revenue_after_transport(self):
        """Test net expected revenue: gross=5000, transport=1000 -> net revenue=4000."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 1000.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 500.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["net_expected_revenue"], 4000.0)

    def test_9_correct_unsold_quantity(self):
        """Test unsold quantity: saleable=900, sellable=500 -> unsold=400 kg."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 500.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["unsold_quantity_kg"], 400.0)

    def test_10_correct_total_unavailable_quantity(self):
        """Test total unavailable quantity: supply=1000, sellable=500 -> total unavailable=500 kg."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 500.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["total_unavailable_quantity_kg"], 500.0)

    def test_11_correct_net_value_per_original_kg(self):
        """Test net value per original kg: net_revenue=4000, supply=1000 -> 4.0/kg."""
        markets = [{
            "market": "Test Market",
            "buyer_name": "Test Buyer",
            "predicted_price_per_kg": 10.0,
            "transport_cost": 1000.0,
            "spoilage_percentage": 10.0,
            "demand_kg": 500.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["net_value_per_original_kg"], 4.0)

    def test_12_feasible_market_classification(self):
        """Test price > 0, capacity > 0, sellable > 0 produces 'feasible'."""
        result = self.service.compare_markets(self.sample_markets, self.supply_kg)
        for option in result["market_options"]:
            self.assertEqual(option["feasibility"], "feasible")

    def test_13_not_feasible_when_capacity_zero(self):
        """Test market with zero capacity is classified as 'not_feasible'."""
        markets = [{
            "market": "Full Market",
            "buyer_name": "Buyer Full",
            "predicted_price_per_kg": 50.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 5.0,
            "demand_kg": 1000.0,
            "available_capacity_kg": 0.0  # Zero capacity
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["feasibility"], "not_feasible")

    def test_14_not_feasible_when_price_zero(self):
        """Test market with zero price is classified as 'not_feasible'."""
        markets = [{
            "market": "Zero Price Market",
            "buyer_name": "Buyer Zero",
            "predicted_price_per_kg": 0.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 5.0,
            "demand_kg": 1000.0,
            "available_capacity_kg": 1000.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        option = result["market_options"][0]
        self.assertEqual(option["feasibility"], "not_feasible")

    def test_15_recommendation_selects_highest_feasible_net_revenue(self):
        """Test recommendation selects feasible market with highest net expected revenue."""
        result = self.service.compare_markets(self.sample_markets, self.supply_kg)
        rec = result["recommended_market"]
        self.assertIsNotNone(rec)
        self.assertEqual(rec["market"], "Market B")  # Market B has higher net revenue due to lower transport & spoilage

    def test_16_non_feasible_market_not_recommended_despite_higher_price(self):
        """Test non-feasible market with raw price = 5000 but 0 capacity is NOT recommended over feasible market with price 3100."""
        markets = [
            {
                "market": "High Price Non-Feasible Market",
                "buyer_name": "Buyer High",
                "predicted_price_per_kg": 5000.0,
                "transport_cost": 100.0,
                "spoilage_percentage": 5.0,
                "demand_kg": 1000.0,
                "available_capacity_kg": 0.0  # Not feasible!
            },
            {
                "market": "Feasible Market B",
                "buyer_name": "Buyer B",
                "predicted_price_per_kg": 3100.0,
                "transport_cost": 1800.0,
                "spoilage_percentage": 10.0,
                "demand_kg": 4000.0,
                "available_capacity_kg": 4000.0  # Feasible
            }
        ]
        result = self.service.compare_markets(markets, self.supply_kg)
        rec = result["recommended_market"]
        self.assertIsNotNone(rec)
        self.assertEqual(rec["market"], "Feasible Market B")

    def test_17_no_feasible_markets_returns_none(self):
        """Test all non-feasible markets returns recommended_market = None."""
        markets = [{
            "market": "Zero Capacity Market",
            "buyer_name": "Buyer Zero",
            "predicted_price_per_kg": 500.0,
            "transport_cost": 100.0,
            "spoilage_percentage": 5.0,
            "demand_kg": 1000.0,
            "available_capacity_kg": 0.0
        }]
        result = self.service.compare_markets(markets, 1000.0)
        self.assertIsNone(result["recommended_market"])

    def test_18_invalid_inputs_raise_errors(self):
        """Test invalid supply, empty markets, missing fields, negative domain values, booleans, and NaNs raise errors."""
        # 1. Supply <= 0 or invalid type
        with self.assertRaises(ValueError):
            self.service.compare_markets(self.sample_markets, 0.0)
        with self.assertRaises(ValueError):
            self.service.compare_markets(self.sample_markets, -500.0)
        with self.assertRaises(TypeError):
            self.service.compare_markets(self.sample_markets, True)

        # 2. Empty or non-list markets
        with self.assertRaises(ValueError):
            self.service.compare_markets([], 1000.0)
        with self.assertRaises(TypeError):
            self.service.compare_markets("INVALID_LIST", 1000.0)

        # 3. Negative transport cost or spoilage > 100
        invalid_market = self.sample_markets[0].copy()
        invalid_market["transport_cost"] = -100.0
        with self.assertRaises(ValueError):
            self.service.compare_markets([invalid_market], 1000.0)

        invalid_market = self.sample_markets[0].copy()
        invalid_market["spoilage_percentage"] = 150.0
        with self.assertRaises(ValueError):
            self.service.compare_markets([invalid_market], 1000.0)

        # 4. Empty string market name
        invalid_market = self.sample_markets[0].copy()
        invalid_market["market"] = "   "
        with self.assertRaises(ValueError):
            self.service.compare_markets([invalid_market], 1000.0)

if __name__ == "__main__":
    unittest.main()
