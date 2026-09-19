import math
import os
from typing import Optional
import joblib
import numpy as np
import pandas as pd


class SupplyPredictionService:
    """
    Module 1: Supply & Yield Prediction Service

    Predicts crop yield using:
    1. Trained scikit-learn Pipeline (crop_yield_model.pkl) for 55 ML-supported crops.
    2. Deterministic demo fallback yields for unsupported vegetables from the Flutter app list.

    Converts predicted yield from tonnes/ha to kg/ha and calculates expected total supply:
        predicted_yield_kg_per_ha = predicted_yield_tonnes_per_ha * 1000
        expected_supply_kg = predicted_yield_tonnes_per_ha * farm_area_ha * 1000
        expected_supply_tonnes = predicted_yield_tonnes_per_ha * farm_area_ha
    """

    MODEL_FILENAME = "crop_yield_model.pkl"

    # Supported crops matching the 55 crops in the trained ML model dataset
    SUPPORTED_CROPS = [
        "Arecanut",
        "Arhar/Tur",
        "Bajra",
        "Banana",
        "Barley",
        "Black pepper",
        "Cardamom",
        "Cashewnut",
        "Castor seed",
        "Coconut",
        "Coriander",
        "Cotton(lint)",
        "Cowpea(Lobia)",
        "Dry chillies",
        "Garlic",
        "Ginger",
        "Gram",
        "Groundnut",
        "Guar seed",
        "Horse-gram",
        "Jowar",
        "Jute",
        "Khesari",
        "Linseed",
        "Maize",
        "Masoor",
        "Mesta",
        "Moong(Green Gram)",
        "Moth",
        "Niger seed",
        "Oilseeds total",
        "Onion",
        "Other  Rabi pulses",
        "Other Cereals",
        "Other Kharif pulses",
        "Other Summer Pulses",
        "Peas & beans (Pulses)",
        "Potato",
        "Ragi",
        "Rapeseed &Mustard",
        "Rice",
        "Safflower",
        "Sannhamp",
        "Sesamum",
        "Small millets",
        "Soyabean",
        "Sugarcane",
        "Sunflower",
        "Sweet potato",
        "Tapioca",
        "Tobacco",
        "Turmeric",
        "Urad",
        "Wheat",
        "other oilseeds",
    ]

    # Pre-built case-insensitive lookup table with common aliases for ML crops
    _CROP_MAP = {c.lower(): c for c in SUPPORTED_CROPS}
    _CROP_MAP.update({
        "cotton": "Cotton(lint)",
        "moong": "Moong(Green Gram)",
        "tur": "Arhar/Tur",
        "arhar": "Arhar/Tur",
        "lobia": "Cowpea(Lobia)",
        "dry chilli": "Dry chillies",
        "dry chili": "Dry chillies",
        "mustard": "Rapeseed &Mustard",
        "rapeseed": "Rapeseed &Mustard",
        "soybean": "Soyabean",
    })

    # Fixed deterministic demo yield values (tonnes/ha) for Flutter vegetables not in ML dataset
    DEMO_FALLBACK_YIELDS = {
        "tomato": 20.0,
        "brinjal": 18.0,
        "eggplant": 18.0,
        "bhindi": 10.0,
        "okra": 10.0,
        "ladies finger": 10.0,
        "bottle gourd": 15.0,
        "bitter gourd": 12.0,
        "ridge gourd": 13.0,
        "snake gourd": 14.0,
        "cabbage": 25.0,
        "cauliflower": 20.0,
        "carrot": 18.0,
        "spinach": 12.0,
        "capsicum": 15.0,
        "bell pepper": 15.0,
        "green chilli": 10.0,
        "green chili": 10.0,
        "beans": 10.0,
        "green peas": 8.0,
    }

    # Canonical display names for fallback vegetables
    FALLBACK_CROP_NAMES = {
        "tomato": "Tomato",
        "brinjal": "Brinjal",
        "eggplant": "Brinjal",
        "bhindi": "Bhindi",
        "okra": "Bhindi",
        "ladies finger": "Bhindi",
        "bottle gourd": "Bottle Gourd",
        "bitter gourd": "Bitter Gourd",
        "ridge gourd": "Ridge Gourd",
        "snake gourd": "Snake Gourd",
        "cabbage": "Cabbage",
        "cauliflower": "Cauliflower",
        "carrot": "Carrot",
        "spinach": "Spinach",
        "capsicum": "Capsicum",
        "bell pepper": "Capsicum",
        "green chilli": "Green Chilli",
        "green chili": "Green Chilli",
        "beans": "Beans",
        "green peas": "Green Peas",
    }

    # Exact feature names expected by the scikit-learn Pipeline
    MODEL_FEATURE_NAMES = [
        "Crop",
        "Crop_Year",
        "Season",
        "State",
        "Area",
        "Annual_Rainfall",
        "Fertilizer",
        "Pesticide",
        "Avg_Temperature",
        "Max_Temperature",
        "Min_Temperature",
    ]

    def __init__(self, models_dir: str = "models", model=None):
        self.models_dir = models_dir
        self.model_path = os.path.join(models_dir, self.MODEL_FILENAME)
        self.model = model

        if self.model is None:
            self._load_model()

    def _load_model(self):
        """Loads the trained scikit-learn pipeline model once during service initialization."""
        if not os.path.exists(self.model_path):
            raise FileNotFoundError(
                f"[SupplyPredictionService] Required model file '{self.model_path}' not found. "
                f"Please ensure '{self.MODEL_FILENAME}' exists in '{self.models_dir}'."
            )

        try:
            self.model = joblib.load(self.model_path)
        except Exception as e:
            raise RuntimeError(
                f"[SupplyPredictionService] Failed to load ML model from '{self.model_path}': {str(e)}"
            ) from e

    def _validate_numeric(
        self,
        val,
        name: str,
        min_val: Optional[float] = None,
        allow_zero: bool = True,
        must_be_int: bool = False,
    ):
        """Validates numeric types, rejecting booleans, NaN, infinity, and out-of-range values."""
        if val is None:
            raise ValueError(f"Missing required parameter: '{name}' cannot be None.")
        if isinstance(val, bool):
            raise TypeError(f"Invalid type for '{name}': boolean value is not allowed.")

        if must_be_int:
            if isinstance(val, int):
                pass
            elif isinstance(val, float) and val.is_integer():
                val = int(val)
            elif isinstance(val, str) and val.strip().lstrip("-").isdigit():
                val = int(val.strip())
            else:
                raise TypeError(f"Invalid type for '{name}': expected integer, got {type(val).__name__}.")
        else:
            if not isinstance(val, (int, float)):
                raise TypeError(f"Invalid type for '{name}': expected numeric (int or float), got {type(val).__name__}.")

        float_val = float(val)
        if math.isnan(float_val) or np.isnan(float_val):
            raise ValueError(f"Invalid value for '{name}': value cannot be NaN.")
        if math.isinf(float_val) or np.isinf(float_val):
            raise ValueError(f"Invalid value for '{name}': value cannot be infinity.")

        if min_val is not None:
            if allow_zero:
                if float_val < min_val:
                    raise ValueError(f"Invalid value for '{name}' ({float_val}): must be >= {min_val}.")
            else:
                if float_val <= min_val:
                    raise ValueError(f"Invalid value for '{name}' ({float_val}): must be strictly greater than {min_val}.")

        return int(val) if must_be_int else float_val

    def predict_supply(
        self,
        crop: str,
        area_ha: Optional[float] = None,
        season: str = "Whole Year",
        state: Optional[str] = None,
        crop_year: Optional[int] = None,
        annual_rainfall: Optional[float] = None,
        fertilizer: float = 0.0,
        pesticide: float = 0.0,
        avg_temperature: Optional[float] = None,
        max_temperature: Optional[float] = None,
        min_temperature: Optional[float] = None,
        # Backward-compatible parameter aliases
        farm_area_ha: Optional[float] = None,
        state_name: Optional[str] = None,
        dist_name: Optional[str] = None,
        year: Optional[int] = None,
        rainfall_mm: Optional[float] = None,
        temperature_c: Optional[float] = None,
        **kwargs,
    ) -> dict:
        """
        Executes crop yield prediction (tonnes/ha) and converts to kg/ha and expected supply.
        Uses real ML model for 55 supported crops, and deterministic demo fallback yields
        for unsupported vegetables from the Flutter selection list.

        Returns:
            dict containing:
                crop: canonical crop name
                state: state name
                season: cropping season
                crop_year: harvest year
                farm_area_ha: area in hectares
                predicted_yield_tonnes_per_ha: yield in tonnes/ha
                predicted_yield_kg_per_ha: yield in kg/ha
                expected_supply_kg: total expected supply in kg
                expected_supply_tonnes: total expected supply in tonnes
                prediction_source: "ml_model" or "demo_fallback"
                is_demo_prediction: False or True
        """
        # Resolve aliases
        effective_area = area_ha if area_ha is not None else farm_area_ha
        effective_state = state if state is not None else state_name
        effective_year = crop_year if crop_year is not None else year
        effective_rainfall = annual_rainfall if annual_rainfall is not None else rainfall_mm
        effective_avg_temp = avg_temperature if avg_temperature is not None else temperature_c

        # 1. Validate Crop
        if crop is None or not isinstance(crop, str) or not crop.strip():
            raise ValueError("Empty crop is rejected. Crop must be a non-empty string.")

        crop_clean = crop.strip()
        crop_lower = crop_clean.lower()

        # Determine whether crop is ML-supported or demo fallback
        if crop_lower in self._CROP_MAP:
            canonical_crop = self._CROP_MAP[crop_lower]
            prediction_source = "ml_model"
            is_demo_prediction = False
            fallback_yield = None
        elif crop_lower in self.DEMO_FALLBACK_YIELDS:
            canonical_crop = self.FALLBACK_CROP_NAMES.get(crop_lower, crop_clean)
            prediction_source = "demo_fallback"
            is_demo_prediction = True
            fallback_yield = self.DEMO_FALLBACK_YIELDS[crop_lower]
        else:
            raise ValueError(f"Yield prediction is not available for crop: {crop_clean}")

        # 2. Validate Season & State strings
        if season is None or not isinstance(season, str) or not season.strip():
            raise ValueError("season must not be empty.")
        if effective_state is None or not isinstance(effective_state, str) or not effective_state.strip():
            raise ValueError("state must not be empty.")

        # 3. Validate Numeric Fields
        validated_year = self._validate_numeric(effective_year, "crop_year", must_be_int=True)
        validated_area = self._validate_numeric(effective_area, "area_ha", min_val=0.0, allow_zero=False)
        validated_rainfall = self._validate_numeric(
            0.0 if effective_rainfall is None else effective_rainfall,
            "annual_rainfall",
            min_val=0.0,
            allow_zero=True,
        )
        validated_fertilizer = self._validate_numeric(fertilizer, "fertilizer", min_val=0.0, allow_zero=True)
        validated_pesticide = self._validate_numeric(pesticide, "pesticide", min_val=0.0, allow_zero=True)

        # 4. Handle Temperature Values
        if effective_avg_temp is not None:
            max_temperature = max_temperature if max_temperature is not None else effective_avg_temp
            min_temperature = min_temperature if min_temperature is not None else effective_avg_temp
        elif max_temperature is not None and min_temperature is not None:
            effective_avg_temp = (max_temperature + min_temperature) / 2.0
        else:
            raise ValueError("Temperature values must be numeric and provided.")

        validated_avg_temp = self._validate_numeric(effective_avg_temp, "avg_temperature")
        validated_max_temp = self._validate_numeric(max_temperature, "max_temperature")
        validated_min_temp = self._validate_numeric(min_temperature, "min_temperature")

        # 5. Predict Yield (Pipeline target is tonnes/hectare)
        if is_demo_prediction:
            # Deterministic fallback yield - do NOT call ML model
            predicted_yield_tonnes_per_ha = float(fallback_yield)
        else:
            # Call real scikit-learn Pipeline
            input_data = {
                "Crop": [canonical_crop],
                "Crop_Year": [validated_year],
                "Season": [season.strip()],
                "State": [effective_state.strip()],
                "Area": [validated_area],
                "Annual_Rainfall": [validated_rainfall],
                "Fertilizer": [validated_fertilizer],
                "Pesticide": [validated_pesticide],
                "Avg_Temperature": [validated_avg_temp],
                "Max_Temperature": [validated_max_temp],
                "Min_Temperature": [validated_min_temp],
            }

            input_df = pd.DataFrame(input_data)[self.MODEL_FEATURE_NAMES]

            try:
                raw_prediction = float(self.model.predict(input_df)[0])
            except Exception as e:
                raise RuntimeError(f"Error during crop yield prediction: {str(e)}") from e

            predicted_yield_tonnes_per_ha = max(0.0, raw_prediction)

        # 6. Convert Yield and calculate Expected Supply
        predicted_yield_tonnes_per_ha = round(predicted_yield_tonnes_per_ha, 4)
        predicted_yield_kg_per_ha = round(predicted_yield_tonnes_per_ha * 1000.0, 4)
        expected_supply_kg = round(predicted_yield_tonnes_per_ha * validated_area * 1000.0, 4)
        expected_supply_tonnes = round(predicted_yield_tonnes_per_ha * validated_area, 4)

        # 7. Return clean, structured dictionary
        return {
            "crop": canonical_crop,
            "state": effective_state.strip(),
            "season": season.strip(),
            "crop_year": validated_year,
            "farm_area_ha": round(validated_area, 4),
            "predicted_yield_tonnes_per_ha": predicted_yield_tonnes_per_ha,
            "predicted_yield_kg_per_ha": predicted_yield_kg_per_ha,
            "expected_supply_kg": expected_supply_kg,
            "expected_supply_tonnes": expected_supply_tonnes,
            "prediction_source": prediction_source,
            "is_demo_prediction": is_demo_prediction,
            # Backward compatibility aliases for existing services & tests:
            "state_name": effective_state.strip(),
            "area_ha": round(validated_area, 4),
        }

    # Method alias for convenience
    predict = predict_supply
