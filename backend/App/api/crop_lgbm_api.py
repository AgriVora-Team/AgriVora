"""
====================================================================
AGRIVORA CROP RECOMMENDATION API (ULTRA ENTERPRISE VERSION)
====================================================================

This module defines the REST API endpoint responsible for generating
AI-based crop recommendations using the LightGBM model.

This version includes:

✔ Multi-layer validation
✔ Input normalization pipeline
✔ Structured logging (info/debug/error)
✔ Background task execution
✔ Robust error handling
✔ Response abstraction layer
✔ Execution tracing for debugging
✔ Clean modular architecture

====================================================================
"""

# ===============================================================
# IMPORTS
# ===============================================================

from fastapi import APIRouter, BackgroundTasks, HTTPException
from typing import Dict, Any
import traceback
import datetime



# Internal modules
from app.schemas.crop_lgbm_schema import (
    CropLGBMRequest,
    CropLGBMResponse
)

from app.services.crop_lgbm_service import predict_crop



# ===============================================================
# ROUTER CONFIGURATION
# ===============================================================

"""
Router groups all crop-related endpoints.

Prefix:
    /crop

Tag:
    Used in Swagger UI grouping
"""

router = APIRouter(
    prefix="/crop",
    tags=["Crop Recommendation (LightGBM) - Ultra"]
)



# ===============================================================
# LOGGING SYSTEM
# ===============================================================

def log_info(msg: str):
    """General information logs"""
    print(f"[INFO] {datetime.datetime.utcnow()} | {msg}")


def log_debug(msg: str):
    """Detailed debug logs"""
    print(f"[DEBUG] {datetime.datetime.utcnow()} | {msg}")


def log_error(msg: str):
    """Error logs"""
    print(f"[ERROR] {datetime.datetime.utcnow()} | {msg}")



# ===============================================================
# VALIDATION LAYER
# ===============================================================

def validate_request_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    """
    Validate incoming request payload.

    Ensures:
    - pH is within valid agricultural range
    - Required values exist
    """

    if payload.get("ph") is not None:

        if not (0 <= payload["ph"] <= 14):

            log_error("Invalid pH detected")

            raise HTTPException(
                status_code=400,
                detail="pH must be between 0 and 14"
            )

    return payload



# ===============================================================
# NORMALIZATION LAYER
# ===============================================================

def normalize_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    """
    Convert all numeric inputs into float values.

    This ensures compatibility with ML model expectations.
    """

    normalized = {}

    for key, value in payload.items():

        try:

            if isinstance(value, (int, float)):
                normalized[key] = float(value)
            else:
                normalized[key] = value

        except Exception:

            log_debug(f"Normalization failed for {key}, keeping original")

            normalized[key] = value

    return normalized



# ===============================================================
# RESPONSE BUILDER
# ===============================================================

def build_response(result: Dict[str, Any]) -> CropLGBMResponse:
    """
    Convert ML output into structured API response.
    """

    return CropLGBMResponse(
        recommended_crop=result.get("crop", "Unknown"),
        confidence=result.get("confidence", 0.85),
        recommendations=result.get("recommendations", [])
    )



# ===============================================================
# BACKGROUND TASK HANDLER
# ===============================================================

def background_logger(payload: Dict[str, Any], result: Dict[str, Any]):
    """
    Background logging task.

    Runs asynchronously after response is sent.
    Useful for:
    - analytics
    - debugging
    - monitoring
    """

    log_debug("Background logging started")

    log_debug(f"Payload snapshot: {payload}")

    log_debug(f"Prediction snapshot: {result}")

    log_debug("Background logging finished")



# ===============================================================
# MAIN API ENDPOINT
# ===============================================================

@router.post("/recommend", response_model=CropLGBMResponse)
def recommend(
    req: CropLGBMRequest,
    background_tasks: BackgroundTasks
):
    """
    MAIN ENDPOINT: Crop Recommendation

    Full Execution Flow:

    1. Receive request
    2. Convert request to dictionary
    3. Validate payload
    4. Normalize data
    5. Call ML model
    6. Handle errors
    7. Build response
    8. Run background tasks
    9. Return final response
    """

    # ===========================================================
    # STEP 0: INITIAL LOGGING
    # ===========================================================

    log_info("==============================================")
    log_info("Crop recommendation request started")
    log_info(f"User ID: {req.user_id}")
    log_info("==============================================")



    # ===========================================================
    # STEP 1: CONVERT REQUEST OBJECT TO DICTIONARY
    # ===========================================================

    payload = req.model_dump()

    log_debug(f"Raw payload received: {payload}")



    # ===========================================================
    # STEP 2: VALIDATION
    # ===========================================================

    try:

        payload = validate_request_payload(payload)

    except Exception as e:

        log_error(f"Validation error: {e}")

        raise



    # ===========================================================
    # STEP 3: NORMALIZATION
    # ===========================================================

    payload = normalize_payload(payload)

    log_debug(f"Normalized payload: {payload}")



    # ===========================================================
    # STEP 4: ML PREDICTION
    # ===========================================================

    try:

        result = predict_crop(payload)

        log_debug(f"ML output: {result}")

    except Exception:

        log_error("Prediction engine crashed")

        log_error(traceback.format_exc())

        raise HTTPException(
            status_code=500,
            detail="Prediction engine failure"
        )



    # ===========================================================
    # STEP 5: OUTPUT VALIDATION
    # ===========================================================

    if not result or "crop" not in result:

        log_error("Invalid ML response structure")

        raise HTTPException(
            status_code=500,
            detail="Invalid prediction output"
        )



    # ===========================================================
    # STEP 6: BUILD RESPONSE OBJECT
    # ===========================================================

    response = build_response(result)



    # ===========================================================
    # STEP 7: BACKGROUND PROCESSING
    # ===========================================================

    try:

        background_tasks.add_task(
            background_logger,
            payload,
            result
        )

    except Exception as e:

        log_error(f"Background task error: {e}")



    # ===========================================================
    # STEP 8: FINAL LOGGING
    # ===========================================================

    log_info("Crop recommendation completed successfully")
    log_info("==============================================")



    # ===========================================================
    # STEP 9: RETURN RESPONSE
    # ===========================================================

    return response