from fastapi import APIRouter, File, UploadFile
from app.services.cnn_service import predict_soil_type

router = APIRouter(prefix="/soil", tags=["Soil CNN"])


@router.post("/predict")
async def predict_soil(file: UploadFile = File(...)):
    contents = await file.read()
    result = predict_soil_type(contents)

    return {
        "success": True,
        "data": result,
        "error": None,
    }