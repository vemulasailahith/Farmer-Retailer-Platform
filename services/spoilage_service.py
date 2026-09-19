import numpy as np

class SpoilageRiskService:
    """
    Module 5: Spoilage Risk Engine
    Transparent rule-based risk engine for estimating post-harvest produce spoilage risk,
    spoilage percentage, spoiled quantity, and saleable quantity based on initial freshness,
    transit time ratio, temperature, and humidity.
    
    NOTE:
    - Temperature & Humidity risk thresholds are configurable heuristic assumptions.
    - Risk component weights (Freshness: 40%, Transit: 30%, Temp: 20%, Humidity: 10%) are engineering assumptions.
    - This is a deterministic rule-based spoilage risk estimate, NOT an ML prediction model.
    """

    # Configurable Weight Assumptions (Sum = 1.0)
    WEIGHT_FRESHNESS = 0.40
    WEIGHT_TRANSIT = 0.30
    WEIGHT_TEMPERATURE = 0.20
    WEIGHT_HUMIDITY = 0.10

    def calculate_risk(self, data: dict) -> dict:
        """
        Calculates rule-based spoilage risk metrics for a produce batch.
        """
        self._validate_input(data)

        fresh_probability = float(data["fresh_probability"])
        shelf_life_hours = float(data["shelf_life_hours"])
        travel_time_hours = float(data["travel_time_hours"])
        temperature_c = float(data["temperature_c"])
        humidity_percent = float(data["humidity_percent"])
        supply_kg = float(data["supply_kg"])

        # A. Initial Freshness Risk
        freshness_risk = 1.0 - fresh_probability

        # B. Transit-Time Risk Ratio (Clamped to 0.0 - 1.0)
        transit_ratio = travel_time_hours / shelf_life_hours
        transit_ratio = min(max(transit_ratio, 0.0), 1.0)

        # C. Temperature Risk (Heuristic Ranges)
        temperature_risk = self._get_temperature_risk(temperature_c)

        # D. Humidity Risk (Heuristic Ranges)
        humidity_risk = self._get_humidity_risk(humidity_percent)

        # E. Combined Spoilage Risk Calculation
        spoilage_risk = (
            (self.WEIGHT_FRESHNESS * freshness_risk) +
            (self.WEIGHT_TRANSIT * transit_ratio) +
            (self.WEIGHT_TEMPERATURE * temperature_risk) +
            (self.WEIGHT_HUMIDITY * humidity_risk)
        )

        spoilage_risk = min(max(spoilage_risk, 0.0), 1.0)
        spoilage_percentage = spoilage_risk * 100.0

        # F. Spoiled and Saleable Quantities
        estimated_spoiled_kg = max(0.0, supply_kg * spoilage_risk)
        estimated_saleable_kg = max(0.0, supply_kg - estimated_spoiled_kg)

        # G. Risk Level Categorization
        risk_level = self._get_risk_level(spoilage_risk)

        return {
            "spoilage_risk": round(spoilage_risk, 4),
            "spoilage_percentage": round(spoilage_percentage, 4),
            "risk_level": risk_level,
            "estimated_spoiled_kg": round(estimated_spoiled_kg, 4),
            "estimated_saleable_kg": round(estimated_saleable_kg, 4)
        }

    def _get_temperature_risk(self, temp: float) -> float:
        """Heuristic temperature risk mapping."""
        if temp <= 10.0:
            return 0.05
        elif temp <= 20.0:
            return 0.15
        elif temp <= 30.0:
            return 0.35
        elif temp <= 35.0:
            return 0.60
        else:
            return 0.80

    def _get_humidity_risk(self, humidity: float) -> float:
        """Heuristic humidity risk mapping."""
        if humidity < 50.0:
            return 0.10
        elif humidity < 70.0:
            return 0.20
        elif humidity < 85.0:
            return 0.40
        else:
            return 0.60

    def _get_risk_level(self, risk: float) -> str:
        """Categorizes numerical risk into human-readable levels."""
        if risk < 0.25:
            return "low"
        elif risk < 0.50:
            return "medium"
        elif risk < 0.75:
            return "high"
        else:
            return "very_high"

    def _validate_input(self, data: dict):
        """Validates all input parameter types and domain constraints."""
        required_fields = [
            "fresh_probability",
            "shelf_life_hours",
            "travel_time_hours",
            "temperature_c",
            "humidity_percent",
            "supply_kg"
        ]

        if not isinstance(data, dict):
            raise TypeError("Input 'data' must be a dictionary.")

        for field in required_fields:
            if field not in data or data[field] is None:
                raise ValueError(f"Missing required parameter: '{field}'.")

            val = data[field]
            if isinstance(val, bool):
                raise TypeError(f"Invalid type for '{field}': boolean is not allowed.")
            if not isinstance(val, (int, float)):
                raise TypeError(f"Invalid type for '{field}': expected int or float, got {type(val).__name__}.")
            if np.isnan(val):
                raise ValueError(f"Invalid value for '{field}': cannot be NaN.")

        fresh_prob = data["fresh_probability"]
        if fresh_prob < 0.0 or fresh_prob > 1.0:
            raise ValueError(f"Invalid fresh_probability ({fresh_prob}): must be between 0.0 and 1.0.")

        shelf_life = data["shelf_life_hours"]
        if shelf_life <= 0.0:
            raise ValueError(f"Invalid shelf_life_hours ({shelf_life}): must be strictly greater than 0.")

        travel_time = data["travel_time_hours"]
        if travel_time < 0.0:
            raise ValueError(f"Invalid travel_time_hours ({travel_time}): cannot be negative.")

        humidity = data["humidity_percent"]
        if humidity < 0.0 or humidity > 100.0:
            raise ValueError(f"Invalid humidity_percent ({humidity}): must be between 0.0 and 100.0.")

        supply = data["supply_kg"]
        if supply <= 0.0:
            raise ValueError(f"Invalid supply_kg ({supply}): must be strictly greater than 0.")
