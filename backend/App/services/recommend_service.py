import joblib
import numpy as np
import os

MODEL_PATH = os.path.join("app", "models", "rf_model.pkl")

rf_model = None
model_error = None

try:
    rf_model = joblib.load(MODEL_PATH)
except Exception as e:
    model_error = str(e)

CROP_LABELS = ["Rice", "Maize", "Wheat", "Chili", "Potato"]

def recommend_crops(features: dict):
    try:
        if rf_model is None:
            # Fallback if model fails to load
            return [
                {
                    "name": "Rice",
                    "score": 0.75,
                    "reasons": ["Model unavailable – fallback used"],
                    "tips": ["Apply organic compost"]
                }
            ], None

        X = np.array([[
            features["soil"]["sand"],
            features["soil"]["clay"],
            features["soil"]["organicCarbon"],
            features["weather"]["temperature"],
            features["weather"]["rainfall"],
            features["weather"]["humidity"],
            features["ph"]
        ]])

        probs = rf_model.predict_proba(X)[0]

        ranked = sorted(
            zip(CROP_LABELS, probs),
            key=lambda x: x[1],
            reverse=True
        )

        recommendations = []
        for crop, score in ranked[:3]:
            recommendations.append({
                "name": crop,
                "score": round(float(score), 2),
                "reasons": ["Based on soil and weather conditions"],
                "tips": ["Follow recommended agricultural practices"]
            })

        return recommendations, None

    except Exception as e:
        return None, str(e)
