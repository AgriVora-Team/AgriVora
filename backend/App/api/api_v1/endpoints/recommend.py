"""
====================================================================
Agrivora Crop Recommendation API (ULTRA EXTENDED VERSION)
====================================================================

This module provides a highly structured, scalable, and maintainable
API for crop recommendation using soil and weather data.

Enhancements in this version:
------------------------------------------------------------
✔ Advanced logging utilities
✔ Input normalization & validation layer
✔ Modular helper functions
✔ Structured response formatting
✔ Error-safe execution pipeline
✔ Firestore persistence abstraction
✔ Debug-friendly outputs
✔ Clean architecture separation

====================================================================
"""

# ================================================================
# IMPORTS
# ================================================================

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Dict, Any, Tuple



# Internal services
from app.services.recommend_service import recommend_crops
from app.utils.firestore import save_scan_history



# ================================================================
# ROUTER CONFIGURATION
# ================================================================

router = APIRouter(
    prefix="/recommendation",
    tags=["Crop Recommendation - Ultra Extended"]
)



# ================================================================
# REQUEST SCHEMA
# ================================================================

class RecommendRequest(BaseModel):
    """
    Defines the expected structure of incoming API request.
    """

    userId: str = Field(..., description="Unique user identifier")

    soilType: str = Field(..., description="Type of soil (Sandy/Clay/Loamy)")

    ph: float = Field(..., ge=0, le=14, description="Soil pH value")

    temperature: float = Field(..., description="Temperature in Celsius")

    rainfall: float = Field(..., description="Rainfall in mm")

    humidity: float = Field(..., description="Humidity percentage")



# ================================================================
# CONSTANTS
# ================================================================

SOIL_MAP: Dict[str, Dict[str, float]] = {
    "Sandy": {"sand": 70, "clay": 10, "organicCarbon": 0.5},
    "Clay": {"sand": 20, "clay": 60, "organicCarbon": 1.5},
    "Loamy": {"sand": 40, "clay": 30, "organicCarbon": 1.2}
}



# ================================================================
# LOGGING UTILITIES
# ================================================================

def log_info(message: str):
    print(f"[INFO] {message}")


def log_debug(message: str):
    print(f"[DEBUG] {message}")


def log_warning(message: str):
    print(f"[WARNING] {message}")


def log_error(message: str):
    print(f"[ERROR] {message}")



# ================================================================
# VALIDATION LAYER
# ================================================================

def validate_request(data: RecommendRequest):
    """
    Perform additional validation beyond Pydantic.
    """

    if data.temperature < -10 or data.temperature > 60:
        raise HTTPException(status_code=400, detail="Invalid temperature")

    if data.humidity < 0 or data.humidity > 100:
        raise HTTPException(status_code=400, detail="Invalid humidity")

    if data.rainfall < 0:
        raise HTTPException(status_code=400, detail="Invalid rainfall")



# ================================================================
# NORMALIZATION LAYER
# ================================================================

def normalize_inputs(data: RecommendRequest) -> Dict[str, float]:
    """
    Convert all inputs into standardized float values.
    """

    normalized = {
        "temperature": float(data.temperature),
        "rainfall": float(data.rainfall),
        "humidity": float(data.humidity),
        "ph": float(data.ph)
    }

    log_debug(f"Normalized Inputs: {normalized}")

    return normalized



# ================================================================
# SOIL PROCESSING
# ================================================================

def resolve_soil(soil_type: str) -> Dict[str, float]:
    """
    Convert soil type string into structured soil data.
    """

    soil = SOIL_MAP.get(soil_type)

    if soil is None:
        log_error(f"Invalid soil type: {soil_type}")
        raise HTTPException(status_code=400, detail="Invalid soil type")

    log_debug(f"Soil resolved: {soil}")

    return soil



# ================================================================
# WEATHER CONSTRUCTION
# ================================================================

def build_weather(normalized: Dict[str, float]) -> Dict[str, float]:
    """
    Create weather payload for ML model.
    """

    weather = {
        "temperature": normalized["temperature"],
        "rainfall": normalized["rainfall"],
        "humidity": normalized["humidity"]
    }

    log_debug(f"Weather payload: {weather}")

    return weather



# ================================================================
# ML EXECUTION LAYER
# ================================================================

def execute_prediction(soil, weather, ph) -> Tuple[Any, Any]:
    """
    Run the ML model prediction safely.
    """

    try:
        return recommend_crops({
            "soil": soil,
            "weather": weather,
            "ph": ph
        })

    except Exception as e:
        log_error(f"Prediction failed: {e}")
        raise HTTPException(status_code=500, detail="Prediction error")



# ================================================================
# RESPONSE BUILDER
# ================================================================

def format_response(results):
    """
    Format final API response.
    """

    return {
        "success": True,
        "data": {
            "crops": results,
            "count": len(results)
        },
        "error": None
    }



# ================================================================
# HISTORY STORAGE
# ================================================================

def store_history(user_id, soil, weather, ph, results):
    """
    Save recommendation result into Firestore.
    """

    payload = {
        "userId": user_id,
        "soilSummary": soil,
        "weatherSummary": weather,
        "ph": ph,
        "results": results,
        "createdAt": datetime.utcnow()
    }

    try:
        save_scan_history(payload)
        log_info("History saved successfully")

    except Exception as e:
        log_warning(f"History save failed: {e}")



# ================================================================
# MAIN API ENDPOINT
# ================================================================

@router.post("/recommend")
def recommend(data: RecommendRequest):

    log_info("Request received")

    # ------------------------------------------------------------
    # STEP 1: Validate Request
    # ------------------------------------------------------------

    validate_request(data)

    # ------------------------------------------------------------
    # STEP 2: Normalize Inputs
    # ------------------------------------------------------------

    normalized = normalize_inputs(data)

    # ------------------------------------------------------------
    # STEP 3: Resolve Soil
    # ------------------------------------------------------------

    soil = resolve_soil(data.soilType)

    # ------------------------------------------------------------
    # STEP 4: Build Weather
    # ------------------------------------------------------------

    weather = build_weather(normalized)

    # ------------------------------------------------------------
    # STEP 5: Run Prediction
    # ------------------------------------------------------------

    results, error = execute_prediction(
        soil,
        weather,
        normalized["ph"]
    )

    # ------------------------------------------------------------
    # STEP 6: Handle Model Errors
    # ------------------------------------------------------------

    if error or results is None:
        log_error(f"Model returned error: {error}")
        raise HTTPException(status_code=500, detail="Recommendation failed")

    # ------------------------------------------------------------
    # STEP 7: Save History
    # ------------------------------------------------------------

    store_history(
        data.userId,
        soil,
        weather,
        normalized["ph"],
        results
    )

    # ------------------------------------------------------------
    # STEP 8: Return Response
    # ------------------------------------------------------------

    log_info("Returning response")

    return format_response(results)