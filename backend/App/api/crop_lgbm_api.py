"""
====================================================================
Agrivora Crop Recommendation API (Enterprise Version)
====================================================================

This module defines the REST API endpoint responsible for
generating crop recommendations using the LightGBM model.

This version includes:

✔ Input validation layer
✔ Structured logging system
✔ Modular helper utilities
✔ Error handling mechanisms
✔ Response abstraction
✔ Background task integration
✔ Execution tracing

====================================================================
"""

# ===============================================================
# IMPORTS
# ===============================================================

from fastapi import APIRouter, BackgroundTasks, HTTPException
from typing import Dict, Any
import traceback

from app.schemas.crop_lgbm_schema import (
    CropLGBMRequest,
    CropLGBMResponse
)

from app.services.crop_lgbm_service import predict_crop



# ===============================================================
# ROUTER CONFIGURATION
# ===============================================================

router = APIRouter(
    prefix="/crop",
    tags=["Crop Recommendation (LightGBM) - Advanced"]
)



# ===============================================================
# LOGGING UTILITIES
# ===============================================================

def log_info(msg: str):
    print(f"[INFO] {msg}")


def log_debug(msg: str):
    print(f"[DEBUG] {msg}")


def log_error(msg: str):
    print(f"[ERROR] {msg}")



# ===============================================================
# VALIDATION HELPERS
# ===============================================================

def validate_request_payload(payload: Dict[str, Any]):
    """
    Perform additional validation on incoming payload.
    """

    if payload.get("ph") is not None:
        if not (0 <= payload["ph"] <= 14):
            raise HTTPException(
                status_code=400,
                detail="pH must be between 0 and 14"
            )

    return payload



# ===============================================================
# NORMALIZATION HELPERS
# ===============================================================

def normalize_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    """
    Normalize values before sending to ML service.
    """

    normalized = {}

    for key, value in payload.items():
        try:
            normalized[key] = float(value) if isinstance(value, (int, float)) else value
        except:
            normalized[key] = value

    return normalized



# ===============================================================
# RESPONSE BUILDER
# ===============================================================

def build_response(result: Dict[str, Any]) -> CropLGBMResponse:
    """
    Convert ML output into API response schema.
    """

    return CropLGBMResponse(
        recommended_crop=result.get("crop", "Unknown"),
        confidence=result.get("confidence", 0.85),
        recommendations=result.get("recommendations", [])
    )



# ===============================================================
# BACKGROUND TASK (OPTIONAL)
# ===============================================================

def background_logger(payload, result):
    """
    Simulated async logging function.
    """

    log_debug("Background logging started")
    log_debug(f"Payload: {payload}")
    log_debug(f"Result: {result}")
    log_debug("Background logging completed")



# ===============================================================
# MAIN ENDPOINT
# ===============================================================

@router.post("/recommend", response_model=CropLGBMResponse)
def recommend(
    req: CropLGBMRequest,
    background_tasks: BackgroundTasks
):
    """
    Main crop recommendation endpoint.

    Execution Flow:

    1. Convert request to dictionary
    2. Validate payload
    3. Normalize inputs
    4. Call ML service
    5. Handle errors
    6. Build response
    7. Trigger background tasks
    """

    log_info("==============================================")
    log_info("Crop recommendation request received")
    log_info(f"User ID: {req.user_id}")
    log_info("==============================================")



    # ----------------------------------------------------------
    # STEP 1: Convert request to dictionary
    # ----------------------------------------------------------

    payload = req.model_dump()

    log_debug(f"Raw payload: {payload}")



    # ----------------------------------------------------------
    # STEP 2: Validate payload
    # ----------------------------------------------------------

    try:
        payload = validate_request_payload(payload)
    except Exception as e:
        log_error(f"Validation failed: {e}")
        raise



    # ----------------------------------------------------------
    # STEP 3: Normalize inputs
    # ----------------------------------------------------------

    payload = normalize_payload(payload)

    log_debug(f"Normalized payload: {payload}")



    # ----------------------------------------------------------
    # STEP 4: Call ML service
    # ----------------------------------------------------------

    try:

        result = predict_crop(payload)

        log_debug(f"ML Result: {result}")

    except Exception as e:

        log_error("ML prediction failed")
        log_error(traceback.format_exc())

        raise HTTPException(
            status_code=500,
            detail="Prediction engine failure"
        )



    # ----------------------------------------------------------
    # STEP 5: Validate ML output
    # ----------------------------------------------------------

    if not result or "crop" not in result:

        log_error("Invalid ML response format")

        raise HTTPException(
            status_code=500,
            detail="Invalid prediction response"
        )



    # ----------------------------------------------------------
    # STEP 6: Build API response
    # ----------------------------------------------------------

    response = build_response(result)



    # ----------------------------------------------------------
    # STEP 7: Background logging
    # ----------------------------------------------------------

    try:
        background_tasks.add_task(
            background_logger,
            payload,
            result
        )
    except Exception as e:
        log_error(f"Background task failed: {e}")



    # ----------------------------------------------------------
    # STEP 8: Final logging
    # ----------------------------------------------------------

    log_info("Recommendation successfully generated")
    log_info("==============================================")



    return response