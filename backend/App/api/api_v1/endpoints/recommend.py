from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime

from app.services.recommend_service import recommend_crops
from app.utils.firestore import save_scan_history

router = APIRouter()


# =====================================================
# REQUEST MODEL
# =====================================================

class RecommendRequest(BaseModel):

    userId: str = Field(..., description="User ID making the request")
    soilType: str = Field(..., description="Type of soil selected")
    ph: float = Field(..., ge=0, le=14, description="Soil pH value")

    temperature: float
    rainfall: float
    humidity: float


# =====================================================
# SOIL MAPPING
# =====================================================

SOIL_MAP = {
    "Sandy": {
        "sand": 70,
        "clay": 10,
        "organicCarbon": 0.5
    },
    "Clay": {
        "sand": 20,
        "clay": 60,
        "organicCarbon": 1.5
    },
    "Loamy": {
        "sand": 40,
        "clay": 30,
        "organicCarbon": 1.2
    }
}


# =====================================================
# HELPER FUNCTIONS
# =====================================================

def build_weather_summary(temp: float, rain: float, humid: float):

    return {
        "temperature": temp,
        "rainfall": rain,
        "humidity": humid
    }


def validate_soil_type(soil_type: str):

    soil_summary = SOIL_MAP.get(soil_type)

    if soil_summary is None:
        raise HTTPException(
            status_code=400,
            detail="Invalid soil type provided"
        )

    return soil_summary


def store_history(user_id, soil, weather, ph, results):

    history_payload = {
        "userId": user_id,
        "soilSummary": soil,
        "weatherSummary": weather,
        "ph": ph,
        "results": results,
        "createdAt": datetime.utcnow()
    }

    save_scan_history(history_payload)


# =====================================================
# RECOMMENDATION ROUTE
# =====================================================

@router.post("/recommend")
def recommend(data: RecommendRequest):

    print("📡 Crop recommendation request received")

    # Validate soil
    soil_summary = validate_soil_type(data.soilType)

    # Build weather summary
    weather_summary = build_weather_summary(
        data.temperature,
        data.rainfall,
        data.humidity
    )

    print("🌱 Soil summary:", soil_summary)
    print("☁ Weather summary:", weather_summary)

    # Run ML prediction
    results, error = recommend_crops({
        "soil": soil_summary,
        "weather": weather_summary,
        "ph": data.ph
    })

    if error or results is None:
        raise HTTPException(
            status_code=500,
            detail="Crop recommendation failed"
        )

    # Save scan history
    store_history(
        data.userId,
        soil_summary,
        weather_summary,
        data.ph,
        results
    )

    print("✅ Recommendation saved to Firestore")

    return {
        "success": True,
        "data": {
            "crops": results
        },
        "error": None
    }