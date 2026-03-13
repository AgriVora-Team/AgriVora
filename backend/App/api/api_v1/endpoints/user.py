from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

from app.utils.firestore import db
from app.api.api_v1.endpoints.auth import hash_password, verify_password

router = APIRouter()


# ==========================================
# PROFILE RESPONSE MODEL
# ==========================================

class UserProfile(BaseModel):
    user_id: str
    full_name: str
    email: EmailStr
    phone: str
    role: Optional[str]


# ==========================================
# REQUEST MODELS
# ==========================================

class EditProfile(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None


class PasswordUpdate(BaseModel):
    old_password: str
    new_password: str


# ==========================================
# FETCH USER PROFILE
# ==========================================

@router.get("/profile/{user_id}")
def fetch_profile(user_id: str):

    user_doc = db.collection("users").document(user_id).get()

    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    user = user_doc.to_dict()

    return {
        "success": True,
        "profile": {
            "user_id": user_id,
            "full_name": user.get("full_name"),
            "email": user.get("email"),
            "phone": user.get("phone"),
            "role": user.get("role")
        }
    }


# ==========================================
# EDIT PROFILE
# ==========================================

@router.put("/profile/{user_id}")
def edit_profile(user_id: str, payload: EditProfile):

    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()

    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User does not exist")

    updates = {}

    if payload.full_name:
        updates["full_name"] = payload.full_name

    if payload.phone:
        updates["phone"] = payload.phone

    updates["updated_at"] = datetime.utcnow()

    user_ref.update(updates)

    return {
        "success": True,
        "message": "Profile information updated"
    }


# ==========================================
# UPDATE PASSWORD
# ==========================================

@router.put("/profile/{user_id}/password")
def update_password(user_id: str, payload: PasswordUpdate):

    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()

    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    user_data = user_doc.to_dict()
    current_hash = user_data.get("password_hash")

    if not current_hash or not verify_password(payload.old_password, current_hash):
        raise HTTPException(status_code=400, detail="Old password is incorrect")

    new_hash = hash_password(payload.new_password)

    user_ref.update({
        "password_hash": new_hash,
        "updated_at": datetime.utcnow()
    })

    return {
        "success": True,
        "message": "Password changed successfully"
    }