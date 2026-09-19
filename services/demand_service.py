import numpy as np

class DemandAnalysisService:
    """
    Module 6: Demand & Buyer Capacity Engine
    Deterministic calculation engine that determines available buyer capacity,
    demand coverage ratio, demand status, and buyer capacity status for a target market.
    """

    def analyze_demand(self, data: dict) -> dict:
        """
        Analyzes market/buyer demand and capacity metrics.
        """
        self._validate_input(data)

        commodity = data["commodity"].strip()
        market = data["market"].strip()
        buyer_name = data["buyer_name"].strip()

        demand_kg = float(data["demand_kg"])
        buyer_capacity_kg = float(data["buyer_capacity_kg"])
        current_supply_kg = float(data["current_supply_kg"])

        # 1. Calculate Available Capacity (Cannot be negative)
        available_capacity_kg = max(0.0, buyer_capacity_kg - current_supply_kg)

        # 2. Calculate Demand Coverage Ratio
        demand_coverage = current_supply_kg / demand_kg

        # 3. Determine Demand and Capacity Statuses
        demand_status = self._get_demand_status(demand_coverage)
        capacity_status = self._get_capacity_status(available_capacity_kg)

        # 4. Construct & Return Formatted Output
        return {
            "commodity": commodity,
            "market": market,
            "buyer_name": buyer_name,
            "demand_kg": round(demand_kg, 2),
            "buyer_capacity_kg": round(buyer_capacity_kg, 2),
            "current_supply_kg": round(current_supply_kg, 2),
            "available_capacity_kg": round(available_capacity_kg, 2),
            "demand_coverage": round(demand_coverage, 4),
            "demand_status": demand_status,
            "capacity_status": capacity_status
        }

    def _get_demand_status(self, coverage: float) -> str:
        """Categorizes demand coverage ratio into deterministic status levels."""
        if coverage < 0.50:
            return "low_demand"
        elif coverage < 0.80:
            return "moderate_demand"
        elif coverage <= 1.00:
            return "high_demand"
        else:
            return "oversupplied"

    def _get_capacity_status(self, available_capacity_kg: float) -> str:
        """Determines buyer capacity status based on remaining available capacity."""
        if available_capacity_kg > 0.0:
            return "capacity_available"
        else:
            return "capacity_full"

    def _validate_input(self, data: dict):
        """Validates input types and domain constraints."""
        if not isinstance(data, dict):
            raise TypeError("Input data must be a dictionary.")

        required_fields = [
            "commodity",
            "market",
            "buyer_name",
            "demand_kg",
            "buyer_capacity_kg",
            "current_supply_kg"
        ]

        for field in required_fields:
            if field not in data or data[field] is None:
                raise ValueError(f"Missing required parameter: '{field}'.")

        # Validate String Fields
        string_fields = ["commodity", "market", "buyer_name"]
        for s_field in string_fields:
            val = data[s_field]
            if not isinstance(val, str):
                raise ValueError(f"Invalid type for '{s_field}': expected non-empty string.")
            if not val.strip():
                raise ValueError(f"Invalid value for '{s_field}': string cannot be empty or whitespace only.")

        # Validate Numeric Fields
        numeric_fields = ["demand_kg", "buyer_capacity_kg", "current_supply_kg"]
        for n_field in numeric_fields:
            val = data[n_field]
            if isinstance(val, bool):
                raise TypeError(f"Invalid type for '{n_field}': boolean is not allowed.")
            if not isinstance(val, (int, float)):
                raise TypeError(f"Invalid type for '{n_field}': expected int or float, got {type(val).__name__}.")
            if np.isnan(val):
                raise ValueError(f"Invalid value for '{n_field}': value cannot be NaN.")

        demand_kg = data["demand_kg"]
        if demand_kg <= 0.0:
            raise ValueError(f"Invalid demand_kg ({demand_kg}): must be strictly greater than 0.")

        buyer_capacity_kg = data["buyer_capacity_kg"]
        if buyer_capacity_kg < 0.0:
            raise ValueError(f"Invalid buyer_capacity_kg ({buyer_capacity_kg}): cannot be negative.")

        current_supply_kg = data["current_supply_kg"]
        if current_supply_kg < 0.0:
            raise ValueError(f"Invalid current_supply_kg ({current_supply_kg}): cannot be negative.")
