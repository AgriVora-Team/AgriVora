from fastapi import APIRouter, File, UploadFile

router = APIRouter(prefix="/soil", tags=["Soil CNN"])


@router.post("/predict")
async def predict_soil(file: UploadFile = File(...)):
    return {
        "success": True,
        "filename": file.filename,
    }