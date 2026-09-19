import numpy as np

class MarketDecisionService:
    """
    Module 7: Market Comparison & Decision Engine
    Deterministic calculation and comparison engine that evaluates multiple market/buyer
    options based on predicted price, transportation cost, spoilage loss, buyer demand,
    and available buyer capacity. Recommends the optimal market based on highest feasible net expected revenue.
    """

    def compare_markets(self, markets: list, supply_kg: float) -> dict:
        """
        Compares multiple target market options and determines the recommended market.
        """
        self._validate_supply(supply_kg)
        self._validate_markets(markets)

        supply_kg = float(supply_kg)
        market_options = []
        feasible_options = []

        for m_data in markets:
            analysis = self._analyze_single_market(m_data, supply_kg)
            market_options.append(analysis)
            if analysis["feasibility"] == "feasible":
                feasible_options.append(analysis)

        # Recommendation logic based on highest net expected revenue among feasible markets
        recommended_market = None
        if feasible_options:
            best_market = max(feasible_options, key=lambda x: x["net_expected_revenue"])
            recommended_market = {
                "market": best_market["market"],
                "buyer_name": best_market["buyer_name"],
                "reason": (
                    "Highest feasible net expected revenue after transport cost, "
                    "while accounting for spoilage and buyer capacity."
                )
            }

        return {
            "supply_kg": round(supply_kg, 2),
            "market_options": market_options,
            "recommended_market": recommended_market
        }

    def _analyze_single_market(self, m_data: dict, supply_kg: float) -> dict:
        """Calculates all trade-off metrics for a single market option."""
        market = m_data["market"].strip()
        buyer_name = m_data["buyer_name"].strip()
        predicted_price_per_kg = float(m_data["predicted_price_per_kg"])
        transport_cost = float(m_data["transport_cost"])
        spoilage_percentage = float(m_data["spoilage_percentage"])
        demand_kg = float(m_data["demand_kg"])
        available_capacity_kg = float(m_data["available_capacity_kg"])

        # 1. Spoilage & Saleable Quantity
        spoilage_fraction = spoilage_percentage / 100.0
        spoilage_quantity_kg = supply_kg * spoilage_fraction
        saleable_quantity_kg = max(0.0, supply_kg - spoilage_quantity_kg)

        # 2. Demand & Buyer Capacity Constraint
        sellable_quantity_kg = min(saleable_quantity_kg, demand_kg, available_capacity_kg)

        # 3. Financial Metrics
        gross_revenue = sellable_quantity_kg * predicted_price_per_kg
        net_expected_revenue = gross_revenue - transport_cost

        # 4. Unsold & Unavailable Quantities
        unsold_quantity_kg = max(0.0, saleable_quantity_kg - sellable_quantity_kg)
        total_unavailable_quantity_kg = supply_kg - sellable_quantity_kg

        # 5. Normalized Metric
        net_value_per_original_kg = net_expected_revenue / supply_kg

        # 6. Feasibility Check
        feasibility = "feasible" if self._is_market_feasible(predicted_price_per_kg, available_capacity_kg, sellable_quantity_kg) else "not_feasible"

        return {
            "market": market,
            "buyer_name": buyer_name,
            "predicted_price_per_kg": round(predicted_price_per_kg, 2),
            "transport_cost": round(transport_cost, 2),
            "spoilage_percentage": round(spoilage_percentage, 2),
            "spoilage_quantity_kg": round(spoilage_quantity_kg, 2),
            "saleable_quantity_kg": round(saleable_quantity_kg, 2),
            "demand_kg": round(demand_kg, 2),
            "available_capacity_kg": round(available_capacity_kg, 2),
            "sellable_quantity_kg": round(sellable_quantity_kg, 2),
            "unsold_quantity_kg": round(unsold_quantity_kg, 2),
            "gross_revenue": round(gross_revenue, 2),
            "net_expected_revenue": round(net_expected_revenue, 2),
            "net_value_per_original_kg": round(net_value_per_original_kg, 2),
            "total_unavailable_quantity_kg": round(total_unavailable_quantity_kg, 2),
            "feasibility": feasibility
        }

    def _is_market_feasible(self, predicted_price: float, available_capacity: float, sellable_quantity: float) -> bool:
        """Determines if a market option is feasible."""
        return predicted_price > 0.0 and available_capacity > 0.0 and sellable_quantity > 0.0

    def _validate_supply(self, supply_kg: float):
        """Validates supply_kg input."""
        if isinstance(supply_kg, bool):
            raise TypeError("Invalid supply_kg: boolean is not allowed.")
        if not isinstance(supply_kg, (int, float)):
            raise TypeError(f"Invalid supply_kg type: expected int or float, got {type(supply_kg).__name__}.")
        if np.isnan(supply_kg):
            raise ValueError("Invalid supply_kg: value cannot be NaN.")
        if supply_kg <= 0.0:
            raise ValueError(f"Invalid supply_kg ({supply_kg}): must be strictly greater than 0.")

    def _validate_markets(self, markets: list):
        """Validates markets list and each item's structure and constraints."""
        if not isinstance(markets, list):
            raise TypeError("Input 'markets' must be a list.")
        if not markets:
            raise ValueError("Input 'markets' list cannot be empty.")

        required_fields = [
            "market",
            "buyer_name",
            "predicted_price_per_kg",
            "transport_cost",
            "spoilage_percentage",
            "demand_kg",
            "available_capacity_kg"
        ]

        for idx, m in enumerate(markets):
            if not isinstance(m, dict):
                raise TypeError(f"Market item at index {idx} must be a dictionary.")

            for field in required_fields:
                if field not in m or m[field] is None:
                    raise ValueError(f"Market item at index {idx} missing required parameter: '{field}'.")

            # Validate String Fields
            for s_field in ["market", "buyer_name"]:
                val = m[s_field]
                if not isinstance(val, str):
                    raise ValueError(f"Market item at index {idx} invalid type for '{s_field}': expected string.")
                if not val.strip():
                    raise ValueError(f"Market item at index {idx} invalid '{s_field}': string cannot be empty or whitespace only.")

            # Validate Numeric Fields
            numeric_fields = [
                "predicted_price_per_kg",
                "transport_cost",
                "spoilage_percentage",
                "demand_kg",
                "available_capacity_kg"
            ]

            for n_field in numeric_fields:
                val = m[n_field]
                if isinstance(val, bool):
                    raise TypeError(f"Market item at index {idx} invalid type for '{n_field}': boolean is not allowed.")
                if not isinstance(val, (int, float)):
                    raise TypeError(f"Market item at index {idx} invalid type for '{n_field}': expected int or float, got {type(val).__name__}.")
                if np.isnan(val):
                    raise ValueError(f"Market item at index {idx} invalid value for '{n_field}': value cannot be NaN.")

            # Domain Constraints
            if m["predicted_price_per_kg"] < 0.0:
                raise ValueError(f"Market item at index {idx} negative predicted_price_per_kg ({m['predicted_price_per_kg']}).")
            if m["transport_cost"] < 0.0:
                raise ValueError(f"Market item at index {idx} negative transport_cost ({m['transport_cost']}).")
            if m["spoilage_percentage"] < 0.0 or m["spoilage_percentage"] > 100.0:
                raise ValueError(f"Market item at index {idx} invalid spoilage_percentage ({m['spoilage_percentage']}): must be between 0 and 100.")
            if m["demand_kg"] < 0.0:
                raise ValueError(f"Market item at index {idx} negative demand_kg ({m['demand_kg']}).")
            if m["available_capacity_kg"] < 0.0:
                raise ValueError(f"Market item at index {idx} negative available_capacity_kg ({m['available_capacity_kg']}).")
