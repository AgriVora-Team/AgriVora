from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from typing import Optional
from app.utils.firestore import db
from datetime import datetime
from app.api.api_v1.endpoints.auth import hash_password, verify_password

router = APIRouter()


class ProfileResponse(BaseModel):
    user_id: str
    full_name: str
    email: EmailStr
    phone: str
    role: Optional[str]


class UpdateProfileRequest(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str


def success_response(message: Optional[str] = None, data=None):
    return {
        "success": True,
        "message": message,
        "data": data,
        "error": None
    }


def get_user_document(user_id: str):
    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()
    return user_ref, user_doc


def build_profile_data(user_id: str, user_data: dict):
    return {
        "user_id": user_id,
        "full_name": user_data.get("full_name"),
        "email": user_data.get("email"),
        "phone": user_data.get("phone"),
        "role": user_data.get("role")
    }


def build_profile_update_data(data: UpdateProfileRequest):
    update_data = {}

    if data.full_name is not None:
        update_data["full_name"] = data.full_name

    if data.phone is not None:
        update_data["phone"] = data.phone

    update_data["updatedAt"] = datetime.utcnow()
    return update_data


@router.get("/profile/{user_id}")
def get_profile(user_id: str):
    _, user_doc = get_user_document(user_id)

    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    return success_response(
        data=build_profile_data(user_id, user_doc.to_dict())
    )


@router.put("/profile/{user_id}")
def update_profile(user_id: str, data: UpdateProfileRequest):
    user_ref, user_doc = get_user_document(user_id)

    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = build_profile_update_data(data)
    user_ref.update(update_data)

    return success_response(message="Profile updated successfully")


@router.put("/{user_id}/change-password")
def change_password(user_id: str, data: ChangePasswordRequest):
    user_ref, user_doc = get_user_document(user_id)

    if not user_doc.exists:
        raise HTTPException(status_code=404, detail="User not found")

    user_data = user_doc.to_dict()
    stored_hash = user_data.get("password_hash")

    if not stored_hash or not verify_password(data.old_password, stored_hash):
        raise HTTPException(status_code=400, detail="Incorrect old password")

    user_ref.update({
        "password_hash": hash_password(data.new_password),
        "updatedAt": datetime.utcnow()
    })

    return success_response(message="Password updated successfully")