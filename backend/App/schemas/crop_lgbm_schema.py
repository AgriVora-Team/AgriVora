"""
Crop Recommendation Schema Definitions
------------------------------------------------------------

This module defines the Pydantic schemas used for the
LightGBM crop recommendation API in the Agrivora system.

Schemas are responsible for:

1. Validating incoming API requests
2. Structuring API responses
3. Enforcing data types and constraints
4. Generating automatic API documentation

FastAPI uses these schemas to automatically generate
OpenAPI / Swagger documentation.

Author: Agrivora AI Platform
"""

# ---------------------------------------------------------
# IMPORTS
# ---------------------------------------------------------

from pydantic import BaseModel, Field
from typing import List


# ---------------------------------------------------------
# REQUEST SCHEMA
# ---------------------------------------------------------

class CropLGBMRequest(BaseModel):
    """
    Request schema for the crop recommendation endpoint.

    This schema represents the input data sent by
    the frontend or mobile application when requesting
    a crop recommendation.

    The values represent environmental conditions
    and soil properties of the farm location.
    """

    user_id: str = Field(
        ...,
        description="Unique identifier of the user requesting crop recommendation",
        example="user_12345"
    )

    temperature: float = Field(
        ...,
        description="Current environmental temperature in Celsius",
        example=27.5
    )

    humidity: float = Field(
        ...,
        description="Relative humidity percentage",
        example=70.0
    )

    rainfall: float = Field(
        ...,
        description="Average rainfall measurement in millimeters",
        example=120.0
    )

    ph: float = Field(
        ...,
        description="Soil pH level (0–14 scale)",
        example=6.5
    )

    nitrogen: float = Field(
        ...,
        description="Nitrogen content in soil",
        example=40.0
    )

    carbon: float = Field(
        ...,
        description="Organic carbon level in soil",
        example=1.2
    )

    soil_type: str = Field(
        ...,
        description="Type of soil detected or selected",
        example="loamy soil"
    )

    class Config:
        """
        Pydantic configuration for the request schema.
        """

        schema_extra = {
            "example": {
                "user_id": "user_001",
                "temperature": 26.0,
                "humidity": 68.0,
                "rainfall": 110.0,
                "ph": 6.5,
                "nitrogen": 38.0,
                "carbon": 1.3,
                "soil_type": "loamy soil"
            }
        }


# ---------------------------------------------------------
# RECOMMENDATION OBJECT SCHEMA
# ---------------------------------------------------------

class Recommendation(BaseModel):
    """
    Schema representing a single crop recommendation.

    The ML model returns multiple crop options
    ranked by confidence score.
    """

    crop: str = Field(
        ...,
        description="Name of the recommended crop",
        example="Rice"
    )

    confidence: float = Field(
        ...,
        description="Prediction confidence score between 0 and 1",
        example=0.87
    )


# ---------------------------------------------------------
# RESPONSE SCHEMA
# ---------------------------------------------------------

class CropLGBMResponse(BaseModel):
    """
    API response schema returned by the crop
    recommendation endpoint.

    This structure is sent back to the frontend
    application after the ML prediction is generated.
    """

    recommended_crop: str = Field(
        ...,
        description="Top recommended crop based on model prediction",
        example="Rice"
    )

    confidence: float = Field(
        ...,
        description="Confidence score of the top prediction",
        example=0.92
    )

    recommendations: List[Recommendation] = Field(
        ...,
        description="List of alternative crop recommendations"
    )

    class Config:
        """
        Example response used in API documentation.
        """

        schema_extra = {
            "example": {
                "recommended_crop": "Rice",
                "confidence": 0.92,
                "recommendations": [
                    {
                        "crop": "Rice",
                        "confidence": 0.92
                    },
                    {
                        "crop": "Maize",
                        "confidence": 0.81
                    },
                    {
                        "crop": "Wheat",
                        "confidence": 0.74
                    }
                ]
            }
        }


# ---------------------------------------------------------
# DEBUG INITIALIZATION MESSAGE
# ---------------------------------------------------------

"""
This message helps developers verify that the schema
module has been successfully loaded during server startup.
"""

print("Crop LightGBM schema module initialized successfully.")
print("Request and response validation schemas ready.")