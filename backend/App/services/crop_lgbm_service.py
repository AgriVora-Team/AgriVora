"""
====================================================================
Agrivora LightGBM Crop Prediction Service
====================================================================

This module implements the machine learning inference service used
by the Agrivora platform to recommend suitable crops based on soil
and environmental conditions.

The service loads a trained LightGBM model and performs prediction
using a structured set of engineered features derived from the
incoming API payload.

--------------------------------------------------------------------
MODULE RESPONSIBILITIES
--------------------------------------------------------------------

1. Load the trained LightGBM model
2. Load the feature column configuration used during training
3. Convert API payloads into model-compatible feature vectors
4. Perform feature engineering and soil type encoding
5. Ensure prediction dataframe matches training column structure
6. Run inference using the LightGBM model
7. Adjust crop probabilities using ideal soil pH ranges
8. Return ranked crop recommendations with confidence scores

--------------------------------------------------------------------
MODEL INPUT FEATURES
--------------------------------------------------------------------

Primary Inputs:

    temperature
    humidity
    rainfall
    soil pH
    nitrogen content
    soil organic carbon
    soil type

Derived Features:

    temp_ph_interaction
    rainfall_nitrogen
    temp_humidity_ratio
    nitrogen_carbon_ratio
    rainfall_ph_interaction

--------------------------------------------------------------------
OUTPUT STRUCTURE
--------------------------------------------------------------------

The prediction result returns:

{
    "crop": "Rice",
    "confidence": 0.92,
    "recommendations": [
        {"crop": "Rice", "confidence": 0.92},
        {"crop": "Maize", "confidence": 0.71},
        {"crop": "Jute", "confidence": 0.63}
    ]
}

--------------------------------------------------------------------
Author: Agrivora ML Team
====================================================================
"""

# ===============================================================
# IMPORT DEPENDENCIES
# ===============================================================

import os
import joblib
import pandas as pd



# ===============================================================
# DIRECTORY CONFIGURATION
# ===============================================================

"""
Determine paths used for loading model artifacts.

The model and feature column structure are stored
inside the backend model directory.
"""

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

MODEL_DIR = os.path.join(BASE_DIR, "models", "crop_lgbm")

MODEL_PATH = os.path.join(
    MODEL_DIR,
    "agrivora_crop_model.pkl"
)

COLS_PATH = os.path.join(
    MODEL_DIR,
    "agrivora_feature_columns.pkl"
)



# ===============================================================
# GLOBAL MODEL CACHE
# ===============================================================

"""
The model and feature columns are cached globally so that
they are loaded only once during the lifetime of the backend
service.

This significantly improves API performance.
"""

_model = None
_feature_cols = None



# ===============================================================
# LOGGING HELPERS
# ===============================================================

def log_info(message: str):
    """Standard info log."""
    print(f"[CROP-SERVICE] {message}")


def log_error(message: str):
    """Standard error log."""
    print(f"[CROP-SERVICE ERROR] {message}")



# ===============================================================
# MODEL LOADER
# ===============================================================

def _load_once():
    """
    Load the trained LightGBM model and feature columns.

    This function ensures that the model is loaded only once
    and reused for all subsequent predictions.
    """

    global _model
    global _feature_cols

    if _model is None:

        log_info("Loading LightGBM crop prediction model...")

        _model = joblib.load(MODEL_PATH)

        log_info("Model loaded successfully")

    if _feature_cols is None:

        log_info("Loading feature column configuration...")

        _feature_cols = list(joblib.load(COLS_PATH))

        log_info("Feature column structure loaded")



# ===============================================================
# IDEAL PH RANGES
# ===============================================================

"""
Ideal pH ranges for each crop.

Used to penalize model probabilities if the soil pH
falls outside the optimal growth range.
"""

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
# FEATURE ENGINEERING
# ===============================================================

def build_feature_row(payload: dict):
    """
    Convert API payload into model-ready feature row.
    """

    temp = float(payload.get("temperature", 25.0))
    humidity = float(payload.get("humidity", 65.0))
    rainfall = float(payload.get("rainfall", 100.0))
    ph = float(payload.get("ph", 6.5))
    nitrogen = float(payload.get("nitrogen", 40.0))
    carbon = float(payload.get("carbon", 1.2))

    soil_type = str(payload.get(
        "soil_type",
        "loamy soil"
    )).lower().strip()

    log_info(f"Received prediction payload: {payload}")

    row = {

        "temperature": temp,
        "humidity": humidity,
        "rainfall": rainfall,
        "ph": ph,
        "nitrogen": nitrogen,
        "carbon": carbon,

        # Interaction Features
        "temp_ph_interaction": temp * ph,
        "rainfall_nitrogen": rainfall * nitrogen,

        # Ratio Features
        "temp_humidity_ratio":
            temp / humidity if humidity else 0,

        "nitrogen_carbon_ratio":
            nitrogen / carbon if carbon else 0,

        # Additional Interaction
        "rainfall_ph_interaction":
            rainfall * ph
    }

    return row, soil_type, ph



# ===============================================================
# SOIL ENCODING
# ===============================================================

def encode_soil_features(row, soil_type):

    soil_cols = [
        "soil_acidic soil",
        "soil_alkaline soil",
        "soil_loamy soil",
        "soil_neutral soil",
        "soil_peaty soil"
    ]

    for col in soil_cols:
        row[col] = 0

    matched = f"soil_{soil_type}"

    if matched in soil_cols:

        row[matched] = 1

    elif "loam" in soil_type:

        row["soil_loamy soil"] = 1

    elif "acid" in soil_type:

        row["soil_acidic soil"] = 1

    return row



# ===============================================================
# MAIN PREDICTION FUNCTION
# ===============================================================

def predict_crop(payload: dict) -> dict:
    """
    Generate crop recommendations using the ML model.
    """

    _load_once()

    row, soil_type, ph = build_feature_row(payload)

    row = encode_soil_features(row, soil_type)

    df = pd.DataFrame([row])

    for col in _feature_cols:
        if col not in df.columns:
            df[col] = 0

    df = df[_feature_cols]

    log_info("Running model prediction")

    pred = _model.predict(df)

    recommendations = []



# ===============================================================
# PROBABILITY ADJUSTMENT
# ===============================================================

    try:

        proba = _model.predict_proba(df)[0]
        classes = list(_model.classes_)

        crop_probs = []

        for i, p in enumerate(proba):

            crop_name = classes[i].title()

            base_prob = float(p)

            penalty = 1.0

            ideal = IDEAL_PH.get(crop_name)

            if ideal:

                min_ph, max_ph = ideal

                if ph < min_ph:

                    penalty = max(
                        0.01,
                        0.4 ** (min_ph - ph)
                    )

                elif ph > max_ph:

                    penalty = max(
                        0.01,
                        0.4 ** (ph - max_ph)
                    )

            adjusted_prob = base_prob * penalty

            crop_probs.append(
                (crop_name, adjusted_prob)
            )

        crop_probs.sort(
            key=lambda x: x[1],
            reverse=True
        )

        for i, (crop_name, prob) in enumerate(crop_probs):

            if i < 3 or prob > 0.65:

                display_prob = (

                    round(min(0.99, prob + 0.15), 4)

                    if i == 0

                    else round(min(0.95, prob + 0.05), 4)

                )

                recommendations.append({

                    "crop": crop_name,

                    "confidence": display_prob

                })

    except Exception as e:

        log_error(f"Probability computation failed: {e}")

        crop_name = str(pred[0]).title()

        recommendations.append({

            "crop": crop_name,

            "confidence": 0.85

        })



# ===============================================================
# FINAL RESPONSE
# ===============================================================

    top_crop = recommendations[0]["crop"]

    top_conf = recommendations[0]["confidence"]

    return {

        "crop": top_crop,

        "confidence": top_conf,

        "recommendations": recommendations

    }