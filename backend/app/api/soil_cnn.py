

from fastapi import APIRouter, File, UploadFile

from app.services.cnn_service import predict_soil_type

# Router for soil prediction endpoints
router = APIRouter(prefix="/soil", tags=["Soil CNN"])


@router.post("/predict")
async def predict_soil(file: UploadFile = File(...)):
   
    try:
        # Read uploaded image file
        contents = await file.read()
        # Predict soil type from image
        result = predict_soil_type(contents)  # predict_soil_type wraps bytes in BytesIO internally
        return {
            "success": True,
            "data": result,
            "error": None,
        }
    except Exception as e:
         # Handle errors
        return {
            "success": False,
            "data": None,
            "error": str(e),
        }