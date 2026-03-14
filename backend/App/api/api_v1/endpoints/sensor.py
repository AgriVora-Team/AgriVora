from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
import logging
import uuid
from datetime import datetime, timezone
from collections import deque
import statistics
import asyncio

router = APIRouter()
logger = logging.getLogger(__name__)

_sessions: dict = {}
_live_cache: dict = {}

class GpsPoint(BaseModel):
    lat: float
    lng: float

class PhReadingIn(BaseModel):
    ph: float = Field(..., ge=0.0, le=14.0)
    voltage: Optional[float] = None
    temperature: Optional[float] = None
    gps: Optional[GpsPoint] = None
    capturedAt: Optional[str] = None

class BulkUpload(BaseModel):
    sessionId: str
    deviceId: str
    readings: List[PhReadingIn]

class SessionStart(BaseModel):
    userId: str
    deviceId: str
    gps: Optional[GpsPoint] = None


def _get_session(session_id: str):
    if session_id not in _sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    return _sessions[session_id]


def _compute_summary(readings: list) -> dict:
    ph_vals = [r["ph"] for r in readings if r.get("ph") is not None]
    if not ph_vals:
        return {}

    avg = round(statistics.mean(ph_vals), 2)
    mn = round(min(ph_vals), 2)
    mx = round(max(ph_vals), 2)
    stdev = round(statistics.stdev(ph_vals), 3) if len(ph_vals) > 1 else 0.0

    stability = max(0, round(100 - stdev * 100, 1))

    category = (
        "Strongly Acidic" if avg < 5.5 else
        "Acidic" if avg < 6.5 else
        "Neutral" if avg < 7.5 else
        "Alkaline" if avg < 8.5 else
        "Strongly Alkaline"
    )

    tip = None
    if avg < 5.5:
        tip = "Add lime to raise soil pH."
    elif avg > 7.5:
        tip = "Add sulfur or compost to reduce soil pH."

    return {
        "avgPh": avg,
        "minPh": mn,
        "maxPh": mx,
        "stdev": stdev,
        "stabilityScore": stability,
        "category": category,
        "improvementTip": tip,
        "count": len(ph_vals),
    }


def _validate_readings(readings: List[PhReadingIn]) -> List[dict]:
    valid = []
    prev = None

    for r in readings:
        if prev is not None and abs(r.ph - prev) > 1.0:
            continue
        prev = r.ph
        valid.append(r.dict())

    return valid


@router.post("/ph/sessions/start")
async def start_session(body: SessionStart):

    session_id = str(uuid.uuid4())

    _sessions[session_id] = {
        "sessionId": session_id,
        "userId": body.userId,
        "deviceId": body.deviceId,
        "startedAt": datetime.now(timezone.utc).isoformat(),
        "endedAt": None,
        "gps": body.gps.dict() if body.gps else None,
        "readings": [],
        "summary": {},
    }

    return {"success": True, "data": {"sessionId": session_id}}


@router.post("/ph/sessions/{session_id}/readings/bulk")
async def bulk_upload(session_id: str, body: BulkUpload):

    session = _get_session(session_id)

    validated = _validate_readings(body.readings)
    session["readings"].extend(validated)

    uid = session["userId"]
    cache = _live_cache.setdefault(uid, deque(maxlen=50))
    cache.extend(validated)

    return {
        "success": True,
        "data": {
            "accepted": len(validated),
            "discarded": len(body.readings) - len(validated),
        }
    }


@router.post("/ph/sessions/{session_id}/end")
async def end_session(session_id: str):

    session = _get_session(session_id)

    session["endedAt"] = datetime.now(timezone.utc).isoformat()
    session["summary"] = _compute_summary(session["readings"])

    return {"success": True, "data": session}


@router.get("/ph/live/{user_id}")
async def get_live(user_id: str):

    cache = _live_cache.get(user_id)

    if not cache:
        return {"success": True, "data": {"ph": None}}

    latest = list(cache)[-1]

    return {"success": True, "data": latest}


@router.get("/ph/search_device")
async def search_device():

    try:
        await asyncio.sleep(1)

        devices = [
            {"device": "AgriVora_pH_ESP32", "mac": "70:4B:CA:8D:A7:86", "status": "available"},
            {"device": "AgriVora_pH_Sensor_02", "mac": "12:34:56:78:9A:BC", "status": "available"},
            {"device": "SoilLab_Pro_03", "mac": "DE:AD:BE:EF:00:11", "status": "available"}
        ]

        return {"success": True, "data": {"devices": devices}}

    except Exception as e:
        return {"success": False, "error": str(e)}