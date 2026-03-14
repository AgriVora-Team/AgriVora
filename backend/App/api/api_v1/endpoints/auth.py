# FastAPI authentication module handling signup, login, OTP verification and password reset

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

# Authentication router for signup, login, OTP verification and password reset


# =========================================
# DATA MODELS
# =========================================

class RegisterUser(BaseModel):
    full_name: str = Field(..., min_length=1)
    email: EmailStr
    phone: str = Field(..., min_length=6)
    password: str = Field(..., min_length=8)


class LoginUser(BaseModel):
    email_or_phone: str = Field(..., min_length=1)
    password: str = Field(..., min_length=8)


class OTPRequest(BaseModel):
    email: EmailStr


class OTPVerify(BaseModel):
    email: EmailStr
    otp: str


class PasswordReset(BaseModel):
    email: EmailStr
    otp: str
    new_password: str = Field(..., min_length=8)


# =========================================
# PASSWORD UTILITIES
# =========================================

def create_digest(password: str) -> bytes:
    """Generate SHA256 digest to avoid bcrypt length issues."""
    return hashlib.sha256(password.encode()).digest()


def hash_password(password: str) -> str:
    digest = create_digest(password)
    hashed_pw = bcrypt.hashpw(digest, bcrypt.gensalt())
    return hashed_pw.decode()


def verify_password(password: str, stored_hash: str) -> bool:
    digest = create_digest(password)
    return bcrypt.checkpw(digest, stored_hash.encode())


# =========================================
# DATABASE HELPER
# =========================================

# Helper function to retrieve user records from Firestore

def get_user_by_field(field: str, value: str):
    query = db.collection("users").where(field, "==", value).limit(1).stream()
    for doc in query:
        return doc
    return None


# =========================================
# USER REGISTRATION
# =========================================

@router.post("/signup")
def signup(user: RegisterUser):
    """Register a new user and store credentials securely."""
    try:
        users_ref = db.collection("users")

        name = user.full_name.strip()
        email = user.email.strip().lower()
        phone = user.phone.strip()

        if get_user_by_field("email", email):
            raise HTTPException(status_code=400, detail="Email already exists")

        if get_user_by_field("phone", phone):
            raise HTTPException(status_code=400, detail="Phone already exists")

        user_id = str(uuid.uuid4())
        password_hash = hash_password(user.password)

        users_ref.document(user_id).set(
            {
                "full_name": name,
                "email": email,
                "phone": phone,
                "password_hash": password_hash,
                "role": None,
                "acceptedTerms": False,
                "onboardingCompleted": False,
                "created_at": datetime.utcnow(),
            }
        )

        return {
            "success": True,
            "message": "User registered successfully",
            "user_id": user_id,
        }

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))


# =========================================
# USER LOGIN
# =========================================

@router.post("/login")
def login(user: LoginUser):
    """Authenticate user using email or phone and verify password."""
    try:
        identifier = user.email_or_phone.strip()
        password = user.password

        user_doc = get_user_by_field("email", identifier.lower())

        if not user_doc:
            user_doc = get_user_by_field("phone", identifier)

        if not user_doc:
            raise HTTPException(status_code=404, detail="Account not found")

        user_data = user_doc.to_dict()
        stored_hash = user_data.get("password_hash")

        if not verify_password(password, stored_hash):
            raise HTTPException(status_code=401, detail="Incorrect password")

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
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))


# =========================================
# REQUEST OTP
# =========================================

# OTP generation and validation for password recovery

@router.post("/forgot-password/request-otp")
def request_otp(data: OTPRequest):
    try:
        email = data.email.strip().lower()

        if not get_user_by_field("email", email):
            raise HTTPException(status_code=404, detail="Email not registered")

        otp_code = str(random.randint(100000, 999999))

        db.collection("otps").document(email).set(
            {
                "email": email,
                "otp": otp_code,
                "created_at": datetime.utcnow(),
                "expires_at": datetime.utcnow() + timedelta(minutes=10),
            }
        )

        if not send_otp_email(email, otp_code):
            raise HTTPException(status_code=500, detail="Email sending failed")

        return {"success": True, "message": "OTP sent"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))


# =========================================
# VERIFY OTP
# =========================================

@router.post("/forgot-password/verify-otp")
def verify_otp(data: OTPVerify):
    try:
        email = data.email.strip().lower()
        otp_input = data.otp.strip()

        otp_doc = db.collection("otps").document(email).get()

        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="OTP not found")

        otp_data = otp_doc.to_dict()

        if datetime.utcnow() > otp_data["expires_at"]:
            raise HTTPException(status_code=400, detail="OTP expired")

        if otp_data["otp"] != otp_input:
            raise HTTPException(status_code=400, detail="Invalid OTP")

        return {"success": True, "message": "OTP verified"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))


# =========================================
# RESET PASSWORD
# =========================================

@router.post("/forgot-password/reset")
def reset_password(data: PasswordReset):
    try:
        email = data.email.strip().lower()
        otp = data.otp.strip()

        otp_doc = db.collection("otps").document(email).get()

        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="Invalid reset request")

        otp_data = otp_doc.to_dict()

        if otp_data["otp"] != otp or datetime.utcnow() > otp_data["expires_at"]:
            raise HTTPException(status_code=400, detail="OTP invalid or expired")

        user_doc = get_user_by_field("email", email)

        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")

        db.collection("users").document(user_doc.id).update(
            {"password_hash": hash_password(data.new_password)}
        )

        db.collection("otps").document(email).delete()

        return {"success": True, "message": "Password updated successfully"}

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))