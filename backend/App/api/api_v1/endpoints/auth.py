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

# =====================================================
# REQUEST SCHEMAS
# =====================================================

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


# =====================================================
# HELPER FUNCTIONS
# =====================================================

def normalize_email(email: str) -> str:
    return email.strip().lower()

def normalize_phone(phone: str) -> str:
    return phone.strip()

def _pw_digest(password: str) -> bytes:
    return hashlib.sha256(password.encode("utf-8")).digest()

def hash_password(password: str) -> str:
    digest = _pw_digest(password)
    hashed = bcrypt.hashpw(digest, bcrypt.gensalt())
    return hashed.decode("utf-8")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    digest = _pw_digest(plain_password)
    return bcrypt.checkpw(digest, hashed_password.encode("utf-8"))

def get_user_by_email(email: str):
    query = db.collection("users").where("email", "==", email).limit(1).stream()
    for doc in query:
        return doc
    return None

def get_user_by_phone(phone: str):
    query = db.collection("users").where("phone", "==", phone).limit(1).stream()
    for doc in query:
        return doc
    return None

def generate_otp() -> str:
    return str(random.randint(100000, 999999))

def get_otp_doc(email: str):
    return db.collection("otps").document(email).get()

def save_otp(email: str, otp: str):
    now = datetime.utcnow()
    db.collection("otps").document(email).set({
        "email": email,
        "otp": otp,
        "createdAt": now,
        "expiresAt": now + timedelta(minutes=10)
    })


# =====================================================
# SIGNUP ENDPOINT
# =====================================================

@router.post("/signup")
def create_account(data: SignUpRequest):
    try:
        users_ref = db.collection("users")

        full_name = data.full_name.strip()
        email = normalize_email(data.email)
        phone = normalize_phone(data.phone)
        password = data.password

        if get_user_by_email(email):
            raise HTTPException(status_code=400, detail="Email already registered")

        if get_user_by_phone(phone):
            raise HTTPException(status_code=400, detail="Phone number already registered")

        user_id = str(uuid.uuid4())
        password_hash = hash_password(password)

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


# =====================================================
# LOGIN ENDPOINT
# =====================================================

@router.post("/login")
def login_user(data: LoginRequest):
    try:
        identifier = data.email_or_phone.strip()
        password = data.password

        user_doc = get_user_by_email(identifier.lower())
        if not user_doc:
            user_doc = get_user_by_phone(identifier)

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


# =====================================================
# FORGOT PASSWORD - REQUEST OTP
# =====================================================

@router.post("/forgot-password/request-otp")
def request_otp(data: RequestOTPRequest):
    try:
        email = normalize_email(data.email)

        if not get_user_by_email(email):
            raise HTTPException(status_code=404, detail="User with this email not found")

        otp = generate_otp()
        save_otp(email, otp)

        success = send_otp_email(email, otp)
        if not success:
            raise HTTPException(status_code=500, detail="Failed to send email. Check SMTP settings.")

        return {
            "success": True,
            "message": "OTP sent to your email"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


# =====================================================
# FORGOT PASSWORD - VERIFY OTP
# =====================================================

@router.post("/forgot-password/verify-otp")
def verify_otp_endpoint(data: VerifyOTPRequest):
    try:
        email = normalize_email(data.email)
        otp = data.otp.strip()

        otp_doc = get_otp_doc(email)
        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="No OTP requested for this email")

        otp_data = otp_doc.to_dict()

        if datetime.utcnow().timestamp() > otp_data["expiresAt"].timestamp():
            raise HTTPException(status_code=400, detail="OTP has expired")

        if otp_data["otp"] != otp:
            raise HTTPException(status_code=400, detail="Invalid OTP")

        return {
            "success": True,
            "message": "OTP verified successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}")


# =====================================================
# FORGOT PASSWORD - RESET
# =====================================================

@router.post("/forgot-password/reset")
def reset_password_endpoint(data: ResetPasswordRequest):
    try:
        email = normalize_email(data.email)
        otp = data.otp.strip()
        new_password = data.new_password

        otp_doc = get_otp_doc(email)
        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="Invalid request")

        otp_data = otp_doc.to_dict()
        if otp_data["otp"] != otp or datetime.utcnow().timestamp() > otp_data["expiresAt"].timestamp():
            raise HTTPException(status_code=400, detail="OTP expired or invalid")

        user_doc = get_user_by_email(email)
        if not user_doc:
            raise HTTPException(status_code=404, detail="User not found")

        db.collection("users").document(user_doc.id).update({
            "password_hash": hash_password(new_password)
        })

        db.collection("otps").document(email).delete()

        return {
            "success": True,
            "message": "Password reset successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Server error: {str(e)}") # small update
