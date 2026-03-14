import joblib
import numpy as np
import os

MODEL_PATH = os.path.join("app", "models", "rf_model.pkl")

rf_model = None
model_error = None

try:
    print("Loading recommendation model...")
    rf_model = joblib.load(MODEL_PATH)
except Exception as e:
    model_error = str(e)
    print("Model load failed:", model_error)

CROP_LABELS = ["Rice", "Maize", "Wheat", "Chili", "Potato"]


def recommend_crops(features: dict):
    try:

        print("Recommendation service called")

        if rf_model is None:
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

        print("Recommendation results:", recommendations)

        return recommendations, None

    except Exception as e:
        print("Recommendation error:", str(e))
        return None, str(e)