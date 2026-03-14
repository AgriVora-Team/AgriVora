from pydantic import BaseModel
from typing import List


class CropLGBMRequest(BaseModel):
    user_id: str
    temperature: float
    humidity: float
    rainfall: float
    ph: float
    nitrogen: float
    carbon: float
    soil_type: str


class Recommendation(BaseModel):
    crop: str
    confidence: float


class CropLGBMResponse(BaseModel):
    recommended_crop: str
    confidence: float
    recommendations: List[Recommendation]


# Debug helper
print("Crop LGBM schema loaded")