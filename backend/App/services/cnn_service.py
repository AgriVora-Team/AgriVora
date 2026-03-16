import io
import os
import queue
import threading

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


def _detect_img_size(model) -> int:
    try:
        inp = model.input_shape
        h = inp[1]
        if h and isinstance(h, int) and h > 0:
            return h
    except Exception:
        pass
    return 224


_task_queue: "queue.Queue[tuple]" = queue.Queue()
_result_store: dict = {}
_store_lock = threading.Lock()
_task_counter = 0
_task_counter_lock = threading.Lock()


def _worker():
    model = None
    img_h = 224
    load_err = None

    try:
        os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")
        import tensorflow as tf

        model = tf.keras.models.load_model(MODEL_PATH)
        img_h = _detect_img_size(model)

        dummy = np.zeros((1, img_h, img_h, 3), dtype="float32")
        _ = model(tf.constant(dummy), training=False)
    except Exception as e:
        load_err = str(e)

    while True:
        task_id, img_bytes, event = _task_queue.get()
        try:
            if model is None:
                raise RuntimeError(load_err or "Model failed to load")

            import tensorflow as tf

            img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
            img = img.resize((img_h, img_h))
            arr = np.array(img, dtype="float32") / 255.0
            arr = np.expand_dims(arr, axis=0)

            output = model(tf.constant(arr), training=False)
            probs = output.numpy()[0]

            idx = int(np.argmax(probs))
            confidence = float(probs[idx])

            result = {
                "soil_type": LABELS[idx],
                "confidence": round(confidence, 4),
                "probs": {
                    label: round(float(p), 4)
                    for label, p in zip(LABELS, probs)
                },
            }

            with _store_lock:
                _result_store[task_id] = ("ok", result)

        except Exception as e:
            with _store_lock:
                _result_store[task_id] = ("err", str(e))
        finally:
            event.set()


_worker_thread = threading.Thread(target=_worker, daemon=True, name="cnn-worker")
_worker_thread.start()


def predict_soil_type(img_bytes: bytes) -> dict:
    global _task_counter

    with _task_counter_lock:
        _task_counter += 1
        tid = _task_counter

    event = threading.Event()
    _task_queue.put((tid, img_bytes, event))

    if not event.wait(timeout=200):
        with _store_lock:
            _result_store.pop(tid, None)
        raise RuntimeError("CNN inference timed out after 200 s")

    with _store_lock:
        status, payload = _result_store.pop(tid)

    if status == "err":
        raise RuntimeError(payload)

    return payload