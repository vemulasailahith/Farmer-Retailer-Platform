import json
import os
import shutil
import tempfile
from typing import Any, Dict, List, Optional

from fastapi import Depends, FastAPI, File, Form, HTTPException, UploadFile, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, ConfigDict, ValidationError

from services.recommendation_service import FarmToMarketRecommendationService

app = FastAPI(title="Farm-to-Market Recommendation API", version="1.0.0")

# CORS middleware for Flutter application access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Reusable / Singleton Service Dependency
# ---------------------------------------------------------------------------
_recommendation_service_instance: Optional[FarmToMarketRecommendationService] = None


def get_recommendation_service() -> FarmToMarketRecommendationService:
    """Provides a reusable singleton instance of the recommendation service."""
    global _recommendation_service_instance
    if _recommendation_service_instance is None:
        _recommendation_service_instance = FarmToMarketRecommendationService()
    return _recommendation_service_instance


# ---------------------------------------------------------------------------
# Pydantic Request Validation Models
# ---------------------------------------------------------------------------
class SupplyPayload(BaseModel):
    model_config = ConfigDict(extra="allow")

    state_name: str
    dist_name: str
    crop: str
    area_ha: float
    year: int
    n_req_kg_per_ha: float
    p_req_kg_per_ha: float
    k_req_kg_per_ha: float
    temperature_c: float
    humidity_percent: float
    ph: float
    rainfall_mm: float
    wind_speed_m_s: float
    solar_radiation_mj_m2_day: float
    season: Optional[str] = "Whole Year"
    fertilizer: Optional[float] = 0.0
    pesticide: Optional[float] = 0.0
    max_temperature: Optional[float] = None
    min_temperature: Optional[float] = None


class FarmerLocationPayload(BaseModel):
    latitude: float
    longitude: float


class DemandPayload(BaseModel):
    demand_kg: float
    buyer_capacity_kg: float
    current_supply_kg: Optional[float] = None
    commodity: Optional[str] = None


class TransportPayload(BaseModel):
    cost_per_km: float = 30.0


class MarketItemPayload(BaseModel):
    market: str
    buyer_name: str
    latitude: float
    longitude: float
    price_unit: Optional[str] = None
    price: Optional[Dict[str, Any]] = None
    demand: DemandPayload
    transport: Optional[TransportPayload] = None
    shelf_life_hours: Optional[float] = None
    temperature_c: Optional[float] = None
    humidity_percent: Optional[float] = None


class SpoilagePayload(BaseModel):
    shelf_life_hours: Optional[float] = None
    temperature_c: Optional[float] = None
    humidity_percent: Optional[float] = None


class FreshnessPayload(BaseModel):
    image_path: Optional[str] = None
    shelf_life_hours: Optional[float] = None


class RecommendationRequestPayload(BaseModel):
    price_unit: Optional[str] = None
    supply: SupplyPayload
    farmer_location: FarmerLocationPayload
    freshness: Optional[FreshnessPayload] = None
    spoilage: Optional[SpoilagePayload] = None
    price: Optional[Dict[str, Any]] = None
    markets: List[MarketItemPayload]


# ---------------------------------------------------------------------------
# Endpoints
# ---------------------------------------------------------------------------
@app.get("/", status_code=status.HTTP_200_OK)
def root() -> Dict[str, Any]:
    """Root status endpoint providing API discovery and interactive documentation links."""
    return {
        "project": "Farm-to-Market Recommendation API",
        "status": "online",
        "version": "1.0.0",
        "docs_url": "/docs",
        "health_url": "/health",
        "endpoints": {
            "root": "GET /",
            "health": "GET /health",
            "recommend": "POST /api/v1/recommend",
            "interactive_docs": "GET /docs",
            "redoc": "GET /redoc",
            "openapi": "GET /openapi.json",
        },
    }


@app.get("/health", status_code=status.HTTP_200_OK)
def health_check() -> Dict[str, str]:
    """Health check endpoint for container and client status verification."""
    return {"status": "healthy"}


@app.post("/api/v1/recommend", status_code=status.HTTP_200_OK)
async def recommend(
    data: str = Form(...),
    image: UploadFile = File(...),
    service: FarmToMarketRecommendationService = Depends(get_recommendation_service),
) -> JSONResponse:
    """
    Orchestrates end-to-end market recommendation:
    1. Parses JSON form field 'data'
    2. Validates payload via Pydantic
    3. Saves uploaded produce image to safe temporary file
    4. Injects temporary file path into data['freshness']['image_path']
    5. Calls FarmToMarketRecommendationService.recommend()
    6. Always deletes temporary file in finally block
    """
    # 1. Parse JSON string
    try:
        raw_dict = json.loads(data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Malformed JSON in 'data' field: {str(e)}",
        )

    if not isinstance(raw_dict, dict):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="'data' field must contain a JSON object.",
        )

    # 2. Validate structured payload with Pydantic
    try:
        validated_payload = RecommendationRequestPayload.model_validate(raw_dict)
        payload_dict = validated_payload.model_dump()
    except ValidationError as e:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Request validation error: {str(e)}",
        )

    # 3. Handle temporary image storage
    temp_image_path = None
    try:
        original_ext = os.path.splitext(image.filename or ".jpg")[1] or ".jpg"
        with tempfile.NamedTemporaryFile(delete=False, suffix=original_ext) as temp_file:
            temp_image_path = temp_file.name
            shutil.copyfileobj(image.file, temp_file)

        # 4. Inject image path into freshness structure
        if "freshness" not in payload_dict or payload_dict["freshness"] is None:
            payload_dict["freshness"] = {}
        payload_dict["freshness"]["image_path"] = temp_image_path

        # 5. Call Module 9 Recommendation Service
        try:
            result = service.recommend(payload_dict)
            return JSONResponse(status_code=status.HTTP_200_OK, content=result)
        except (ValueError, TypeError) as e:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=str(e),
            )
        except RuntimeError as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=str(e),
            )
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Unexpected recommendation failure: {str(e)}",
            )

    finally:
        # 6. Ensure temporary image file is always cleaned up
        if temp_image_path and os.path.exists(temp_image_path):
            try:
                os.remove(temp_image_path)
            except OSError:
                pass
