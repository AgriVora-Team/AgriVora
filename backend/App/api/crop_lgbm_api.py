from fastapi import APIRouter, BackgroundTasks
from app.schemas.crop_lgbm_schema import CropLGBMRequest, CropLGBMResponse
from app.services.crop_lgbm_service import predict_crop

router = APIRouter(prefix="/crop", tags=["Crop Recommendation (LightGBM)"])


@router.post("/recommend", response_model=CropLGBMResponse)
def recommend(req: CropLGBMRequest, background_tasks: BackgroundTasks):

    # convert request to dictionary
    payload = req.model_dump()

    # call prediction service
    result = predict_crop(payload)

    # debug logging
    print("Crop recommendation requested for user:", req.user_id)
    print("Prediction result:", result)

    # return response
    print("Crop recommendation API executed")
    return CropLGBMResponse(
        recommended_crop=result["crop"],
        confidence=result["confidence"],
        recommendations=result.get("recommendations", [])
    )