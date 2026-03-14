from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.recommend_service import recommend_crops
from app.utils.firestore import save_scan_history
from datetime import datetime

router = APIRouter()


# =====================================================
# REQUEST SCHEMA
# =====================================================

class RecommendRequest(BaseModel):
    userId: str
    soilType: str
    ph: float
    temperature: float
    rainfall: float
    humidity: float


# =====================================================
# MANUAL SOIL RECOMMENDATION
# =====================================================

@router.post("/recommend")
def recommend(data: RecommendRequest):

    print("Recommendation request received for user:", data.userId)

    # Validate pH
    if not (0 <= data.ph <= 14):
        raise HTTPException(
            status_code=400,
            detail="Invalid pH value"
        )

    # Soil type mapping
    soil_map = {
        "Sandy": {"sand": 70, "clay": 10, "organicCarbon": 0.5},
        "Clay": {"sand": 20, "clay": 60, "organicCarbon": 1.5},
        "Loamy": {"sand": 40, "clay": 30, "organicCarbon": 1.2}
    }

    soil_summary = soil_map.get(data.soilType)

    if soil_summary is None:
        raise HTTPException(
            status_code=400,
            detail="Invalid soil type"
        )

    # Weather summary
    weather_summary = {
        "temperature": data.temperature,
        "rainfall": data.rainfall,
        "humidity": data.humidity
    }

    print("Soil summary:", soil_summary)
    print("Weather summary:", weather_summary)

    # ML prediction
    results, error = recommend_crops({
        "soil": soil_summary,
        "weather": weather_summary,
        "ph": data.ph
    })

    if error or results is None:
        raise HTTPException(
            status_code=500,
            detail="Recommendation failed"
        )

    # Save scan history
    save_scan_history({
        "userId": data.userId,
        "soilSummary": soil_summary,
        "weatherSummary": weather_summary,
        "ph": data.ph,
        "results": results,
        "createdAt": datetime.utcnow()
    })

    print("Recommendation saved to Firestore")

    return {
        "success": True,
        "data": {
            "crops": results
        },
        "error": None
    }