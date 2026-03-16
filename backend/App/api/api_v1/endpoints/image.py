from fastapi import APIRouter, File, UploadFile

from app.services.cnn_service import predict_soil_type

router = APIRouter()


@router.post("/image/texture")
async def predict_texture(file: UploadFile = File(...)):
    contents: bytes = await file.read()
    result = predict_soil_type(contents)

    return {
        "success": True,
        "data": result,
        "error": None,
    }