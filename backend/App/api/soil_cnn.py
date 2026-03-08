import io
from fastapi import APIRouter, UploadFile, File
from app.services.cnn_service import predict_soil_type

router = APIRouter(prefix="/soil", tags=["Soil CNN"])


@router.post("/predict")
async def predict_soil(file: UploadFile = File(...)):
    """
    Direct CNN prediction endpoint.
    Returns: { "success": true, "data": { "soil_type": "...", "confidence": 0.xx, "probs": {...} } }
    """
    try:
        contents = await file.read()
        result = predict_soil_type(io.BytesIO(contents))
        return {
            "success": True,
            "data": result,
            "error": None,
        }
    except Exception as e:
        return {
            "success": False,
            "data": None,
            "error": str(e),
        }