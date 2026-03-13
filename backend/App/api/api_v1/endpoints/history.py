from fastapi import APIRouter, HTTPException
from app.utils.firestore import db, get_scan_history

router = APIRouter()


def success_response(data):
    return {
        "success": True,
        "data": data,
        "error": None
    }


def server_error(exc: Exception):
    raise HTTPException(
        status_code=500,
        detail=str(exc)
    )


# =====================================================
# GET FULL SCAN HISTORY
# =====================================================
@router.get("/history/{user_id}")
def get_history(user_id: str):
    try:
        history = get_scan_history(user_id)
        return success_response(history)
    except Exception as e:
        server_error(e)


# =====================================================
# GET LATEST SCAN (FOR DASHBOARD)
# =====================================================
@router.get("/history/latest/{user_id}")
def get_latest_history(user_id: str):
    try:
        query = (
            db.collection("scan_history")
            .where("userId", "==", user_id)
            .order_by("createdAt", direction="DESCENDING")
            .limit(1)
            .stream()
        )

        latest_record = None

        for doc in query:
            latest_record = doc.to_dict()
            latest_record["id"] = doc.id
            break

        return success_response(latest_record)

    except Exception as e:
        server_error(e)