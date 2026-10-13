import os
import joblib
import pandas as pd


def _safe_joblib_load(file_path):
    """
    Loads joblib serialized models with backward/forward compatibility shims
    for NumPy 1.x / 2.x BitGenerator and PCG64 state unpickling.
    """
    import pickle
    import numpy.random._pickle as np_pickle
    import numpy.random.bit_generator as bg
    from numpy.random import Generator

    orig_bg_ctor = getattr(np_pickle, "__bit_generator_ctor", None)
    orig_gen_ctor = getattr(np_pickle, "__generator_ctor", None)
    orig_load_build = pickle._Unpickler.load_build

    def patched_bg_ctor(name="MT19937"):
        if isinstance(name, bg.BitGenerator):
            return name
        if isinstance(name, type) and issubclass(name, bg.BitGenerator):
            return name()
        if isinstance(name, str) and name in np_pickle.BitGenerators:
            return np_pickle.BitGenerators[name]()
        if orig_bg_ctor:
            return orig_bg_ctor(name)
        raise ValueError(f"Unknown BitGenerator: {name}")

    def patched_gen_ctor(bit_generator_name="MT19937", bit_generator_ctor=patched_bg_ctor):
        if isinstance(bit_generator_name, bg.BitGenerator):
            return Generator(bit_generator_name)
        return Generator(bit_generator_ctor(bit_generator_name))

    def patched_load_build(self):
        inst = self.stack[-2]
        state = self.stack[-1]
        if isinstance(inst, bg.BitGenerator) and isinstance(state, tuple):
            self.stack[-1] = state[0]
        return orig_load_build(self)

    try:
        np_pickle.__bit_generator_ctor = patched_bg_ctor
        np_pickle.__generator_ctor = patched_gen_ctor
        pickle._Unpickler.load_build = patched_load_build
        return joblib.load(file_path)
    finally:
        if orig_bg_ctor:
            np_pickle.__bit_generator_ctor = orig_bg_ctor
        if orig_gen_ctor:
            np_pickle.__generator_ctor = orig_gen_ctor
        pickle._Unpickler.load_build = orig_load_build


class PricePredictionService:
    def __init__(self):
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

        model_path = os.path.join(
            base_dir,
            "models",
            "farm_price_prediction_model.pkl"
        )

        preprocessing_path = os.path.join(
            base_dir,
            "models",
            "price_preprocessing.pkl"
        )

        if not os.path.exists(model_path):
            raise FileNotFoundError(
                f"Price model not found: {model_path}"
            )

        if not os.path.exists(preprocessing_path):
            raise FileNotFoundError(
                f"Price preprocessing artifact not found: {preprocessing_path}"
            )

        self.model = _safe_joblib_load(model_path)
        self.preprocessing = joblib.load(preprocessing_path)

        self.categorical_features = self.preprocessing[
            "categorical_features"
        ]

        self.numerical_features = self.preprocessing[
            "numerical_features"
        ]

        self.model_features = self.preprocessing[
            "model_features"
        ]

        self.frequency_mappings = self.preprocessing[
            "frequency_mappings"
        ]

    def _validate_input(self, data):
        required_fields = [
            "State",
            "District",
            "Market",
            "Commodity",
            "Variety",
            "Grade",
            "Commodity_Code",
            "Date",
            "Min_Price",
            "Max_Price",
            "Modal_Price",
            "Previous_Price",
            "Rolling_Mean_3",
            "Rolling_Mean_7",
        ]

        missing_fields = [
            field for field in required_fields
            if field not in data
        ]

        if missing_fields:
            raise ValueError(
                f"Missing required fields: {missing_fields}"
            )

    def _frequency_encode(self, data):
        encoded = {}

        for column in self.categorical_features:
            value = data[column]

            encoded[column + "_freq"] = (
                self.frequency_mappings[column]
                .get(value, 0.0)
            )

        return encoded

    def _create_features(self, data):
        date = pd.to_datetime(data["Date"], errors="raise")

        features = {
            "Commodity_Code": float(data["Commodity_Code"]),

            "Year": int(date.year),
            "Month": int(date.month),
            "Day": int(date.day),
            "DayOfWeek": int(date.dayofweek),
            "WeekOfYear": int(date.isocalendar().week),
            "Quarter": int(date.quarter),

            "Min_Price": float(data["Min_Price"]),
            "Max_Price": float(data["Max_Price"]),
            "Modal_Price": float(data["Modal_Price"]),

            "Previous_Price": float(data["Previous_Price"]),

            "Price_Change": (
                float(data["Modal_Price"])
                - float(data["Previous_Price"])
            ),

            "Rolling_Mean_3": float(data["Rolling_Mean_3"]),
            "Rolling_Mean_7": float(data["Rolling_Mean_7"]),
        }

        frequency_features = self._frequency_encode(data)

        features.update(frequency_features)

        return features

    def predict(self, data):
        self._validate_input(data)

        features = self._create_features(data)

        # Ensure exact feature order used during model training
        input_df = pd.DataFrame(
            [[features[column] for column in self.model_features]],
            columns=self.model_features
        )

        prediction = self.model.predict(input_df)[0]

        predicted_price_per_kg = float(prediction) / 100.0

        return {
            "commodity": data["Commodity"],
            "market": data["Market"],
            "prediction_date": str(data["Date"]),
            "current_modal_price": round(float(data["Modal_Price"]), 2),
            "predicted_future_modal_price": round(float(prediction), 2),
            "price_unit_model": "INR/quintal",
            "predicted_price_per_kg": round(predicted_price_per_kg, 2),
            "price_unit": "INR/kg",
        }

