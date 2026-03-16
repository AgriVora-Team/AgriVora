import io
import os

import numpy as np
from PIL import Image

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MODEL_PATH = os.path.join(BASE_DIR, "models", "soil_cnn", "soil_model.h5")
LABELS_PATH = os.path.join(BASE_DIR, "models", "soil_cnn", "labels.txt")


def _load_labels():
    try:
        with open(LABELS_PATH, "r") as f:
            return [line.strip() for line in f.readlines() if line.strip()]
    except Exception:
        return ["Alluvial soil", "Black soil", "Other soil", "Red soil", "Yellow soil"]


LABELS = _load_labels()


def predict_soil_type(img_bytes: bytes) -> dict:
    img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    arr = np.array(img, dtype="float32") / 255.0

    return {
        "soil_type": LABELS[0],
        "confidence": 0.0,
        "probs": {label: 0.0 for label in LABELS},
    }