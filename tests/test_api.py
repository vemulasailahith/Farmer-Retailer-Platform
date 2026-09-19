import io
import json
import os
import sys
import unittest
from unittest.mock import MagicMock

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from fastapi.testclient import TestClient
from main import app, get_recommendation_service


class TestFastAPIApp(unittest.TestCase):

    def setUp(self):
        self.mock_service = MagicMock()
        app.dependency_overrides[get_recommendation_service] = lambda: self.mock_service
        self.client = TestClient(app)

        self.valid_payload = {
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
            "spoilage": {
                "shelf_life_hours": 72.0,
            },
            "farmer_location": {
                "latitude": 16.3067,
                "longitude": 80.4365,
            },
            "markets": [
                {
                    "market": "Guntur Yard",
                    "buyer_name": "Buyer A",
                    "latitude": 16.3000,
                    "longitude": 80.4500,
                    "price_unit": "INR/kg",
                    "price": {
                        "State": "Andhra Pradesh",
                        "District": "Guntur",
                        "Market": "Guntur Yard",
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
                        "Rolling_Mean_7": 3120.0,
                    },
                    "demand": {
                        "demand_kg": 5000.0,
                        "buyer_capacity_kg": 6000.0,
                    },
                    "transport": {
                        "cost_per_km": 30.0,
                    },
                }
            ],
        }

        self.mock_recommendation_result = {
            "supply": {"crop": "rice", "expected_supply_kg": 3769.56},
            "freshness": {"predicted_class": "fresh", "confidence": 0.92},
            "price_unit": "INR/kg",
            "markets": [
                {
                    "market": "Guntur Yard",
                    "buyer_name": "Buyer A",
                    "routing": {"distance_km": 50.0, "travel_time_hours": 1.5},
                    "price": {
                        "commodity": "rice",
                        "market": "Guntur Yard",
                        "prediction_date": "2024-01-01",
                        "current_modal_price": 3200.0,
                        "predicted_future_modal_price": 3244.13,
                        "price_unit_model": "INR/quintal",
                        "predicted_price_per_kg": 32.44,
                        "price_unit": "INR/kg",
                    },
                    "decision": {"net_expected_revenue": 76565.40, "feasibility": "feasible"},
                }
            ],
            "recommendation": {
                "market": "Guntur Yard",
                "buyer_name": "Buyer A",
                "reason": "Highest net expected revenue",
            },
        }

        self.mock_service.recommend.return_value = self.mock_recommendation_result

    def tearDown(self):
        app.dependency_overrides.clear()

    def _get_dummy_image(self):
        return ("produce.jpg", io.BytesIO(b"\xff\xd8\xff\xe0" + b"\x00" * 32), "image/jpeg")

    def test_1_health_check_returns_200(self):
        """Test 1: GET /health returns status code 200 and healthy status."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "healthy"})

    def test_2_valid_recommendation_request_returns_200(self):
        """Test 2: Valid recommendation request returns status 200 and structured recommendation."""
        data_str = json.dumps(self.valid_payload)
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": data_str},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 200)
        json_resp = response.json()
        self.assertIn("recommendation", json_resp)
        self.assertEqual(json_resp["recommendation"]["market"], "Guntur Yard")
        market_price = json_resp["markets"][0]["price"]
        self.assertEqual(market_price["predicted_future_modal_price"], 3244.13)
        self.assertEqual(market_price["predicted_price_per_kg"], 32.44)
        self.assertEqual(market_price["price_unit_model"], "INR/quintal")
        self.assertEqual(market_price["price_unit"], "INR/kg")

    def test_3_missing_data_returns_422(self):
        """Test 3: Missing 'data' form field returns HTTP 422."""
        response = self.client.post(
            "/api/v1/recommend",
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 422)

    def test_4_missing_image_returns_422(self):
        """Test 4: Missing 'image' upload file returns HTTP 422."""
        data_str = json.dumps(self.valid_payload)
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": data_str},
        )
        self.assertEqual(response.status_code, 422)

    def test_5_malformed_json_in_data_returns_422(self):
        """Test 5: Malformed JSON string in 'data' returns HTTP 422."""
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": "{invalid_json: 123"},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 422)
        self.assertIn("Malformed JSON", response.json()["detail"])

    def test_6_invalid_structured_input_returns_422(self):
        """Test 6: Missing required supply fields in payload returns HTTP 422."""
        bad_payload = dict(self.valid_payload)
        bad_payload["supply"] = {"crop": "rice"}  # Missing 13 required supply fields
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": json.dumps(bad_payload)},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 422)

    def test_7_module_9_validation_failure_mapped_to_422(self):
        """Test 7: Module 9 ValueError is mapped to HTTP 422 with message preserved."""
        self.mock_service.recommend.side_effect = ValueError("Missing required price_unit")
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": json.dumps(self.valid_payload)},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 422)
        self.assertIn("Missing required price_unit", response.json()["detail"])

    def test_8_unexpected_service_failure_returns_500(self):
        """Test 8: Unexpected service failure (RuntimeError) returns HTTP 500 without stack trace."""
        self.mock_service.recommend.side_effect = RuntimeError("Routing failed for market 'Guntur Yard'")
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": json.dumps(self.valid_payload)},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 500)
        self.assertIn("Routing failed for market 'Guntur Yard'", response.json()["detail"])

    def test_9_uploaded_image_path_passed_to_freshness(self):
        """Test 9: Temporary file path of the uploaded image is injected into freshness.image_path."""
        passed_image_path = None

        def capture_call(payload):
            nonlocal passed_image_path
            passed_image_path = payload.get("freshness", {}).get("image_path")
            return self.mock_recommendation_result

        self.mock_service.recommend.side_effect = capture_call

        response = self.client.post(
            "/api/v1/recommend",
            data={"data": json.dumps(self.valid_payload)},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 200)
        self.assertIsNotNone(passed_image_path)
        self.assertTrue(isinstance(passed_image_path, str))
        self.assertTrue(passed_image_path.endswith(".jpg"))

    def test_10_temporary_uploaded_image_cleaned_up_after_processing(self):
        """Test 10: Temporary image file is completely deleted after request finishes."""
        captured_path = None

        def capture_call(payload):
            nonlocal captured_path
            captured_path = payload["freshness"]["image_path"]
            # During processing, the temporary file must exist
            self.assertTrue(os.path.exists(captured_path))
            return self.mock_recommendation_result

        self.mock_service.recommend.side_effect = capture_call

        response = self.client.post(
            "/api/v1/recommend",
            data={"data": json.dumps(self.valid_payload)},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 200)
        # After processing, temporary file must be cleaned up
        self.assertIsNotNone(captured_path)
        self.assertFalse(os.path.exists(captured_path))

    def test_11_module_9_called_exactly_once(self):
        """Test 11: Module 9 recommendation service is invoked exactly once for a valid request."""
        response = self.client.post(
            "/api/v1/recommend",
            data={"data": json.dumps(self.valid_payload)},
            files={"image": self._get_dummy_image()},
        )
        self.assertEqual(response.status_code, 200)
        self.mock_service.recommend.assert_called_once()

    def test_12_cors_middleware_configured(self):
        """Test 12: CORS middleware is configured with allow_origins=['*'] and allow_credentials=False."""
        # Check user middleware registrations on the FastAPI app
        cors_found = False
        for middleware in app.user_middleware:
            cls_name = getattr(middleware.cls, "__name__", "")
            if cls_name == "CORSMiddleware":
                cors_found = True
                kwargs = getattr(middleware, "kwargs", None) or getattr(middleware, "options", {})
                self.assertIn("*", kwargs.get("allow_origins", []))
                self.assertFalse(kwargs.get("allow_credentials", True))
                break
        self.assertTrue(cors_found, "CORSMiddleware must be configured on app.")


if __name__ == "__main__":
    unittest.main()
