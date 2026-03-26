

from fastapi import APIRouter
from fastapi.responses import JSONResponse

from app.schemas.crop_lgbm_schema import CropLGBMRequest
from app.services.crop_lgbm_service import predict_crop

# Router for crop recommendation endpoints
router = APIRouter(prefix="/crop", tags=["Crop Recommendation (LightGBM)"])


@router.post("/recommend")
def recommend(req: CropLGBMRequest):
   
    try:
          # Run prediction using request data
        result = predict_crop(req.model_dump())

        # Return standardized response
        return JSONResponse(content={
            "success": True,
            "data": {
                "recommended_crop": result["crop"],
                "confidence": result["confidence"],
                "recommendations": result.get("recommendations", []),
            },
            "error": None,
        })

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "data": None,
                "error": str(e),
            },
        )
