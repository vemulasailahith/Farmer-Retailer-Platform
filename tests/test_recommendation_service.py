import os
import sys
import unittest
from unittest.mock import MagicMock

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.recommendation_service import FarmToMarketRecommendationService


class TestFarmToMarketRecommendationService(unittest.TestCase):

    def setUp(self):
        # 1. Instantiate mock services
        self.mock_supply_service = MagicMock()
        self.mock_price_service = MagicMock()
        self.mock_freshness_service = MagicMock()
        self.mock_routing_service = MagicMock()
        self.mock_transport_service = MagicMock()
        self.mock_spoilage_service = MagicMock()
        self.mock_demand_service = MagicMock()
        self.mock_decision_service = MagicMock()

        # 2. Configure default mock returns
        self.mock_supply_service.predict_supply.return_value = {
            "crop": "rice",
            "state_name": "Andhra Pradesh",
            "dist_name": "Guntur",
            "area_ha": 5.0,
            "predicted_yield_kg_per_ha": 753.91,
            "expected_supply_kg": 3769.56,
            "expected_supply_tonnes": 3.77,
        }

        self.mock_freshness_service.predict.return_value = {
            "predicted_class": "fresh",
            "fresh_probability": 0.92,
            "rotten_probability": 0.08,
            "confidence": 0.92,
        }

        def fake_routing(farmer_latitude, farmer_longitude, market_latitude, market_longitude):
            if market_latitude == 16.3000:
                return {"distance_km": 50.0, "travel_time_hours": 1.5}
            return {"distance_km": 120.0, "travel_time_hours": 3.0}

        self.mock_routing_service.get_route.side_effect = fake_routing

        def fake_transport(distance_km, cost_per_km=30.0, supply_kg=None):
            total_cost = round(distance_km * cost_per_km, 2)
            return {
                "distance_km": distance_km,
                "cost_per_km": cost_per_km,
                "total_transport_cost": total_cost,
                "supply_kg": supply_kg,
                "transport_cost_per_kg": round(total_cost / supply_kg, 2) if supply_kg else None,
            }

        self.mock_transport_service.calculate_cost.side_effect = fake_transport

        def fake_spoilage(data):
            risk = 0.08 if data["travel_time_hours"] < 2.0 else 0.15
            pct = risk * 100.0
            spoiled = data["supply_kg"] * risk
            return {
                "spoilage_risk": risk,
                "spoilage_percentage": pct,
                "risk_level": "low",
                "estimated_spoiled_kg": round(spoiled, 2),
                "estimated_saleable_kg": round(data["supply_kg"] - spoiled, 2),
            }

        self.mock_spoilage_service.calculate_risk.side_effect = fake_spoilage

        def fake_price(data):
            market = data.get("Market", "")
            if "Market A" in market:
                quintal_price = 3500.0
                kg_price = 35.0
            else:
                quintal_price = 4200.0
                kg_price = 42.0
            return {
                "commodity": data.get("Commodity", "rice"),
                "market": market,
                "prediction_date": str(data.get("Date", "2024-01-01")),
                "current_modal_price": quintal_price - 300.0,
                "predicted_future_modal_price": quintal_price,
                "price_unit_model": "INR/quintal",
                "predicted_price_per_kg": kg_price,
                "price_unit": "INR/kg",
            }

        self.mock_price_service.predict.side_effect = fake_price

        def fake_demand(data):
            demand_kg = data["demand_kg"]
            cap = data["buyer_capacity_kg"]
            supply = data["current_supply_kg"]
            avail = max(0.0, cap - supply)
            return {
                "commodity": data["commodity"],
                "market": data["market"],
                "buyer_name": data["buyer_name"],
                "demand_kg": demand_kg,
                "buyer_capacity_kg": cap,
                "current_supply_kg": supply,
                "available_capacity_kg": round(avail, 2),
                "demand_coverage": round(supply / demand_kg, 4),
                "demand_status": "moderate_demand",
                "capacity_status": "capacity_available" if avail > 0 else "capacity_full",
            }

        self.mock_demand_service.analyze_demand.side_effect = fake_demand

        self.mock_decision_service.compare_markets.return_value = {
            "supply_kg": 3769.56,
            "market_options": [
                {
                    "market": "Market A",
                    "buyer_name": "Buyer A",
                    "predicted_price_per_kg": 35.0,
                    "transport_cost": 1500.0,
                    "spoilage_percentage": 8.0,
                    "spoilage_quantity_kg": 301.56,
                    "saleable_quantity_kg": 3468.0,
                    "demand_kg": 5000.0,
                    "available_capacity_kg": 2230.44,
                    "sellable_quantity_kg": 2230.44,
                    "gross_revenue": 78065.40,
                    "net_expected_revenue": 76565.40,
                    "feasibility": "feasible",
                },
                {
                    "market": "Market B",
                    "buyer_name": "Buyer B",
                    "predicted_price_per_kg": 42.0,
                    "transport_cost": 3600.0,
                    "spoilage_percentage": 15.0,
                    "spoilage_quantity_kg": 565.43,
                    "saleable_quantity_kg": 3204.13,
                    "demand_kg": 4000.0,
                    "available_capacity_kg": 1230.44,
                    "sellable_quantity_kg": 1230.44,
                    "gross_revenue": 51678.48,
                    "net_expected_revenue": 48078.48,
                    "feasibility": "feasible",
                },
            ],
            "recommended_market": {
                "market": "Market A",
                "buyer_name": "Buyer A",
                "reason": "Highest feasible net expected revenue",
            },
        }

        # 3. Create orchestrator instance with injected mocks
        self.orchestrator = FarmToMarketRecommendationService(
            supply_service=self.mock_supply_service,
            price_service=self.mock_price_service,
            freshness_service=self.mock_freshness_service,
            routing_service=self.mock_routing_service,
            transport_service=self.mock_transport_service,
            spoilage_service=self.mock_spoilage_service,
            demand_service=self.mock_demand_service,
            decision_service=self.mock_decision_service,
        )

        # 4. Standard valid input data
        self.valid_input = {
            "price_unit": "INR/kg",
            "supply": {
                "state_name": "Andhra Pradesh",
                "dist_name": "Guntur",
                "crop": "rice",
                "area_ha": 5.0,
                "year": 2024,
                "n_req_kg_per_ha": 100.0,
                "p_req_kg_per_ha": 40.0,
                "k_req_kg_per_ha": 40.0,
                "temperature_c": 28.0,
                "humidity_percent": 75.0,
                "ph": 6.5,
                "rainfall_mm": 120.0,
                "wind_speed_m_s": 2.5,
                "solar_radiation_mj_m2_day": 18.0,
            },
            "freshness": {
                "image_path": "test_images/sample_produce.jpg",
            },
            "spoilage": {
                "shelf_life_hours": 72.0,
            },
            "farmer_location": {
                "latitude": 16.3067,
                "longitude": 80.4365,
            },
            "markets": [
                {
                    "market": "Market A",
                    "buyer_name": "Buyer A",
                    "latitude": 16.3000,
                    "longitude": 80.4500,
                    "price": {
                        "State": "Andhra Pradesh",
                        "District": "Guntur",
                        "Market": "Market A",
                        "Commodity": "rice",
                        "Variety": "Common",
                        "Grade": "FAQ",
                        "Commodity_Code": 1,
                        "Date": "2024-01-01",
                        "Min_Price": 3000.0,
                        "Max_Price": 3600.0,
                        "Modal_Price": 3200.0,
                        "Previous_Price": 3100.0,
                        "Rolling_Mean_3": 3150.0,
                        "Rolling_Mean_7": 3100.0,
                    },
                    "demand": {
                        "demand_kg": 5000.0,
                        "buyer_capacity_kg": 6000.0,
                    },
                    "transport": {
                        "cost_per_km": 30.0,
                    },
                },
                {
                    "market": "Market B",
                    "buyer_name": "Buyer B",
                    "latitude": 16.5000,
                    "longitude": 80.6000,
                    "price": {
                        "State": "Andhra Pradesh",
                        "District": "Krishna",
                        "Market": "Market B",
                        "Commodity": "rice",
                        "Variety": "Common",
                        "Grade": "FAQ",
                        "Commodity_Code": 1,
                        "Date": "2024-01-01",
                        "Min_Price": 3500.0,
                        "Max_Price": 4500.0,
                        "Modal_Price": 3800.0,
                        "Previous_Price": 3700.0,
                        "Rolling_Mean_3": 3750.0,
                        "Rolling_Mean_7": 3700.0,
                    },
                    "demand": {
                        "demand_kg": 4000.0,
                        "buyer_capacity_kg": 5000.0,
                    },
                    "transport": {
                        "cost_per_km": 30.0,
                    },
                },
            ],
        }


    def test_1_successful_end_to_end_orchestration_two_markets(self):
        """Test 1: Full end-to-end orchestration successfully evaluates 2 candidate markets."""
        result = self.orchestrator.recommend(self.valid_input)

        self.assertIsInstance(result, dict)
        self.assertIn("supply", result)
        self.assertIn("freshness", result)
        self.assertIn("markets", result)
        self.assertIn("recommendation", result)
        self.assertEqual(len(result["markets"]), 2)
        self.assertEqual(result["price_unit"], "INR/kg")
        market_a_price = result["markets"][0]["price"]
        self.assertEqual(market_a_price["price_unit_model"], "INR/quintal")
        self.assertEqual(market_a_price["predicted_future_modal_price"], 3500.0)
        self.assertEqual(market_a_price["predicted_price_per_kg"], 35.0)
        self.assertEqual(market_a_price["price_unit"], "INR/kg")


    def test_2_verify_supply_prediction_service_called(self):
        """Test 2: Verify SupplyPredictionService is called with correct arguments."""
        self.orchestrator.recommend(self.valid_input)
        self.mock_supply_service.predict_supply.assert_called_once()
        call_kwargs = self.mock_supply_service.predict_supply.call_args[1]
        self.assertEqual(call_kwargs["crop"], "rice")
        self.assertEqual(call_kwargs["area_ha"], 5.0)

    def test_3_verify_price_prediction_service_called(self):
        """Test 3: Verify PricePredictionService is called for each candidate market."""
        self.orchestrator.recommend(self.valid_input)
        self.assertEqual(self.mock_price_service.predict.call_count, 2)

    def test_4_verify_freshness_detection_service_called(self):
        """Test 4: Verify FreshnessDetectionService is called with the produce image path."""
        self.orchestrator.recommend(self.valid_input)
        self.mock_freshness_service.predict.assert_called_once_with("test_images/sample_produce.jpg")

    def test_5_verify_routing_service_called_for_each_market(self):
        """Test 5: Verify MarketRoutingService is called for each market with coordinates."""
        self.orchestrator.recommend(self.valid_input)
        self.assertEqual(self.mock_routing_service.get_route.call_count, 2)
        # Check first call coordinates
        first_call = self.mock_routing_service.get_route.call_args_list[0][1]
        self.assertEqual(first_call["farmer_latitude"], 16.3067)
        self.assertEqual(first_call["market_latitude"], 16.3000)

    def test_6_verify_transport_service_receives_routing_distance(self):
        """Test 6: Verify TransportationCostService receives the road distance from routing."""
        self.orchestrator.recommend(self.valid_input)
        self.assertEqual(self.mock_transport_service.calculate_cost.call_count, 2)
        calls = self.mock_transport_service.calculate_cost.call_args_list
        # Market A: distance 50.0 km
        self.assertEqual(calls[0][1]["distance_km"], 50.0)
        # Market B: distance 120.0 km
        self.assertEqual(calls[1][1]["distance_km"], 120.0)

    def test_7_verify_spoilage_service_receives_routing_travel_time(self):
        """Test 7: Verify SpoilageRiskService receives travel time from routing and fresh probability."""
        self.orchestrator.recommend(self.valid_input)
        self.assertEqual(self.mock_spoilage_service.calculate_risk.call_count, 2)
        calls = self.mock_spoilage_service.calculate_risk.call_args_list
        # Market A: 1.5 hours travel time
        self.assertEqual(calls[0][0][0]["travel_time_hours"], 1.5)
        self.assertEqual(calls[0][0][0]["fresh_probability"], 0.92)
        # Market B: 3.0 hours travel time
        self.assertEqual(calls[1][0][0]["travel_time_hours"], 3.0)

    def test_8_verify_demand_service_called_for_each_market(self):
        """Test 8: Verify DemandAnalysisService is called for each market with buyer demand/capacity."""
        self.orchestrator.recommend(self.valid_input)
        self.assertEqual(self.mock_demand_service.analyze_demand.call_count, 2)
        calls = self.mock_demand_service.analyze_demand.call_args_list
        self.assertEqual(calls[0][0][0]["buyer_name"], "Buyer A")
        self.assertEqual(calls[1][0][0]["buyer_name"], "Buyer B")

    def test_9_verify_decision_service_receives_assembled_market_data(self):
        """Test 9: Verify MarketDecisionService receives correctly assembled comparison items."""
        self.orchestrator.recommend(self.valid_input)
        self.mock_decision_service.compare_markets.assert_called_once()
        called_markets = self.mock_decision_service.compare_markets.call_args[1]["markets"]
        called_supply = self.mock_decision_service.compare_markets.call_args[1]["supply_kg"]

        self.assertEqual(called_supply, 3769.56)
        self.assertEqual(len(called_markets), 2)
        m1 = called_markets[0]
        self.assertIn("market", m1)
        self.assertIn("buyer_name", m1)
        self.assertIn("predicted_price_per_kg", m1)
        self.assertEqual(m1["predicted_price_per_kg"], 35.0)
        self.assertNotEqual(m1["predicted_price_per_kg"], 3500.0)
        self.assertIn("transport_cost", m1)
        self.assertIn("spoilage_percentage", m1)
        self.assertIn("demand_kg", m1)
        self.assertIn("available_capacity_kg", m1)

    def test_10_verify_final_recommendation_preserved(self):
        """Test 10: Verify the final recommendation returned by Module 7 is preserved in output."""
        result = self.orchestrator.recommend(self.valid_input)
        self.assertIsNotNone(result["recommendation"])
        self.assertEqual(result["recommendation"]["market"], "Market A")
        self.assertEqual(result["recommendation"]["buyer_name"], "Buyer A")

    def test_11_missing_required_input_raises_exception(self):
        """Test 11: Missing required input sections raise clear ValueError."""
        # Non-dict input
        with self.assertRaises(TypeError):
            self.orchestrator.recommend(["not", "a", "dict"])

        # Missing 'supply'
        bad_input = dict(self.valid_input)
        del bad_input["supply"]
        with self.assertRaises(ValueError):
            self.orchestrator.recommend(bad_input)

        # Missing 'markets'
        bad_input = dict(self.valid_input)
        del bad_input["markets"]
        with self.assertRaises(ValueError):
            self.orchestrator.recommend(bad_input)

        # Empty 'markets'
        bad_input = dict(self.valid_input)
        bad_input["markets"] = []
        with self.assertRaises(ValueError):
            self.orchestrator.recommend(bad_input)

    def test_12_missing_or_invalid_price_unit_raises_exception(self):
        """Test 12: Missing price unit or non-per-kg price unit raises ValueError."""
        # Missing price_unit
        bad_input = dict(self.valid_input)
        del bad_input["price_unit"]
        with self.assertRaises(ValueError) as cm:
            self.orchestrator.recommend(bad_input)
        self.assertIn("price_unit", str(cm.exception).lower())

        # Unsupported price unit (e.g. quintal)
        bad_input = dict(self.valid_input)
        bad_input["price_unit"] = "INR/quintal"
        with self.assertRaises(ValueError) as cm:
            self.orchestrator.recommend(bad_input)
        self.assertIn("per-kilogram", str(cm.exception))

    def test_13_invalid_market_gps_data_propagates_routing_error(self):
        """Test 13: Invalid market GPS coordinates trigger a routing failure."""
        self.mock_routing_service.get_route.side_effect = ValueError("Invalid latitude: out of bounds")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Routing failed for market 'Market A'", str(cm.exception))

    def test_14_routing_failure_identifies_market(self):
        """Test 14: Routing failure explicitly identifies the failing market name in the exception."""
        self.mock_routing_service.get_route.side_effect = RuntimeError("OSRM connection timeout")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Routing failed for market 'Market A'", str(cm.exception))

    def test_15_existing_service_errors_not_swallowed(self):
        """Test 15: Failures in each underlying service raise clear identifying RuntimeError."""
        # 1. Supply prediction failure
        self.mock_supply_service.predict_supply.side_effect = RuntimeError("Model corrupted")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Supply prediction failed", str(cm.exception))
        self.mock_supply_service.predict_supply.side_effect = None

        # 2. Freshness detection failure
        self.mock_freshness_service.predict.side_effect = RuntimeError("Image decoding error")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Freshness detection failed", str(cm.exception))
        self.mock_freshness_service.predict.side_effect = None

        # 3. Transport calculation failure
        self.mock_transport_service.calculate_cost.side_effect = RuntimeError("Math error")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Transport calculation failed for market 'Market A'", str(cm.exception))
        self.mock_transport_service.calculate_cost.side_effect = None

        # 4. Spoilage risk calculation failure
        self.mock_spoilage_service.calculate_risk.side_effect = RuntimeError("Negative shelf life")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Spoilage calculation failed for market 'Market A'", str(cm.exception))
        self.mock_spoilage_service.calculate_risk.side_effect = None

        # 5. Price prediction failure
        self.mock_price_service.predict.side_effect = RuntimeError("Missing categorical encoder")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Price prediction failed for market 'Market A'", str(cm.exception))
        self.mock_price_service.predict.side_effect = None

        # 6. Demand analysis failure
        self.mock_demand_service.analyze_demand.side_effect = RuntimeError("Division by zero")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Demand analysis failed for market 'Market A'", str(cm.exception))
        self.mock_demand_service.analyze_demand.side_effect = None

        # 7. Market decision failure
        self.mock_decision_service.compare_markets.side_effect = RuntimeError("Comparison failed")
        with self.assertRaises(RuntimeError) as cm:
            self.orchestrator.recommend(self.valid_input)
        self.assertIn("Market decision failed", str(cm.exception))


if __name__ == "__main__":
    unittest.main()
