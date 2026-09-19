import math
import os
import sys
import unittest
from unittest.mock import MagicMock

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.supply_service import SupplyPredictionService


class TestSupplyPredictionService(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.models_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "models"))
        cls.model_path = os.path.join(cls.models_dir, "crop_yield_model.pkl")

        if os.path.exists(cls.model_path):
            cls.real_service = SupplyPredictionService(models_dir=cls.models_dir)
        else:
            cls.real_service = None

    def setUp(self):
        # Create deterministic mock service for isolating conversions and tests
        self.mock_model = MagicMock()
        self.mock_model.predict.return_value = [7.5]  # ML prediction: 7.5 tonnes/ha
        self.mock_service = SupplyPredictionService(model=self.mock_model)

    def test_1_model_loads_successfully(self):
        """Test 1: Verify real ML model loads successfully from models/crop_yield_model.pkl."""
        self.assertIsNotNone(self.real_service, "Real model file 'crop_yield_model.pkl' not found.")
        self.assertIsNotNone(self.real_service.model, "Model attribute is None.")
        self.assertTrue(hasattr(self.real_service.model, "predict"), "Loaded model has no 'predict' method.")

        # Verify FileNotFoundError when models_dir does not contain model
        with self.assertRaises(FileNotFoundError):
            SupplyPredictionService(models_dir="non_existent_dir_12345")

    def test_2_potato_uses_ml_model(self):
        """Test 2: Verify Potato still uses the real ML model."""
        service = self.real_service or self.mock_service
        result = service.predict_supply(
            crop="Potato",
            season="Rabi",
            state="Uttar Pradesh",
            crop_year=2020,
            area_ha=5.0,
            annual_rainfall=850.0,
            fertilizer=150.0,
            pesticide=2.5,
            avg_temperature=22.0,
            max_temperature=28.0,
            min_temperature=16.0,
        )

        self.assertEqual(result["crop"], "Potato")
        self.assertEqual(result["prediction_source"], "ml_model")
        self.assertFalse(result["is_demo_prediction"])
        self.assertGreater(result["predicted_yield_tonnes_per_ha"], 0.0)
        self.assertAlmostEqual(
            result["predicted_yield_kg_per_ha"],
            result["predicted_yield_tonnes_per_ha"] * 1000.0,
            places=2,
        )
        self.assertAlmostEqual(
            result["expected_supply_kg"],
            result["predicted_yield_tonnes_per_ha"] * 5.0 * 1000.0,
            places=2,
        )

    def test_3_onion_uses_ml_model(self):
        """Test 3: Verify Onion still uses the real ML model."""
        service = self.real_service or self.mock_service
        result = service.predict_supply(
            crop="Onion",
            season="Rabi",
            state="Maharashtra",
            crop_year=2020,
            area_ha=5.0,
            annual_rainfall=750.0,
            fertilizer=100.0,
            pesticide=1.5,
            avg_temperature=24.0,
            max_temperature=30.0,
            min_temperature=18.0,
        )

        self.assertEqual(result["crop"], "Onion")
        self.assertEqual(result["prediction_source"], "ml_model")
        self.assertFalse(result["is_demo_prediction"])
        self.assertGreater(result["predicted_yield_tonnes_per_ha"], 0.0)

    def test_4_tomato_succeeds_using_demo_fallback(self):
        """Test 4: Verify Tomato now succeeds using demo_fallback and does not call ML model."""
        result = self.mock_service.predict_supply(
            crop="Tomato",
            season="Rabi",
            state="Andhra Pradesh",
            crop_year=2024,
            area_ha=2.5,
            annual_rainfall=800.0,
            avg_temperature=26.0,
        )

        self.assertEqual(result["crop"], "Tomato")
        self.assertEqual(result["prediction_source"], "demo_fallback")
        self.assertTrue(result["is_demo_prediction"])
        self.assertEqual(result["predicted_yield_tonnes_per_ha"], 20.0)
        self.assertEqual(result["predicted_yield_kg_per_ha"], 20000.0)
        # Expected supply: 20 * 2.5 * 1000 = 50000 kg
        self.assertEqual(result["expected_supply_kg"], 50000.0)
        self.assertEqual(result["expected_supply_tonnes"], 50.0)
        self.mock_model.predict.assert_not_called()

    def test_5_brinjal_succeeds_using_demo_fallback(self):
        """Test 5: Verify Brinjal now succeeds using demo_fallback and does not call ML model."""
        result = self.mock_service.predict_supply(
            crop="Brinjal",
            season="Kharif",
            state="Telangana",
            crop_year=2024,
            area_ha=3.0,
            annual_rainfall=900.0,
            avg_temperature=28.0,
        )

        self.assertEqual(result["crop"], "Brinjal")
        self.assertEqual(result["prediction_source"], "demo_fallback")
        self.assertTrue(result["is_demo_prediction"])
        self.assertEqual(result["predicted_yield_tonnes_per_ha"], 18.0)
        self.assertEqual(result["predicted_yield_kg_per_ha"], 18000.0)
        # Expected supply: 18 * 3.0 * 1000 = 54000 kg
        self.assertEqual(result["expected_supply_kg"], 54000.0)
        self.assertEqual(result["expected_supply_tonnes"], 54.0)
        self.mock_model.predict.assert_not_called()

    def test_6_all_unsupported_flutter_vegetables_produce_results(self):
        """Test 6: Verify all Flutter unsupported vegetables produce expected deterministic demo values."""
        expected_demo_yields = {
            "Tomato": 20.0,
            "Brinjal": 18.0,
            "Bhindi": 10.0,
            "Bottle Gourd": 15.0,
            "Bitter Gourd": 12.0,
            "Ridge Gourd": 13.0,
            "Snake Gourd": 14.0,
            "Cabbage": 25.0,
            "Cauliflower": 20.0,
            "Carrot": 18.0,
            "Spinach": 12.0,
            "Capsicum": 15.0,
            "Green Chilli": 10.0,
        }

        for veg_name, expected_tonnes in expected_demo_yields.items():
            result = self.mock_service.predict_supply(
                crop=veg_name,
                season="Whole Year",
                state="Andhra Pradesh",
                crop_year=2024,
                area_ha=1.0,
                annual_rainfall=750.0,
                avg_temperature=25.0,
            )

            self.assertEqual(
                result["predicted_yield_tonnes_per_ha"],
                expected_tonnes,
                f"Mismatch for {veg_name}",
            )
            self.assertEqual(result["prediction_source"], "demo_fallback")
            self.assertTrue(result["is_demo_prediction"])
            self.assertEqual(result["expected_supply_tonnes"], expected_tonnes)
            self.assertEqual(result["expected_supply_kg"], expected_tonnes * 1000.0)

    def test_7_fallback_values_are_deterministic(self):
        """Test 7: Verify fallback yield does not randomly change between requests."""
        results = [
            self.mock_service.predict_supply(
                crop="Tomato",
                season="Rabi",
                state="Andhra Pradesh",
                crop_year=2024,
                area_ha=4.0,
                annual_rainfall=800.0,
                avg_temperature=25.0,
            )
            for _ in range(5)
        ]

        first_yield = results[0]["predicted_yield_tonnes_per_ha"]
        first_kg = results[0]["expected_supply_kg"]
        for res in results:
            self.assertEqual(res["predicted_yield_tonnes_per_ha"], first_yield)
            self.assertEqual(res["expected_supply_kg"], first_kg)

    def test_8_fallback_supply_calculation_is_correct(self):
        """Test 8: Verify calculation formulas for fallback crops: yield_kg, supply_kg, supply_tonnes."""
        test_area = 3.5
        result = self.mock_service.predict_supply(
            crop="Cabbage",  # 25.0 tonnes/ha
            season="Winter",
            state="Punjab",
            crop_year=2023,
            area_ha=test_area,
            annual_rainfall=500.0,
            avg_temperature=18.0,
        )

        expected_yield_tonnes = 25.0
        expected_yield_kg = expected_yield_tonnes * 1000.0
        expected_supply_kg = expected_yield_tonnes * test_area * 1000.0
        expected_supply_tonnes = expected_yield_tonnes * test_area

        self.assertEqual(result["predicted_yield_tonnes_per_ha"], expected_yield_tonnes)
        self.assertEqual(result["predicted_yield_kg_per_ha"], expected_yield_kg)
        self.assertEqual(result["expected_supply_kg"], expected_supply_kg)
        self.assertEqual(result["expected_supply_tonnes"], expected_supply_tonnes)

    def test_9_completely_unsupported_crop_rejected(self):
        """Test 9: Verify a crop that is neither in ML dataset nor Flutter fallback list is rejected."""
        with self.assertRaises(ValueError) as ctx:
            self.mock_service.predict_supply(
                crop="Dragon Fruit",
                season="Rabi",
                state="Andhra Pradesh",
                crop_year=2024,
                area_ha=2.0,
                annual_rainfall=800.0,
                avg_temperature=25.0,
            )
        self.assertIn("Yield prediction is not available for crop: Dragon Fruit", str(ctx.exception))

    def test_10_empty_crop_rejected(self):
        """Test 10: Verify empty or whitespace-only crop raises ValueError."""
        for empty_val in ["", "   ", "\t\n"]:
            with self.assertRaises(ValueError):
                self.mock_service.predict_supply(
                    crop=empty_val,
                    season="Rabi",
                    state="Uttar Pradesh",
                    crop_year=2020,
                    area_ha=5.0,
                    annual_rainfall=800.0,
                    avg_temperature=22.0,
                )

    def test_11_invalid_area_rejected(self):
        """Test 11: Verify invalid area (<= 0, boolean, non-numeric) is rejected."""
        for bad_area in [0.0, -1.0, -100.0]:
            with self.assertRaises(ValueError):
                self.mock_service.predict_supply(
                    crop="Tomato",
                    season="Rabi",
                    state="Uttar Pradesh",
                    crop_year=2020,
                    area_ha=bad_area,
                    annual_rainfall=800.0,
                    avg_temperature=22.0,
                )

        for bad_type in [True, False, "not_a_number", None]:
            with self.assertRaises((TypeError, ValueError)):
                self.mock_service.predict_supply(
                    crop="Tomato",
                    season="Rabi",
                    state="Uttar Pradesh",
                    crop_year=2020,
                    area_ha=bad_type,
                    annual_rainfall=800.0,
                    avg_temperature=22.0,
                )

    def test_12_invalid_numeric_values_rejected(self):
        """Test 12: Verify NaN, infinity, negative values, and non-numeric inputs are rejected."""
        # NaN rainfall
        with self.assertRaises(ValueError):
            self.mock_service.predict_supply(
                crop="Tomato",
                season="Rabi",
                state="Uttar Pradesh",
                crop_year=2020,
                area_ha=5.0,
                annual_rainfall=float("nan"),
                avg_temperature=22.0,
            )

        # Infinity fertilizer
        with self.assertRaises(ValueError):
            self.mock_service.predict_supply(
                crop="Tomato",
                season="Rabi",
                state="Uttar Pradesh",
                crop_year=2020,
                area_ha=5.0,
                annual_rainfall=800.0,
                fertilizer=float("inf"),
                avg_temperature=22.0,
            )

        # Negative rainfall
        with self.assertRaises(ValueError):
            self.mock_service.predict_supply(
                crop="Tomato",
                season="Rabi",
                state="Uttar Pradesh",
                crop_year=2020,
                area_ha=5.0,
                annual_rainfall=-50.0,
                avg_temperature=22.0,
            )

        # Boolean passed as crop_year
        with self.assertRaises(TypeError):
            self.mock_service.predict_supply(
                crop="Tomato",
                season="Rabi",
                state="Uttar Pradesh",
                crop_year=True,
                area_ha=5.0,
                annual_rainfall=800.0,
                avg_temperature=22.0,
            )


if __name__ == "__main__":
    unittest.main()
