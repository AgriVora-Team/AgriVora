from fastapi import APIRouter, HTTPException
from app.utils.firestore import db, get_scan_history

router = APIRouter()

# =====================================================
# GET FULL SCAN HISTORY
# =====================================================

@router.get("/history/{user_id}")
def get_history(user_id: str):
    try:
        results = get_scan_history(user_id)

        return {
            "success": True,
            "data": results,
            "error": None
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =====================================================
# GET LATEST SCAN (FOR DASHBOARD)
# =====================================================

@router.get("/history/latest/{user_id}")
def get_latest_history(user_id: str):
    try:
        docs = (
            db.collection("scan_history")
            .where("userId", "==", user_id)
            .order_by("createdAt", direction="DESCENDING")
            .limit(1)
            .stream()
        )

        for doc in docs:
            data = doc.to_dict()
            data["id"] = doc.id

            return {
                "success": True,
                "data": data,
                "error": None
            }

        # If no history exists
        return {
            "success": True,
            "data": None,
            "error": None
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )
