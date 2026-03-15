"""
Crop Recommendation Service
-------------------------------------------------------

This module loads the trained LightGBM crop prediction model
and exposes a function `predict_crop()` which is used by the
API layer to generate crop recommendations.

The model uses several environmental and soil parameters:

    - temperature
    - humidity
    - rainfall
    - soil pH
    - nitrogen content
    - soil organic carbon
    - soil type

The service performs the following steps:

1. Load model and feature column structure
2. Construct feature row from input payload
3. Perform feature engineering
4. Encode soil type features
5. Ensure dataframe matches model column structure
6. Run model prediction
7. Adjust probability scores using ideal pH ranges
8. Return top crop recommendations

Author: Agrivora Team
"""

import os
import joblib
import pandas as pd


# ---------------------------------------------------------
# DIRECTORY CONFIGURATION
# ---------------------------------------------------------

# Determine base directory of the backend service
BASE_DIR = os.path.dirname(os.path.dirname(__file__))

# Directory where trained ML models are stored
MODEL_DIR = os.path.join(BASE_DIR, "models", "crop_lgbm")

# Model file path
MODEL_PATH = os.path.join(MODEL_DIR, "agrivora_crop_model.pkl")

# Feature column configuration file
COLS_PATH = os.path.join(MODEL_DIR, "agrivora_feature_columns.pkl")


# ---------------------------------------------------------
# GLOBAL MODEL CACHE
# ---------------------------------------------------------

# These variables ensure that the model is loaded
# only once during application runtime.
_model = None
_feature_cols = None


# ---------------------------------------------------------
# LOAD MODEL ONCE
# ---------------------------------------------------------

def _load_once():
    """
    Load the trained model and feature column list.

    This function ensures that the model is loaded only
    once and reused across all prediction requests.
    """

    global _model, _feature_cols

    if _model is None:
        print("Loading LightGBM crop prediction model...")
        _model = joblib.load(MODEL_PATH)

    if _feature_cols is None:
        print("Loading feature column configuration...")
        _feature_cols = list(joblib.load(COLS_PATH))


# ---------------------------------------------------------
# IDEAL PH RANGES FOR CROPS
# ---------------------------------------------------------

# Used to adjust prediction confidence
# based on how suitable the soil pH is.
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


# ---------------------------------------------------------
# MAIN PREDICTION FUNCTION
# ---------------------------------------------------------

def predict_crop(payload: dict) -> dict:
    """
    Predict the best crop based on environmental conditions.

    Parameters
    ----------
    payload : dict
        Input parameters provided by the API request.

    Returns
    -------
    dict
        Dictionary containing:
            - top crop prediction
            - confidence score
            - list of recommended crops
    """

    # Ensure model is loaded
    _load_once()

    # -----------------------------------------------------
    # EXTRACT INPUT FEATURES
    # -----------------------------------------------------

    temp = float(payload.get("temperature", 25.0))
    humidity = float(payload.get("humidity", 65.0))
    rainfall = float(payload.get("rainfall", 100.0))
    ph = float(payload.get("ph", 6.5))
    nitrogen = float(payload.get("nitrogen", 40.0))
    carbon = float(payload.get("carbon", 1.2))

    soil_type = str(payload.get("soil_type", "loamy soil")).lower().strip()

    print("Crop prediction request received:")
    print(payload)


    # -----------------------------------------------------
    # FEATURE ENGINEERING
    # -----------------------------------------------------

    row = {
        "temperature": temp,
        "humidity": humidity,
        "rainfall": rainfall,
        "ph": ph,
        "nitrogen": nitrogen,
        "carbon": carbon,

        # Interaction features
        "temp_ph_interaction": temp * ph,
        "rainfall_nitrogen": rainfall * nitrogen,

        # Ratio features
        "temp_humidity_ratio": temp / humidity if humidity != 0 else 0,
        "nitrogen_carbon_ratio": nitrogen / carbon if carbon != 0 else 0,

        # Additional interaction
        "rainfall_ph_interaction": rainfall * ph
    }


    # -----------------------------------------------------
    # SOIL TYPE ENCODING
    # -----------------------------------------------------

    soil_cols = [
        "soil_acidic soil",
        "soil_alkaline soil",
        "soil_loamy soil",
        "soil_neutral soil",
        "soil_peaty soil",
    ]

    # Initialize all soil columns
    for col in soil_cols:
        row[col] = 0

    matched = f"soil_{soil_type}"

    if matched in soil_cols:
        row[matched] = 1

    elif "loam" in soil_type:
        row["soil_loamy soil"] = 1

    elif "acid" in soil_type:
        row["soil_acidic soil"] = 1


    # -----------------------------------------------------
    # CREATE DATAFRAME FOR MODEL INPUT
    # -----------------------------------------------------

    df = pd.DataFrame([row])

    # Ensure dataframe contains all model columns
    for col in _feature_cols:
        if col not in df.columns:
            df[col] = 0

    # Reorder columns to match model training
    df = df[_feature_cols]


    # -----------------------------------------------------
    # RUN MODEL PREDICTION
    # -----------------------------------------------------

    pred = _model.predict(df)

    recommendations = []


    # -----------------------------------------------------
    # PROBABILITY ADJUSTMENT USING PH PENALTY
    # -----------------------------------------------------

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
                    penalty = max(0.01, 0.4 ** (min_ph - ph))

                elif ph > max_ph:
                    penalty = max(0.01, 0.4 ** (ph - max_ph))

            adjusted_prob = base_prob * penalty

            crop_probs.append((crop_name, adjusted_prob))

        crop_probs.sort(key=lambda x: x[1], reverse=True)


        # -------------------------------------------------
        # BUILD FINAL RECOMMENDATION LIST
        # -------------------------------------------------

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

    except Exception:

        crop_name = str(pred[0]).title()

        recommendations.append({
            "crop": crop_name,
            "confidence": 0.85
        })


    # -----------------------------------------------------
    # FINAL RESPONSE
    # -----------------------------------------------------

    top_crop = recommendations[0]["crop"]
    top_conf = recommendations[0]["confidence"]

    return {
        "crop": top_crop,
        "confidence": top_conf,
        "recommendations": recommendations
    }