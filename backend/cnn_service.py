# This file wraps the CNN model inference
# so the backend stays independent of ML details

def predict_texture(image_bytes: bytes):
    try:
        # 🔁 TEMPORARY STUB (replace when CNN is ready)
        # Dev 4 will later plug the real model here

        result = {
            "texture": "loamy",
            "confidence": 0.82,
            "needs_confirmation": False
        }

        return result, None

    except Exception as e:
        return None, str(e)
