from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime, timedelta
from app.utils.firestore import db
from app.utils.email import send_otp_email
import uuid
import hashlib
import bcrypt
import random

router = APIRouter()


class SignUpRequest(BaseModel):
    full_name: str = Field(..., min_length=1)
    email: EmailStr
    phone: str = Field(..., min_length=6)
    password: str = Field(..., min_length=8)


class LoginRequest(BaseModel):
    email_or_phone: str = Field(..., min_length=1)
    password: str = Field(..., min_length=8)


class RequestOTPRequest(BaseModel):
    email: EmailStr


class VerifyOTPRequest(BaseModel):
    email: EmailStr
    otp: str


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp: str
    new_password: str = Field(..., min_length=8)


def normalize_email(email: str) -> str:
    return email.strip().lower()


def normalize_phone(phone: str) -> str:
    return phone.strip()


def _pw_digest(password: str) -> bytes:
    return hashlib.sha256(password.encode("utf-8")).digest()


def hash_password(password: str) -> str:
    hashed = bcrypt.hashpw(_pw_digest(password), bcrypt.gensalt())
    return hashed.decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(_pw_digest(plain_password), hashed_password.encode("utf-8"))


@router.post("/signup")
def create_account(data: SignUpRequest):
    try:
        users_ref = db.collection("users")

        full_name = data.full_name.strip()
        email = normalize_email(data.email)
        phone = normalize_phone(data.phone)

        existing_email = users_ref.where("email", "==", email).limit(1).stream()
        for _ in existing_email:
            raise HTTPException(status_code=400, detail="Email already registered")

        existing_phone = users_ref.where("phone", "==", phone).limit(1).stream()
        for _ in existing_phone:
            raise HTTPException(status_code=400, detail="Phone number already registered")

        user_id = str(uuid.uuid4())
        password_hash = hash_password(data.password)

        users_ref.document(user_id).set({
            "full_name": full_name,
            "email": email,
            "phone": phone,
            "password_hash": password_hash,
            "role": None,
            "acceptedTerms": False,
            "onboardingCompleted": False,
            "createdAt": datetime.utcnow(),
        })

        return {
            "success": True,
            "message": "Account created successfully",
            "user_id": user_id,
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


@router.post("/login")
def login_user(data: LoginRequest):
    try:
        users_ref = db.collection("users")

        identifier = data.email_or_phone.strip()
        password = data.password
        user_doc = None

        query = users_ref.where("email", "==", identifier.lower()).limit(1).stream()
        for doc in query:
            user_doc = doc
            break

        if not user_doc:
            query = users_ref.where("phone", "==", identifier).limit(1).stream()
            for doc in query:
                user_doc = doc
                break

        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")

        user_data = user_doc.to_dict()
        stored_hash = user_data.get("password_hash") or user_data.get("password")

        if not stored_hash:
            raise HTTPException(status_code=500, detail="Server error: password hash missing")

        if not verify_password(password, stored_hash):
            raise HTTPException(status_code=401, detail="Invalid password")

        return {
            "success": True,
            "message": "Login successful",
            "user_id": user_doc.id,
            "full_name": user_data.get("full_name"),
            "email": user_data.get("email"),
            "phone": user_data.get("phone"),
            "role": user_data.get("role"),
            "onboardingCompleted": user_data.get("onboardingCompleted", False),
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


@router.post("/forgot-password/request-otp")
def request_otp(data: RequestOTPRequest):
    try:
        email = normalize_email(data.email)
        users_ref = db.collection("users")

        user_query = users_ref.where("email", "==", email).limit(1).stream()
        user_found = False
        for _ in user_query:
            user_found = True
            break

        if not user_found:
            raise HTTPException(status_code=404, detail="User with this email not found")

        otp = str(random.randint(100000, 999999))

        db.collection("otps").document(email).set({
            "email": email,
            "otp": otp,
            "createdAt": datetime.utcnow(),
            "expiresAt": datetime.utcnow() + timedelta(minutes=10),
        })

        success = send_otp_email(email, otp)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to send email. Check SMTP settings.")

        return {
            "success": True,
            "message": "OTP sent to your email",
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


@router.post("/forgot-password/verify-otp")
def verify_otp_endpoint(data: VerifyOTPRequest):
    try:
        email = normalize_email(data.email)
        otp = data.otp.strip()

        otp_doc = db.collection("otps").document(email).get()
        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="No OTP requested for this email")

        otp_data = otp_doc.to_dict()

        if datetime.utcnow().timestamp() > otp_data["expiresAt"].timestamp():
            raise HTTPException(status_code=400, detail="OTP has expired")

        if otp_data["otp"] != otp:
            raise HTTPException(status_code=400, detail="Invalid OTP")

        return {
            "success": True,
            "message": "OTP verified successfully",
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


@router.post("/forgot-password/reset")
def reset_password_endpoint(data: ResetPasswordRequest):
    try:
        email = normalize_email(data.email)
        otp = data.otp.strip()
        new_password = data.new_password

        otp_doc = db.collection("otps").document(email).get()
        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="Invalid request")

        otp_data = otp_doc.to_dict()
        if otp_data["otp"] != otp or datetime.utcnow().timestamp() > otp_data["expiresAt"].timestamp():
            raise HTTPException(status_code=400, detail="OTP expired or invalid")

        users_ref = db.collection("users")
        user_query = users_ref.where("email", "==", email).limit(1).stream()

        user_id = None
        for doc in user_query:
            user_id = doc.id
            break

        if not user_id:
            raise HTTPException(status_code=404, detail="User not found")

        users_ref.document(user_id).update({
            "password_hash": hash_password(new_password)
        })

        db.collection("otps").document(email).delete()

        return {
            "success": True,
            "message": "Password reset successfully",
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")