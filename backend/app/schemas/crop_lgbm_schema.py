from typing import List, Optional

from pydantic import BaseModel

# Request schema for crop prediction
class CropLGBMRequest(BaseModel):
    user_id: Optional[str] = None
    ph: float
    temperature: Optional[float] = None
    humidity: Optional[float] = None
    rainfall: Optional[float] = None
    nitrogen: Optional[float] = 40.0
    carbon: Optional[float] = 1.2
    soil_type: Optional[str] = "loamy soil"

# Individual crop recommendation
class CropRecommendation(BaseModel):
    crop: str
    confidence: float

# Response schema for crop prediction
class CropLGBMResponse(BaseModel):
    recommended_crop: str
    confidence: Optional[float] = None
    recommendations: List[CropRecommendation] = []