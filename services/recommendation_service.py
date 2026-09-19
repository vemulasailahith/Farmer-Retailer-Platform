import os
from typing import Any, Dict, List, Optional

from services.decision_service import MarketDecisionService
from services.demand_service import DemandAnalysisService
from services.freshness_service import FreshnessDetectionService
from services.price_service import PricePredictionService
from services.routing_service import MarketRoutingService
from services.spoilage_service import SpoilageRiskService
from services.supply_service import SupplyPredictionService
from services.transport_service import TransportationCostService


class FarmToMarketRecommendationService:
    """
    Module 9: End-to-End Recommendation Orchestrator
    Coordinates Modules 1–8 into a unified pipeline to recommend the optimal
    market for a farmer based on yield supply, market routing, transport cost,
    produce freshness, spoilage risk, buyer demand, and predicted prices.
    """

    VALID_PER_KG_UNITS = {
        "inr/kg",
        "₹/kg",
        "rs/kg",
        "per_kg",
        "rs./kg",
        "inr / kg",
        "₹ / kg",
        "rs / kg",
    }

    def __init__(
        self,
        supply_service: Optional[SupplyPredictionService] = None,
        price_service: Optional[PricePredictionService] = None,
        freshness_service: Optional[FreshnessDetectionService] = None,
        routing_service: Optional[MarketRoutingService] = None,
        transport_service: Optional[TransportationCostService] = None,
        spoilage_service: Optional[SpoilageRiskService] = None,
        demand_service: Optional[DemandAnalysisService] = None,
        decision_service: Optional[MarketDecisionService] = None,
    ):
        """
        Initializes the orchestrator with dependency injection.
        If any service is None, instantiates the default production service.
        """
        self.supply_service = supply_service or SupplyPredictionService()
        self.price_service = price_service or PricePredictionService()
        self.freshness_service = freshness_service or FreshnessDetectionService()
        self.routing_service = routing_service or MarketRoutingService()
        self.transport_service = transport_service or TransportationCostService()
        self.spoilage_service = spoilage_service or SpoilageRiskService()
        self.demand_service = demand_service or DemandAnalysisService()
        self.decision_service = decision_service or MarketDecisionService()

    def _validate_input_structure(self, data: Dict[str, Any]) -> None:
        """Validates presence and basic structure of required input sections."""
        if not isinstance(data, dict):
            raise TypeError("Input data must be a dictionary.")

        required_sections = ["supply", "freshness", "farmer_location", "markets"]
        for section in required_sections:
            if section not in data or data[section] is None:
                raise ValueError(f"Missing required input section: '{section}'.")

        # Validate farmer location
        farmer_loc = data["farmer_location"]
        if not isinstance(farmer_loc, dict):
            raise TypeError("'farmer_location' must be a dictionary.")
        if "latitude" not in farmer_loc or "longitude" not in farmer_loc:
            raise ValueError("Section 'farmer_location' must contain 'latitude' and 'longitude'.")

        # Validate freshness section
        freshness_info = data["freshness"]
        if not isinstance(freshness_info, dict):
            raise TypeError("'freshness' section must be a dictionary.")
        if "image_path" not in freshness_info or not str(freshness_info["image_path"]).strip():
            raise ValueError("Section 'freshness' must contain a non-empty 'image_path'.")

        # Validate markets list
        markets = data["markets"]
        if not isinstance(markets, list):
            raise TypeError("Section 'markets' must be a list.")
        if len(markets) == 0:
            raise ValueError("Section 'markets' must be a non-empty list.")

        for idx, m in enumerate(markets):
            if not isinstance(m, dict):
                raise TypeError(f"Market item at index {idx} must be a dictionary.")
            for req_field in ["market", "buyer_name", "latitude", "longitude"]:
                if req_field not in m or m[req_field] is None:
                    raise ValueError(f"Market item at index {idx} missing required field: '{req_field}'.")

    def _validate_price_unit(self, price_unit: Optional[str], market_name: str) -> str:
        """
        Validates that an explicit per-kilogram price unit is provided.
        Rejects missing units or non-per-kg units without guessing or converting.
        """
        if not price_unit or not isinstance(price_unit, str) or not price_unit.strip():
            raise ValueError(
                f"Missing required 'price_unit' for market '{market_name}'. "
                "An explicit per-kilogram price unit (e.g. 'INR/kg' or '₹/kg') must be provided."
            )

        clean_unit = price_unit.strip()
        if clean_unit.lower() not in self.VALID_PER_KG_UNITS:
            raise ValueError(
                f"Invalid price unit '{clean_unit}' for market '{market_name}'. "
                "The market decision engine requires an explicit per-kilogram price unit (e.g. 'INR/kg'). "
                "Non-kg units (e.g. quintal) cannot be silently assumed or converted."
            )

        return clean_unit

    def recommend(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Executes end-to-end recommendation workflow across Modules 1–8.
        """
        self._validate_input_structure(data)

        # -------------------------------------------------------------
        # 1. Supply Prediction (Module 1)
        # -------------------------------------------------------------
        supply_input = data["supply"]
        try:
            supply_result = self.supply_service.predict_supply(
                state_name=supply_input["state_name"],
                dist_name=supply_input["dist_name"],
                crop=supply_input["crop"],
                area_ha=supply_input["area_ha"],
                year=supply_input["year"],
                n_req_kg_per_ha=supply_input["n_req_kg_per_ha"],
                p_req_kg_per_ha=supply_input["p_req_kg_per_ha"],
                k_req_kg_per_ha=supply_input["k_req_kg_per_ha"],
                temperature_c=supply_input["temperature_c"],
                humidity_percent=supply_input["humidity_percent"],
                ph=supply_input["ph"],
                rainfall_mm=supply_input["rainfall_mm"],
                wind_speed_m_s=supply_input["wind_speed_m_s"],
                solar_radiation_mj_m2_day=supply_input["solar_radiation_mj_m2_day"],
            )
        except Exception as e:
            raise RuntimeError(f"Supply prediction failed: {str(e)}") from e

        supply_kg = float(supply_result["expected_supply_kg"])

        # -------------------------------------------------------------
        # 2. Freshness Detection (Module 4)
        # -------------------------------------------------------------
        image_path = data["freshness"]["image_path"]
        try:
            freshness_result = self.freshness_service.predict(image_path)
        except Exception as e:
            raise RuntimeError(f"Freshness detection failed: {str(e)}") from e

        fresh_probability = float(freshness_result["fresh_probability"])

        # Default or global spoilage conditions
        # Default or global spoilage conditions
        global_spoilage = data.get("spoilage") or {}
        freshness_config = data.get("freshness") or {}
        global_shelf_life = (
            global_spoilage.get("shelf_life_hours")
            or data.get("shelf_life_hours")
            or freshness_config.get("shelf_life_hours")
        )
        global_temp_c = global_spoilage.get("temperature_c", supply_input.get("temperature_c"))
        global_humidity_pct = global_spoilage.get("humidity_percent", supply_input.get("humidity_percent"))

        # Global price unit if declared at top-level or in 'price' section
        price_data = data.get("price") or {}
        global_price_unit = data.get("price_unit") or price_data.get("price_unit")

        farmer_lat = data["farmer_location"]["latitude"]
        farmer_lon = data["farmer_location"]["longitude"]

        # -------------------------------------------------------------
        # 3. Process Each Candidate Market (Modules 8, 3, 5, 2, 6)
        # -------------------------------------------------------------
        market_details: List[Dict[str, Any]] = []
        decision_market_inputs: List[Dict[str, Any]] = []

        for m in data["markets"]:
            market_name = str(m["market"]).strip()
            buyer_name = str(m["buyer_name"]).strip()
            market_lat = m["latitude"]
            market_lon = m["longitude"]

            # Validate Price Unit (Requirement 1: Explicit per-kg unit required)
            market_price_data = m.get("price") or {}
            m_price_unit = (
                m.get("price_unit")
                or market_price_data.get("price_unit")
                or global_price_unit
            )
            validated_price_unit = self._validate_price_unit(m_price_unit, market_name)

            # --- A. Routing (Module 8) ---
            try:
                routing_result = self.routing_service.get_route(
                    farmer_latitude=farmer_lat,
                    farmer_longitude=farmer_lon,
                    market_latitude=market_lat,
                    market_longitude=market_lon,
                )
            except Exception as e:
                raise RuntimeError(f"Routing failed for market '{market_name}': {str(e)}") from e

            distance_km = float(routing_result["distance_km"])
            travel_time_hours = float(routing_result["travel_time_hours"])

            # --- B. Transportation Cost (Module 3) ---
            transport_config = m.get("transport") or {}
            cost_per_km = float(transport_config.get("cost_per_km", 30.0))
            try:
                transport_result = self.transport_service.calculate_cost(
                    distance_km=distance_km,
                    cost_per_km=cost_per_km,
                    supply_kg=supply_kg,
                )
            except Exception as e:
                raise RuntimeError(f"Transport calculation failed for market '{market_name}': {str(e)}") from e

            total_transport_cost = float(transport_result["total_transport_cost"])

            # --- C. Spoilage Risk (Module 5) ---
            market_spoilage = m.get("spoilage") or {}
            shelf_life_hours = (
                m.get("shelf_life_hours")
                or market_spoilage.get("shelf_life_hours")
                or global_shelf_life
            )
            if shelf_life_hours is None:
                raise ValueError(
                    f"Missing required 'shelf_life_hours' for market '{market_name}'. "
                    "Cannot evaluate spoilage risk."
                )

            temp_c = float(m.get("temperature_c", global_temp_c))
            hum_pct = float(m.get("humidity_percent", global_humidity_pct))

            spoilage_input = {
                "fresh_probability": fresh_probability,
                "shelf_life_hours": float(shelf_life_hours),
                "travel_time_hours": travel_time_hours,
                "temperature_c": temp_c,
                "humidity_percent": hum_pct,
                "supply_kg": supply_kg,
            }

            try:
                spoilage_result = self.spoilage_service.calculate_risk(spoilage_input)
            except Exception as e:
                raise RuntimeError(f"Spoilage calculation failed for market '{market_name}': {str(e)}") from e

            spoilage_percentage = float(spoilage_result["spoilage_percentage"])

            # --- D. Price Prediction (Module 2) ---
            market_price_config = m.get("price") or data.get("price")
            if not market_price_config:
                raise ValueError(f"Missing required price prediction input data for market '{market_name}'.")

            price_input = dict(market_price_config)
            # Ensure Market and Commodity match context if not specified in price block
            price_input.setdefault("Market", market_name)
            price_input.setdefault("Commodity", supply_input.get("crop"))

            try:
                price_result = self.price_service.predict(price_input)
            except Exception as e:
                raise RuntimeError(f"Price prediction failed for market '{market_name}': {str(e)}") from e

            predicted_price_per_kg = float(price_result["predicted_price_per_kg"])

            # --- E. Demand Analysis (Module 6) ---
            demand_config = m.get("demand") or m
            demand_input = {
                "commodity": str(demand_config.get("commodity", supply_input.get("crop"))),
                "market": market_name,
                "buyer_name": buyer_name,
                "demand_kg": demand_config.get("demand_kg"),
                "buyer_capacity_kg": demand_config.get("buyer_capacity_kg"),
                "current_supply_kg": demand_config.get("current_supply_kg", supply_kg),
            }

            try:
                demand_result = self.demand_service.analyze_demand(demand_input)
            except Exception as e:
                raise RuntimeError(f"Demand analysis failed for market '{market_name}': {str(e)}") from e

            available_capacity_kg = float(demand_result["available_capacity_kg"])

            # --- F. Assemble Market Comparison Record for Module 7 ---
            decision_item = {
                "market": market_name,
                "buyer_name": buyer_name,
                "predicted_price_per_kg": predicted_price_per_kg,
                "transport_cost": total_transport_cost,
                "spoilage_percentage": spoilage_percentage,
                "demand_kg": float(demand_input["demand_kg"]),
                "available_capacity_kg": available_capacity_kg,
            }
            decision_market_inputs.append(decision_item)

            market_details.append({
                "market": market_name,
                "buyer_name": buyer_name,
                "routing": {
                    "distance_km": distance_km,
                    "travel_time_hours": travel_time_hours,
                },
                "transport": transport_result,
                "spoilage": spoilage_result,
                "demand": demand_result,
                "price": {
                    **price_result,
                    "price_unit": validated_price_unit,
                    "predicted_price_per_kg": predicted_price_per_kg,
                },
            })

        # -------------------------------------------------------------
        # 4. Market Comparison & Decision (Module 7)
        # -------------------------------------------------------------
        try:
            decision_result = self.decision_service.compare_markets(
                markets=decision_market_inputs,
                supply_kg=supply_kg,
            )
        except Exception as e:
            raise RuntimeError(f"Market decision failed: {str(e)}") from e

        # Pair each market's decision trade-off metrics into market_details
        decision_options_map = {
            (opt["market"], opt["buyer_name"]): opt
            for opt in decision_result.get("market_options", [])
        }
        for item in market_details:
            key = (item["market"], item["buyer_name"])
            item["decision"] = decision_options_map.get(key, {})

        # -------------------------------------------------------------
        # 5. Final Structured Response
        # -------------------------------------------------------------
        return {
            "supply": supply_result,
            "freshness": freshness_result,
            "price_unit": global_price_unit or market_details[0]["price"]["price_unit"],
            "markets": market_details,
            "recommendation": decision_result.get("recommended_market"),
        }


# Alias for shorthand import
RecommendationService = FarmToMarketRecommendationService

