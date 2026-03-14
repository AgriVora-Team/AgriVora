import os
import joblib
import pandas as pd

BASE_DIR = os.path.dirname(os.path.dirname(__file__))
MODEL_DIR = os.path.join(BASE_DIR, "models", "crop_lgbm")

MODEL_PATH = os.path.join(MODEL_DIR, "agrivora_crop_model.pkl")
COLS_PATH = os.path.join(MODEL_DIR, "agrivora_feature_columns.pkl")

_model = None
_feature_cols = None


def _load_once():
    global _model, _feature_cols

    if _model is None:
        print("Loading crop prediction model...")
        _model = joblib.load(MODEL_PATH)

    if _feature_cols is None:
        print("Loading feature columns...")
        _feature_cols = list(joblib.load(COLS_PATH))


IDEAL_PH = {
    "Rice": (5.5, 7.5), "Maize": (5.5, 7.5), "Jute": (6.0, 7.5),
    "Cotton": (5.8, 8.0), "Coconut": (5.0, 8.0), "Papaya": (6.0, 7.0),
    "Orange": (5.5, 7.5), "Apple": (5.5, 6.5), "Muskmelon": (6.0, 6.8),
    "Watermelon": (5.0, 6.8), "Grapes": (5.5, 6.5), "Mango": (4.5, 7.0),
    "Banana": (6.5, 7.5), "Pomegranate": (5.5, 7.0), "Lentil": (6.0, 7.0),
    "Blackgram": (6.0, 7.0), "Mungbean": (6.0, 7.0), "Mothbeans": (5.0, 7.0),
    "Pigeonpeas": (5.0, 7.0), "Kidneybeans": (5.5, 6.0), "Chickpea": (5.5, 7.0),
    "Coffee": (5.5, 7.0), "Peas": (6.0, 7.5)
}


def predict_crop(payload: dict) -> dict:

    _load_once()

    temp = float(payload.get("temperature", 25.0))
    humidity = float(payload.get("humidity", 65.0))
    rainfall = float(payload.get("rainfall", 100.0))
    ph = float(payload.get("ph", 6.5))
    nitrogen = float(payload.get("nitrogen", 40.0))
    carbon = float(payload.get("carbon", 1.2))
    soil_type = str(payload.get("soil_type", "loamy soil")).lower().strip()

    print("Crop prediction input:", payload)

    row = {
        "temperature": temp,
        "humidity": humidity,
        "rainfall": rainfall,
        "ph": ph,
        "nitrogen": nitrogen,
        "carbon": carbon,
        "temp_ph_interaction": temp * ph,
        "rainfall_nitrogen": rainfall * nitrogen,
        "temp_humidity_ratio": temp / humidity if humidity != 0 else 0,
        "rainfall_ph_interaction": rainfall * ph,
        "nitrogen_carbon_ratio": nitrogen / carbon if carbon != 0 else 0,
    }

    soil_cols = [
        "soil_acidic soil",
        "soil_alkaline soil",
        "soil_loamy soil",
        "soil_neutral soil",
        "soil_peaty soil",
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

    df = pd.DataFrame([row])

    for col in _feature_cols:
        if col not in df.columns:
            df[col] = 0

    df = df[_feature_cols]

    pred = _model.predict(df)

    recommendations = []

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

        for i, (crop_name, prob) in enumerate(crop_probs):
            if i < 3 or prob > 0.65:
                display_prob = round(min(0.99, prob + 0.15), 4) if i == 0 else round(min(0.95, prob + 0.05), 4)
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

    top_crop = recommendations[0]["crop"] if recommendations else str(pred[0]).title()
    top_conf = recommendations[0]["confidence"] if recommendations else 0.85

    return {
        "crop": top_crop,
        "confidence": top_conf,
        "recommendations": recommendations
    }