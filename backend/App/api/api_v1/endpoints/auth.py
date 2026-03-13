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

def _create_digest(password: str) -> bytes:
    """Generate fixed SHA256 digest to avoid bcrypt length issues."""
    return hashlib.sha256(password.encode()).digest()

def generate_hash(password: str) -> str:
    digest = _create_digest(password)
    hashed_pw = bcrypt.hashpw(digest, bcrypt.gensalt())
    return hashed_pw.decode()

def check_password(password: str, stored_hash: str) -> bool:
    digest = _create_digest(password)
    return bcrypt.checkpw(digest, stored_hash.encode())


# =========================================
# USER REGISTRATION
# =========================================

@router.post("/signup")
def signup(user: RegisterUser):
    try:
        users = db.collection("users")

        name = user.full_name.strip()
        email = user.email.strip().lower()
        phone = user.phone.strip()
        password = user.password

        # Check duplicate email
        if list(users.where("email", "==", email).limit(1).stream()):
            raise HTTPException(status_code=400, detail="Email already exists")

        # Check duplicate phone
        if list(users.where("phone", "==", phone).limit(1).stream()):
            raise HTTPException(status_code=400, detail="Phone already exists")

        user_id = str(uuid.uuid4())
        pw_hash = generate_hash(password)

        users.document(user_id).set({
            "full_name": name,
            "email": email,
            "phone": phone,
            "password_hash": pw_hash,
            "role": None,
            "acceptedTerms": False,
            "onboardingCompleted": False,
            "created_at": datetime.utcnow()
        })

        return {
            "success": True,
            "message": "User registered successfully",
            "user_id": user_id
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
    try:
        users = db.collection("users")

        identifier = user.email_or_phone.strip()
        password = user.password
        user_doc = None

        # Search by email
        result = users.where("email", "==", identifier.lower()).limit(1).stream()
        for doc in result:
            user_doc = doc

        # If not found try phone
        if not user_doc:
            result = users.where("phone", "==", identifier).limit(1).stream()
            for doc in result:
                user_doc = doc

        if not user_doc:
            raise HTTPException(status_code=404, detail="Account not found")

        data = user_doc.to_dict()
        stored_hash = data.get("password_hash")

        if not check_password(password, stored_hash):
            raise HTTPException(status_code=401, detail="Incorrect password")

        return {
            "success": True,
            "message": "Login successful",
            "user_id": user_doc.id,
            "full_name": data.get("full_name"),
            "email": data.get("email"),
            "phone": data.get("phone"),
            "role": data.get("role"),
            "onboardingCompleted": data.get("onboardingCompleted", False)
        }

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))


# =========================================
# REQUEST OTP
# =========================================

@router.post("/forgot-password/request-otp")
def send_otp(data: OTPRequest):
    try:
        email = data.email.strip().lower()
        users = db.collection("users")

        # Check user
        if not list(users.where("email", "==", email).limit(1).stream()):
            raise HTTPException(status_code=404, detail="Email not registered")

        otp_code = str(random.randint(100000, 999999))

        db.collection("otps").document(email).set({
            "email": email,
            "otp": otp_code,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(minutes=10)
        })

        if not send_otp_email(email, otp_code):
            raise HTTPException(status_code=500, detail="Email sending failed")

        return {
            "success": True,
            "message": "OTP sent"
        }

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

        return {
            "success": True,
            "message": "OTP verified"
        }

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
        new_password = data.new_password

        otp_doc = db.collection("otps").document(email).get()

        if not otp_doc.exists:
            raise HTTPException(status_code=400, detail="Invalid reset request")

        otp_data = otp_doc.to_dict()

        if otp_data["otp"] != otp or datetime.utcnow() > otp_data["expires_at"]:
            raise HTTPException(status_code=400, detail="OTP invalid or expired")

        users = db.collection("users")
        query = users.where("email", "==", email).limit(1).stream()

        user_id = None
        for doc in query:
            user_id = doc.id

        if not user_id:
            raise HTTPException(status_code=404, detail="User not found")

        users.document(user_id).update({
            "password_hash": generate_hash(new_password)
        })

        db.collection("otps").document(email).delete()

        return {
            "success": True,
            "message": "Password updated successfully"
        }

    except HTTPException:
        raise
    except Exception as err:
        raise HTTPException(status_code=500, detail=str(err))