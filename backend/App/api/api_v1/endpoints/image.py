from fastapi import APIRouter, File, UploadFile

router = APIRouter()


@router.post("/image/texture")
async def predict_texture(file: UploadFile = File(...)):
    return {
        "success": True,
        "filename": file.filename,
    }