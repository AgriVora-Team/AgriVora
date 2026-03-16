from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse

from app.services.cnn_service import predict_soil_type

router = APIRouter()


@router.post("/image/texture")
async def predict_texture(file: UploadFile = File(...)):
    contents: bytes = await file.read()
    result = predict_soil_type(contents)

    soil_type = str(result["soil_type"])
    confidence = float(result["confidence"])
    probs = {str(k): float(v) for k, v in result["probs"].items()}

    return JSONResponse(
        content={
            "success": True,
            "data": {
                "texture": soil_type,
                "soil_type": soil_type,
                "confidence": confidence,
                "probs": probs,
            },
            "error": None,
        }
    )