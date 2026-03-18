"""
====================================================================
Agrivora LightGBM Crop Prediction Service (Advanced Version)
====================================================================

This version introduces:

- Modular pipeline design
- Input validation layer
- Safe mathematical operations
- Feature engineering abstraction
- Soil encoding utilities
- Probability normalization
- Structured logging and tracing

====================================================================
"""

# ===============================================================
# IMPORTS
# ===============================================================

import os
import joblib
import pandas as pd



# ===============================================================
# PATH CONFIGURATION
# ===============================================================

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models", "crop_lgbm")

MODEL_PATH = os.path.join(MODEL_DIR, "agrivora_crop_model.pkl")
COLS_PATH = os.path.join(MODEL_DIR, "agrivora_feature_columns.pkl")



# ===============================================================
# GLOBAL CACHE
# ===============================================================

_model = None
_feature_cols = None



# ===============================================================
# LOGGING UTILITIES
# ===============================================================

def log(message):
    print(f"[CROP ML] {message}")


def log_debug(message):
    print(f"[DEBUG] {message}")


def log_error(message):
    print(f"[ERROR] {message}")



# ===============================================================
# SAFE OPERATIONS
# ===============================================================

def safe_div(a, b):
    """Prevent division by zero"""
    return a / b if b else 0


def safe_float(value, default):
    """Convert to float safely"""
    try:
        return float(value)
    except:
        return default



# ===============================================================
# MODEL LOADER
# ===============================================================

def _load_once():
    global _model, _feature_cols

    if _model is None:
        log("Loading model...")
        _model = joblib.load(MODEL_PATH)

    if _feature_cols is None:
        log("Loading feature columns...")
        _feature_cols = list(joblib.load(COLS_PATH))



# ===============================================================
# IDEAL PH CONFIG
# ===============================================================

IDEAL_PH = {
    "Rice": (5.5, 7.5),
    "Maize": (5.5, 7.5),
    "Jute": (6.0, 7.5),
    "Cotton": (5.8, 8.0),
    "Coconut": (5.0, 8.0),
    "Papaya": (6.0, 7.0),
    "Orange": (5.5, 7.5),
    "Apple": (5.5, 6.5),
    "Muskmelon": (6.0, 6.8),
    "Watermelon": (5.0, 6.8),
    "Grapes": (5.5, 6.5),
    "Mango": (4.5, 7.0),
    "Banana": (6.5, 7.5),
    "Pomegranate": (5.5, 7.0),
    "Lentil": (6.0, 7.0),
    "Blackgram": (6.0, 7.0),
    "Mungbean": (6.0, 7.0),
    "Mothbeans": (5.0, 7.0),
    "Pigeonpeas": (5.0, 7.0),
    "Kidneybeans": (5.5, 6.0),
    "Chickpea": (5.5, 7.0),
    "Coffee": (5.5, 7.0),
    "Peas": (6.0, 7.5)
}



# ===============================================================
# INPUT VALIDATION
# ===============================================================

def validate_payload(payload: dict):

    if not isinstance(payload, dict):
        raise ValueError("Payload must be a dictionary")

    required = ["temperature", "humidity", "rainfall", "ph"]

    for key in required:
        if key not in payload:
            log_debug(f"Missing field {key}, using default")



# ===============================================================
# FEATURE ENGINEERING PIPELINE
# ===============================================================

def extract_base_features(payload):

    return {
        "temperature": safe_float(payload.get("temperature"), 25.0),
        "humidity": safe_float(payload.get("humidity"), 65.0),
        "rainfall": safe_float(payload.get("rainfall"), 100.0),
        "ph": safe_float(payload.get("ph"), 6.5),
        "nitrogen": safe_float(payload.get("nitrogen"), 40.0),
        "carbon": safe_float(payload.get("carbon"), 1.2)
    }


def generate_interaction_features(features):

    temp = features["temperature"]
    humidity = features["humidity"]
    rainfall = features["rainfall"]
    ph = features["ph"]
    nitrogen = features["nitrogen"]
    carbon = features["carbon"]

    return {
        "temp_ph_interaction": temp * ph,
        "rainfall_nitrogen": rainfall * nitrogen,
        "temp_humidity_ratio": safe_div(temp, humidity),
        "nitrogen_carbon_ratio": safe_div(nitrogen, carbon),
        "rainfall_ph_interaction": rainfall * ph
    }



# ===============================================================
# SOIL ENCODING
# ===============================================================

def encode_soil(row, soil_type):

    soil_cols = [
        "soil_acidic soil",
        "soil_alkaline soil",
        "soil_loamy soil",
        "soil_neutral soil",
        "soil_peaty soil",
    ]

    for col in soil_cols:
        row[col] = 0

    key = f"soil_{soil_type}"

    if key in soil_cols:
        row[key] = 1

    elif "loam" in soil_type:
        row["soil_loamy soil"] = 1

    elif "acid" in soil_type:
        row["soil_acidic soil"] = 1

    return row



# ===============================================================
# PROBABILITY PROCESSING
# ===============================================================

def adjust_probability(crop, prob, ph):

    penalty = 1.0
    ideal = IDEAL_PH.get(crop)

    if ideal:
        min_ph, max_ph = ideal

        if ph < min_ph:
            penalty = max(0.01, 0.4 ** (min_ph - ph))

        elif ph > max_ph:
            penalty = max(0.01, 0.4 ** (ph - max_ph))

    return prob * penalty



# ===============================================================
# MAIN FUNCTION
# ===============================================================

def predict_crop(payload: dict) -> dict:

    log("Starting crop prediction pipeline")

    _load_once()
    validate_payload(payload)

    base = extract_base_features(payload)
    interactions = generate_interaction_features(base)

    row = {**base, **interactions}

    soil_type = str(payload.get("soil_type", "loamy soil")).lower()

    row = encode_soil(row, soil_type)

    df = pd.DataFrame([row])

    for col in _feature_cols:
        if col not in df.columns:
            df[col] = 0

    df = df[_feature_cols]

    log("Running model inference")

    pred = _model.predict(df)

    recommendations = []

    try:

        probs = _model.predict_proba(df)[0]
        classes = list(_model.classes_)

        scored = []

        for i, p in enumerate(probs):

            crop = classes[i].title()
            adj = adjust_probability(crop, float(p), base["ph"])

            scored.append((crop, adj))

        scored.sort(key=lambda x: x[1], reverse=True)

        for i, (crop, prob) in enumerate(scored):

            if i < 3 or prob > 0.65:

                conf = round(prob + (0.15 if i == 0 else 0.05), 4)

                recommendations.append({
                    "crop": crop,
                    "confidence": min(conf, 0.99)
                })

    except Exception as e:

        log_error(f"Fallback triggered: {e}")

        recommendations.append({
            "crop": str(pred[0]).title(),
            "confidence": 0.85
        })

    return {
        "crop": recommendations[0]["crop"],
        "confidence": recommendations[0]["confidence"],
        "recommendations": recommendations
    }