import json
import math
import urllib.request
import urllib.error


class MarketRoutingService:
    """
    Module 8: GPS + Market Routing Service
    Calculates road distance (km) and driving travel time (hours) between
    farmer and market GPS coordinates using the OpenStreetMap OSRM public routing API.
    """

    DEFAULT_BASE_URL = "https://router.project-osrm.org"
    DEFAULT_TIMEOUT_SECONDS = 10.0

    def __init__(self, base_url: str = DEFAULT_BASE_URL, timeout: float = DEFAULT_TIMEOUT_SECONDS):
        self.base_url = base_url.rstrip("/")
        self.timeout = float(timeout)

    def _validate_coordinate(self, name: str, value: float, is_latitude: bool) -> float:
        """
        Validates individual coordinate type and boundary constraints.
        """
        if isinstance(value, bool):
            raise TypeError(f"Invalid coordinate '{name}': boolean value is not allowed.")
        if not isinstance(value, (int, float)):
            raise TypeError(f"Invalid coordinate '{name}': expected numeric int or float, got {type(value).__name__}.")
        if math.isnan(value):
            raise ValueError(f"Invalid coordinate '{name}': coordinate cannot be NaN.")
        if math.isinf(value):
            raise ValueError(f"Invalid coordinate '{name}': coordinate cannot be infinite.")

        val_float = float(value)
        if is_latitude:
            if not (-90.0 <= val_float <= 90.0):
                raise ValueError(f"Invalid latitude '{name}' ({val_float}): must be between -90 and 90 degrees.")
        else:
            if not (-180.0 <= val_float <= 180.0):
                raise ValueError(f"Invalid longitude '{name}' ({val_float}): must be between -180 and 180 degrees.")

        return val_float

    def get_route(
        self,
        farmer_latitude: float,
        farmer_longitude: float,
        market_latitude: float,
        market_longitude: float,
    ) -> dict:
        """
        Calculates road distance (in km) and travel time (in hours) between farmer and market GPS coordinates.

        OSRM coordinate order: {longitude},{latitude}

        Returns:
            dict: {
                "distance_km": float,
                "travel_time_hours": float
            }
        """
        # 1. Validate all four coordinates
        f_lat = self._validate_coordinate("farmer_latitude", farmer_latitude, is_latitude=True)
        f_lon = self._validate_coordinate("farmer_longitude", farmer_longitude, is_latitude=False)
        m_lat = self._validate_coordinate("market_latitude", market_latitude, is_latitude=True)
        m_lon = self._validate_coordinate("market_longitude", market_longitude, is_latitude=False)

        # 2. Build OSRM route request URL (OSRM uses longitude,latitude order)
        url = f"{self.base_url}/route/v1/driving/{f_lon},{f_lat};{m_lon},{m_lat}?overview=false"

        req = urllib.request.Request(
            url,
            headers={"User-Agent": "FarmToMarket-RoutingService/1.0"}
        )

        # 3. Execute HTTP request
        try:
            with urllib.request.urlopen(req, timeout=self.timeout) as response:
                status_code = getattr(response, "status", 200)
                if status_code != 200:
                    raise RuntimeError(f"OSRM request failed with HTTP status code {status_code}.")
                raw_bytes = response.read()
                raw_text = raw_bytes.decode("utf-8")
        except urllib.error.HTTPError as e:
            raise RuntimeError(f"OSRM HTTP request failed with status {e.code}: {e.reason}") from e
        except urllib.error.URLError as e:
            raise RuntimeError(f"OSRM network connection failed: {e.reason}") from e
        except Exception as e:
            if isinstance(e, (TypeError, ValueError, RuntimeError)):
                raise
            raise RuntimeError(f"Unexpected error during OSRM network request: {e}") from e

        # 4. Parse JSON response
        try:
            payload = json.loads(raw_text)
        except (json.JSONDecodeError, TypeError) as e:
            raise RuntimeError(f"Failed to parse OSRM response as JSON: {e}") from e

        if not isinstance(payload, dict):
            raise RuntimeError("Invalid OSRM response: root JSON must be an object.")

        # 5. Check OSRM response code and presence of routes
        if payload.get("code") != "Ok":
            msg = payload.get("message") or payload.get("code") or "Routing error"
            raise ValueError(f"OSRM routing failed: {msg}")

        routes = payload.get("routes")
        if not isinstance(routes, list) or len(routes) == 0:
            raise ValueError("OSRM response contains no routes.")

        first_route = routes[0]
        if not isinstance(first_route, dict):
            raise ValueError("OSRM route item must be a dictionary.")

        # 6. Extract distance and duration
        if "distance" not in first_route or first_route["distance"] is None:
            raise ValueError("OSRM route is missing 'distance' field.")
        if "duration" not in first_route or first_route["duration"] is None:
            raise ValueError("OSRM route is missing 'duration' field.")

        distance_meters = first_route["distance"]
        duration_seconds = first_route["duration"]

        if not isinstance(distance_meters, (int, float)) or isinstance(distance_meters, bool) or math.isnan(distance_meters):
            raise ValueError(f"Invalid distance value in OSRM response: {distance_meters}")
        if not isinstance(duration_seconds, (int, float)) or isinstance(duration_seconds, bool) or math.isnan(duration_seconds):
            raise ValueError(f"Invalid duration value in OSRM response: {duration_seconds}")

        # 7. Convert distance (m -> km) and duration (s -> hours)
        distance_km = round(float(distance_meters) / 1000.0, 2)
        travel_time_hours = round(float(duration_seconds) / 3600.0, 2)

        return {
            "distance_km": distance_km,
            "travel_time_hours": travel_time_hours
        }

    # Alias for convenience
    calculate_route = get_route
