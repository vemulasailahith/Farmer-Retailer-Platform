import io
import json
import math
import os
import sys
import unittest
from unittest.mock import MagicMock, patch
import urllib.error

# Ensure project root is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from services.routing_service import MarketRoutingService


def _create_mock_response(status=200, json_dict=None, raw_bytes=None):
    """Helper to generate a mock HTTP response context manager."""
    if raw_bytes is None:
        raw_bytes = json.dumps(json_dict).encode("utf-8")
    mock_resp = MagicMock()
    mock_resp.status = status
    mock_resp.read.return_value = raw_bytes
    mock_resp.__enter__.return_value = mock_resp
    mock_resp.__exit__.return_value = None
    return mock_resp


class TestMarketRoutingService(unittest.TestCase):

    def setUp(self):
        self.service = MarketRoutingService()
        self.farmer_lat = 16.3067
        self.farmer_lon = 80.4365
        self.market_lat = 16.5062
        self.market_lon = 80.6480

    @patch("urllib.request.urlopen")
    def test_1_valid_route_response(self, mock_urlopen):
        """Test 1: Valid route response converts to expected distance and travel time."""
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "Ok",
            "routes": [
                {
                    "distance": 120000,
                    "duration": 12600
                }
            ]
        })

        result = self.service.get_route(
            farmer_latitude=self.farmer_lat,
            farmer_longitude=self.farmer_lon,
            market_latitude=self.market_lat,
            market_longitude=self.market_lon
        )

        self.assertIsInstance(result, dict)
        self.assertEqual(result["distance_km"], 120.0)
        self.assertEqual(result["travel_time_hours"], 3.5)

        # Verify correct OSRM URL format: lon1,lat1;lon2,lat2
        called_req = mock_urlopen.call_args[0][0]
        expected_coords = f"{self.farmer_lon},{self.farmer_lat};{self.market_lon},{self.market_lat}?overview=false"
        self.assertIn(expected_coords, called_req.full_url)

    @patch("urllib.request.urlopen")
    def test_2_distance_conversion_meters_to_km(self, mock_urlopen):
        """Test 2: Verify meters-to-kilometers conversion (8420.5 m -> 8.42 km)."""
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "Ok",
            "routes": [
                {
                    "distance": 8420.5,
                    "duration": 3600
                }
            ]
        })

        result = self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)
        self.assertEqual(result["distance_km"], 8.42)

    @patch("urllib.request.urlopen")
    def test_3_duration_conversion_seconds_to_hours(self, mock_urlopen):
        """Test 3: Verify seconds-to-hours conversion (1150.2 s -> 0.32 h)."""
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "Ok",
            "routes": [
                {
                    "distance": 5000,
                    "duration": 1150.2
                }
            ]
        })

        result = self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)
        self.assertEqual(result["travel_time_hours"], 0.32)

    def test_4_invalid_latitude_greater_than_90(self):
        """Test 4: Invalid latitude greater than 90 raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.get_route(90.1, self.farmer_lon, self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, 95.0, self.market_lon)

    def test_5_invalid_latitude_less_than_minus_90(self):
        """Test 5: Invalid latitude less than -90 raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.get_route(-90.01, self.farmer_lon, self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, -91.0, self.market_lon)

    def test_6_invalid_longitude_greater_than_180(self):
        """Test 6: Invalid longitude greater than 180 raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, 180.1, self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, 181.0)

    def test_7_invalid_longitude_less_than_minus_180(self):
        """Test 7: Invalid longitude less than -180 raises ValueError."""
        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, -180.1, self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, -185.0)

    def test_8_boolean_coordinate_rejection(self):
        """Test 8: Boolean coordinate values are rejected with TypeError."""
        with self.assertRaises(TypeError):
            self.service.get_route(True, self.farmer_lon, self.market_lat, self.market_lon)

        with self.assertRaises(TypeError):
            self.service.get_route(self.farmer_lat, False, self.market_lat, self.market_lon)

        with self.assertRaises(TypeError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, True, self.market_lon)

        with self.assertRaises(TypeError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, False)

    def test_9_nan_coordinate_rejection(self):
        """Test 9: NaN coordinate values are rejected with ValueError."""
        with self.assertRaises(ValueError):
            self.service.get_route(float("nan"), self.farmer_lon, self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, float("nan"), self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, float("nan"), self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, float("nan"))

    def test_10_infinite_coordinate_rejection(self):
        """Test 10: Infinite coordinate values are rejected with ValueError."""
        with self.assertRaises(ValueError):
            self.service.get_route(float("inf"), self.farmer_lon, self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, float("-inf"), self.market_lat, self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, float("inf"), self.market_lon)

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, float("-inf"))

    @patch("urllib.request.urlopen")
    def test_11_osrm_network_request_failure(self, mock_urlopen):
        """Test 11: Network connection failure or HTTP error raises clear RuntimeError."""
        mock_urlopen.side_effect = urllib.error.URLError("Network unreachable")

        with self.assertRaises(RuntimeError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)

        mock_urlopen.side_effect = urllib.error.HTTPError(
            url="https://router.project-osrm.org",
            code=500,
            msg="Internal Server Error",
            hdrs={},
            fp=io.BytesIO(b"Server Error")
        )

        with self.assertRaises(RuntimeError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)

    @patch("urllib.request.urlopen")
    def test_12_osrm_returns_non_ok_status_code(self, mock_urlopen):
        """Test 12: OSRM response where code != 'Ok' raises ValueError."""
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "NoRoute",
            "message": "Impossible route between points",
            "routes": []
        })

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)

    @patch("urllib.request.urlopen")
    def test_13_osrm_returns_empty_routes_list(self, mock_urlopen):
        """Test 13: OSRM returns code 'Ok' but empty routes list raises ValueError."""
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "Ok",
            "routes": []
        })

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)

    @patch("urllib.request.urlopen")
    def test_14_osrm_response_missing_distance_or_duration(self, mock_urlopen):
        """Test 14: OSRM response route missing distance or duration raises ValueError."""
        # Missing duration
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "Ok",
            "routes": [{"distance": 10000}]
        })

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)

        # Missing distance
        mock_urlopen.return_value = _create_mock_response(json_dict={
            "code": "Ok",
            "routes": [{"duration": 600}]
        })

        with self.assertRaises(ValueError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)

    @patch("urllib.request.urlopen")
    def test_15_malformed_json_response(self, mock_urlopen):
        """Test 15: Malformed or invalid JSON response from OSRM raises RuntimeError."""
        mock_urlopen.return_value = _create_mock_response(raw_bytes=b"{invalid-json")

        with self.assertRaises(RuntimeError):
            self.service.get_route(self.farmer_lat, self.farmer_lon, self.market_lat, self.market_lon)


if __name__ == "__main__":
    unittest.main()

