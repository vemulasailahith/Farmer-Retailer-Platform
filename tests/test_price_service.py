import unittest

from services.price_service import PricePredictionService


class TestPricePredictionService(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.service = PricePredictionService()

    def test_model_loaded(self):
        self.assertIsNotNone(self.service.model)
        self.assertEqual(len(self.service.model_features), 20)

    def test_frequency_mappings_loaded(self):
        mappings = self.service.frequency_mappings

        expected = [
            "State",
            "District",
            "Market",
            "Commodity",
            "Variety",
            "Grade",
        ]

        for column in expected:
            self.assertIn(column, mappings)
            self.assertGreater(len(mappings[column]), 0)

    def test_prediction(self):
        data = {
            "State": "Tamil Nadu",
            "District": "Salem",
            "Market": "Ammapet (Uzhavar Sandhai )",
            "Commodity": "Onion",
            "Variety": "Other",
            "Grade": "FAQ",
            "Commodity_Code": 82,
            "Date": "2025-09-01",
            "Min_Price": 3000.0,
            "Max_Price": 3500.0,
            "Modal_Price": 3300.0,
            "Previous_Price": 3250.0,
            "Rolling_Mean_3": 3283.33,
            "Rolling_Mean_7": 3310.71,
        }

        result = self.service.predict(data)

        self.assertIn(
            "predicted_future_modal_price",
            result
        )

        self.assertIsInstance(
            result["predicted_future_modal_price"],
            float
        )

        self.assertGreater(
            result["predicted_future_modal_price"],
            0
        )

        self.assertEqual(result["price_unit_model"], "INR/quintal")
        self.assertEqual(result["price_unit"], "INR/kg")
        self.assertIn("predicted_price_per_kg", result)
        self.assertAlmostEqual(
            result["predicted_price_per_kg"],
            result["predicted_future_modal_price"] / 100.0,
            places=2,
        )


if __name__ == "__main__":
    unittest.main()
