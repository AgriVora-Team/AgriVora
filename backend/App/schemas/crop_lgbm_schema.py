"""
====================================================================
Agrivora Crop Recommendation Schema (Enterprise Version)
====================================================================

This module defines advanced Pydantic schemas for the
LightGBM crop recommendation API.

Enhancements in this version:

✔ Field validation rules
✔ Custom validators
✔ Response metadata support
✔ Debug and audit schema layers
✔ Extended documentation for API consumers
✔ Versioned schema structure
✔ Real-world production readiness

====================================================================
"""

# ===============================================================
# IMPORTS
# ===============================================================

from pydantic import BaseModel, Field, validator
from typing import List, Optional
from datetime import datetime



# ===============================================================
# CONSTANTS
# ===============================================================

VALID_SOIL_TYPES = [
    "loamy soil",
    "clay soil",
    "sandy soil",
    "acidic soil",
    "alkaline soil"
]



# ===============================================================
# BASE MODEL WITH COMMON CONFIG
# ===============================================================

class BaseSchema(BaseModel):
    """
    Base schema providing shared configuration.
    """

    class Config:
        anystr_strip_whitespace = True
        validate_assignment = True
        extra = "ignore"



# ===============================================================
# REQUEST SCHEMA
# ===============================================================

class CropLGBMRequest(BaseSchema):

    user_id: str = Field(..., description="User ID")

    temperature: float = Field(..., description="Temperature (°C)")
    humidity: float = Field(..., description="Humidity (%)")
    rainfall: float = Field(..., description="Rainfall (mm)")

    ph: float = Field(..., description="Soil pH level")
    nitrogen: float = Field(..., description="Nitrogen content")
    carbon: float = Field(..., description="Carbon content")

    soil_type: str = Field(..., description="Soil type")



    # ----------------------------------------------------------
    # VALIDATORS
    # ----------------------------------------------------------

    @validator("ph")
    def validate_ph(cls, value):
        if not (0 <= value <= 14):
            raise ValueError("pH must be between 0 and 14")
        return value


    @validator("soil_type")
    def validate_soil(cls, value):
        if value.lower() not in VALID_SOIL_TYPES:
            return value.lower()  # allow flexibility
        return value.lower()


    @validator("temperature", "humidity", "rainfall")
    def validate_non_negative(cls, value):
        if value < 0:
            raise ValueError("Environmental values cannot be negative")
        return value



    # ----------------------------------------------------------
    # UTILITY METHOD
    # ----------------------------------------------------------

    def to_payload(self):
        """
        Convert request into dictionary payload.
        """
        return self.dict()



# ===============================================================
# RECOMMENDATION OBJECT
# ===============================================================

class Recommendation(BaseSchema):

    crop: str = Field(..., description="Crop name")
    confidence: float = Field(..., description="Confidence score")

    reason: Optional[str] = Field(
        None,
        description="Optional explanation for recommendation"
    )



# ===============================================================
# RESPONSE METADATA
# ===============================================================

class ResponseMeta(BaseSchema):

    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="Response generation time"
    )

    model_version: str = Field(
        default="v1.0",
        description="ML model version"
    )

    request_id: Optional[str] = Field(
        None,
        description="Optional tracking ID"
    )



# ===============================================================
# DEBUG INFO (OPTIONAL)
# ===============================================================

class DebugInfo(BaseSchema):

    input_payload: Optional[dict] = None
    processing_time_ms: Optional[int] = None
    model_used: Optional[str] = "LightGBM"



# ===============================================================
# RESPONSE SCHEMA
# ===============================================================

class CropLGBMResponse(BaseSchema):

    recommended_crop: str = Field(..., description="Top crop")
    confidence: float = Field(..., description="Confidence score")

    recommendations: List[Recommendation]

    # Extra enterprise-level fields
    meta: Optional[ResponseMeta] = None
    debug: Optional[DebugInfo] = None



    # ----------------------------------------------------------
    # VALIDATION
    # ----------------------------------------------------------

    @validator("confidence")
    def validate_confidence(cls, value):
        if not (0 <= value <= 1):
            raise ValueError("Confidence must be between 0 and 1")
        return value



    # ----------------------------------------------------------
    # HELPER METHOD
    # ----------------------------------------------------------

    def add_meta(self):
        self.meta = ResponseMeta()



# ===============================================================
# AUDIT LOG SCHEMA (EXTRA)
# ===============================================================

class PredictionAudit(BaseSchema):

    user_id: str
    crop: str
    confidence: float
    created_at: datetime = Field(default_factory=datetime.utcnow)



# ===============================================================
# MODULE INIT LOG
# ===============================================================

print("==================================================")
print("Agrivora Schema Module Loaded Successfully")
print("Schemas: Request | Response | Meta | Debug | Audit")
print("==================================================")