import numpy as np

class TransportationCostService:
    """
    Module 3: Transportation Cost Engine
    Calculates total transportation cost and cost per unit weight (kg) 
    based on distance, vehicle cost per km, and total supply quantity.
    """

    def calculate_cost(self, distance_km: float, cost_per_km: float = 30.0, supply_kg: float = None) -> dict:
        """
        Calculates total transport cost and per-kg transport cost.
        
        Formulas:
            Total Transport Cost = Distance (km) * Cost per km
            Transport Cost per kg = Total Transport Cost / Supply (kg)
        """
        # 1. Validate distance_km
        if not isinstance(distance_km, (int, float)) or isinstance(distance_km, bool):
            raise TypeError("Parameter 'distance_km' must be a numeric value (int or float).")
        if np.isnan(distance_km):
            raise ValueError("Parameter 'distance_km' cannot be NaN.")
        if distance_km < 0:
            raise ValueError(f"Invalid distance_km ({distance_km}): Distance cannot be negative.")

        # 2. Validate cost_per_km
        if not isinstance(cost_per_km, (int, float)) or isinstance(cost_per_km, bool):
            raise TypeError("Parameter 'cost_per_km' must be a numeric value (int or float).")
        if np.isnan(cost_per_km):
            raise ValueError("Parameter 'cost_per_km' cannot be NaN.")
        if cost_per_km < 0:
            raise ValueError(f"Invalid cost_per_km ({cost_per_km}): Cost per km cannot be negative.")

        # 3. Validate supply_kg if provided
        if supply_kg is not None:
            if not isinstance(supply_kg, (int, float)) or isinstance(supply_kg, bool):
                raise TypeError("Parameter 'supply_kg' must be a numeric value (int or float).")
            if np.isnan(supply_kg):
                raise ValueError("Parameter 'supply_kg' cannot be NaN.")
            if supply_kg <= 0:
                raise ValueError(f"Invalid supply_kg ({supply_kg}): Supply weight must be strictly greater than 0.")

        # 4. Perform Cost Calculations
        total_transport_cost = float(distance_km * cost_per_km)

        transport_cost_per_kg = None
        if supply_kg is not None:
            transport_cost_per_kg = float(total_transport_cost / supply_kg)

        # 5. Format & Return Structured Response
        return {
            "distance_km": float(distance_km),
            "cost_per_km": float(cost_per_km),
            "total_transport_cost": round(total_transport_cost, 2),
            "supply_kg": float(supply_kg) if supply_kg is not None else None,
            "transport_cost_per_kg": round(transport_cost_per_kg, 2) if transport_cost_per_kg is not None else None
        }
