"""
====================================================================
Agrivora Crop Recommendation API (Enhanced Version)
====================================================================

This version introduces:
- Structured logging
- Input normalization
- Response builder abstraction
- Improved readability and modularity
- Better debugging support

====================================================================
"""

# ================================================================
# IMPORTS
# ================================================================

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime

from app.services.recommend_service import recommend_crops
from app.utils.firestore import save_scan_history



# ================================================================
# ROUTER SETUP
# ================================================================

router = APIRouter(
    prefix="/recommendation",
    tags=["Crop Recommendation - Enhanced"]
)



# ================================================================
# REQUEST MODEL
# ================================================================

class RecommendRequest(BaseModel):

    userId: str = Field(..., description="User identifier")

    soilType: str = Field(..., description="Soil category")

    ph: float = Field(..., ge=0, le=14, description="Soil pH")

    temperature: float
    rainfall: float
    humidity: float



# ================================================================
# CONSTANTS
# ================================================================

SOIL_MAP = {
    "Sandy": {"sand": 70, "clay": 10, "organicCarbon": 0.5},
    "Clay": {"sand": 20, "clay": 60, "organicCarbon": 1.5},
    "Loamy": {"sand": 40, "clay": 30, "organicCarbon": 1.2}
}



# ================================================================
# LOGGING HELPERS
# ================================================================

def log_step(message: str):
    print(f"[RECOMMENDATION API] {message}")


def log_error(message: str):
    print(f"[RECOMMENDATION ERROR] {message}")



# ================================================================
# HELPER FUNCTIONS
# ================================================================

def normalize_inputs(data: RecommendRequest):
    """
    Normalize and sanitize incoming data
    """

    return {
        "temperature": float(data.temperature),
        "rainfall": float(data.rainfall),
        "humidity": float(data.humidity),
        "ph": float(data.ph)
    }


def get_soil_summary(soil_type: str):

    soil_summary = SOIL_MAP.get(soil_type)

    if soil_summary is None:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported soil type: {soil_type}"
        )

    return soil_summary


def build_weather(data):

    return {
        "temperature": data["temperature"],
        "rainfall": data["rainfall"],
        "humidity": data["humidity"]
    }


def build_response(results):

    return {
        "success": True,
        "data": {
            "crops": results
        },
        "error": None
    }


def save_history(user_id, soil, weather, ph, results):

    payload = {
        "userId": user_id,
        "soilSummary": soil,
        "weatherSummary": weather,
        "ph": ph,
        "results": results,
        "createdAt": datetime.utcnow()
    }

    save_scan_history(payload)



# ================================================================
# MAIN ENDPOINT
# ================================================================

@router.post("/recommend")
def recommend(data: RecommendRequest):

    log_step("Incoming crop recommendation request")

    # ------------------------------------------------------------
    # STEP 1: Normalize Inputs
    # ------------------------------------------------------------

    normalized = normalize_inputs(data)

    log_step(f"Normalized data: {normalized}")


    # ------------------------------------------------------------
    # STEP 2: Soil Processing
    # ------------------------------------------------------------

    soil_summary = get_soil_summary(data.soilType)

    log_step(f"Soil summary resolved: {soil_summary}")


    # ------------------------------------------------------------
    # STEP 3: Weather Construction
    # ------------------------------------------------------------

    weather_summary = build_weather(normalized)

    log_step(f"Weather summary: {weather_summary}")


    # ------------------------------------------------------------
    # STEP 4: ML Prediction
    # ------------------------------------------------------------

    try:

        results, error = recommend_crops({
            "soil": soil_summary,
            "weather": weather_summary,
            "ph": normalized["ph"]
        })

    except Exception as e:
        log_error(f"Prediction crash: {e}")
        raise HTTPException(
            status_code=500,
            detail="Internal prediction failure"
        )


    # ------------------------------------------------------------
    # STEP 5: Error Handling
    # ------------------------------------------------------------

    if error or results is None:

        log_error(f"Model error: {error}")

        raise HTTPException(
            status_code=500,
            detail="Crop recommendation failed"
        )


    # ------------------------------------------------------------
    # STEP 6: Save History
    # ------------------------------------------------------------

    try:

        save_history(
            data.userId,
            soil_summary,
            weather_summary,
            normalized["ph"],
            results
        )

        log_step("History saved successfully")

    except Exception as e:

        log_error(f"History save failed: {e}")


    # ------------------------------------------------------------
    # STEP 7: Return Response
    # ------------------------------------------------------------

    log_step("Returning recommendation response")

    return build_response(results)