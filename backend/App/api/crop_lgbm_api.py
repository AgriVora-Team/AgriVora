"""
Crop Recommendation API (LightGBM)
------------------------------------------------------------

This module exposes the REST API endpoint responsible for
handling crop recommendation requests in the Agrivora system.

The endpoint communicates with the LightGBM prediction service
which performs the machine learning inference.

Workflow of this API endpoint:

1. Receive request from frontend/mobile client
2. Validate request using Pydantic schema
3. Convert request object to dictionary payload
4. Pass payload to LightGBM prediction service
5. Receive prediction result
6. Format response using Pydantic response schema
7. Return structured response to client

This endpoint is designed to work with the Agrivora AI engine
to provide crop recommendations based on environmental
conditions and soil parameters.

Author: Agrivora Team
"""


# ---------------------------------------------------------
# IMPORTS
# ---------------------------------------------------------

# FastAPI router tools
from fastapi import APIRouter, BackgroundTasks

# Pydantic request / response schemas
from app.schemas.crop_lgbm_schema import (
    CropLGBMRequest,
    CropLGBMResponse
)

# ML prediction service
from app.services.crop_lgbm_service import predict_crop



# ---------------------------------------------------------
# ROUTER INITIALIZATION
# ---------------------------------------------------------

"""
Create a router instance for crop-related endpoints.

prefix="/crop"
    All endpoints in this router will start with /crop

tags=["Crop Recommendation (LightGBM)"]
    Used for API documentation grouping in Swagger UI
"""

router = APIRouter(
    prefix="/crop",
    tags=["Crop Recommendation (LightGBM)"]
)



# ---------------------------------------------------------
# CROP RECOMMENDATION ENDPOINT
# ---------------------------------------------------------

@router.post(
    "/recommend",
    response_model=CropLGBMResponse
)
def recommend(
    req: CropLGBMRequest,
    background_tasks: BackgroundTasks
):
    """
    Generate crop recommendation using LightGBM model.

    Parameters
    ----------
    req : CropLGBMRequest
        Pydantic request model containing soil and
        environmental parameters.

    background_tasks : BackgroundTasks
        FastAPI background task handler (optional future use).
        This allows asynchronous tasks such as logging
        or saving prediction history.

    Returns
    -------
    CropLGBMResponse
        Structured API response containing:
        - recommended crop
        - confidence score
        - list of alternative crop recommendations
    """



    # -----------------------------------------------------
    # STEP 1 — CONVERT REQUEST OBJECT TO DICTIONARY
    # -----------------------------------------------------

    """
    Pydantic models cannot always be passed directly to
    ML services. Therefore we convert the request object
    into a Python dictionary.

    This dictionary will contain values such as:

        temperature
        humidity
        rainfall
        soil_type
        nitrogen
        carbon
        ph
    """

    payload = req.model_dump()



    # -----------------------------------------------------
    # STEP 2 — CALL MACHINE LEARNING PREDICTION SERVICE
    # -----------------------------------------------------

    """
    The payload is sent to the crop prediction service.

    This service loads the trained LightGBM model
    and generates crop predictions based on the input data.
    """

    result = predict_crop(payload)



    # -----------------------------------------------------
    # STEP 3 — DEBUG LOGGING
    # -----------------------------------------------------

    """
    These logs help developers monitor API activity.

    In production systems this would usually be replaced
    with structured logging tools such as:

        - Python logging module
        - Logstash
        - Cloud logging services
    """

    print("--------------------------------------------------")
    print("Crop recommendation API request received")
    print("User ID:", req.user_id)
    print("Input payload:", payload)
    print("Prediction result:", result)
    print("--------------------------------------------------")



    # -----------------------------------------------------
    # STEP 4 — FORMAT API RESPONSE
    # -----------------------------------------------------

    """
    The prediction result returned by the ML service
    is converted into a structured response model.

    This ensures consistent API responses and allows
    automatic validation by FastAPI.
    """

    response = CropLGBMResponse(
        recommended_crop=result["crop"],
        confidence=result["confidence"],
        recommendations=result.get("recommendations", [])
    )



    # -----------------------------------------------------
    # STEP 5 — OPTIONAL BACKGROUND TASK (FUTURE USE)
    # -----------------------------------------------------

    """
    Background tasks could be used to:

        - save recommendation history
        - log analytics
        - store predictions for ML monitoring
        - trigger notifications

    Example:

        background_tasks.add_task(save_history, payload, result)
    """



    # -----------------------------------------------------
    # STEP 6 — FINAL RESPONSE
    # -----------------------------------------------------

    print("Crop recommendation API execution completed")

    return response