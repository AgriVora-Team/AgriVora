from fastapi import APIRouter, BackgroundTasks
from app.schemas.crop_lgbm_schema import CropLGBMRequest, CropLGBMResponse
from app.services.crop_lgbm_service import predict_crop
from app.utils.firestore import save_scan_history

router = APIRouter(prefix="/crop", tags=["Crop Recommendation (LightGBM)"])

@router.post("/recommend", response_model=CropLGBMResponse)
def recommend(req: CropLGBMRequest, background_tasks: BackgroundTasks):
    result = predict_crop(req.model_dump())
    print(f"DEBUG: recommend called with user_id: {req.user_id}")
    # Disabled auto-save; User will now explicitly save through the UI
    print("DEBUG: Auto-save disabled for History")

    return CropLGBMResponse(
        recommended_crop=result["crop"],
        confidence=result["confidence"],
        recommendations=result.get("recommendations", [])
    )