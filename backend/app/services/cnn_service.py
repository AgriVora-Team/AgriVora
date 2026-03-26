

import io
import os
import re
import queue
import threading
import requests
from pathlib import Path

import numpy as np
from PIL import Image

# Paths for model and labels
BASE_DIR    = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # backend/app
LABELS_PATH = os.path.join(BASE_DIR, "models", "soil_cnn", "labels.txt")

MODEL_DIR  = Path(BASE_DIR) / "models" / "soil_cnn"
MODEL_PATH = MODEL_DIR / "soil_model.h5"
MODEL_URL  = os.getenv("MODEL_URL")

model = None
img_h = 224
img_w = 224

# Load class labels
def _load_labels():
    try:
        with open(LABELS_PATH, "r") as f:
            return [line.strip() for line in f.readlines() if line.strip()]
    except Exception:
        return ["Alluvial soil", "Black soil", "Other soil", "Red soil", "Yellow soil"]


LABELS = _load_labels()



# Detect input image size from model
def _detect_img_size(keras_model) -> int:
    try:
        inp = keras_model.input_shape
        h = inp[1]
        if h and isinstance(h, int) and h > 0:
            return h
        cfg = keras_model.get_config()
        first_layer = cfg.get("layers", [{}])[0]
        batch_shape = first_layer.get("config", {}).get("batch_shape", [None, None])
        candidate = batch_shape[1] if len(batch_shape) > 1 else None
        if candidate and isinstance(candidate, int) and candidate > 0:
            return candidate
    except Exception:
        pass
    return 224



# Convert Google Drive link to direct download
def _to_direct_gdrive_url(url: str) -> str:
    
    match = re.search(r"/file/d/([a-zA-Z0-9_-]+)", url)
    if match:
        fid = match.group(1)
        return f"https://drive.google.com/uc?export=download&id={fid}&confirm=t"
    if "drive.google.com/uc" in url and "confirm=" not in url:
        return url + "&confirm=t"
    return url



# Download model file
def download_file(url: str, dest: Path):
   
    download_url = _to_direct_gdrive_url(url)
    print(f"[CNN] Downloading from: {download_url}")

    session = requests.Session()
    hdrs = {"User-Agent": "Mozilla/5.0"}

    resp = session.get(download_url, headers=hdrs, stream=True, timeout=180)
    resp.raise_for_status()

    content_type = resp.headers.get("Content-Type", "")

    # Handle Google Drive HTML response
    if "text/html" in content_type:
        
        try:
            from bs4 import BeautifulSoup
            soup = BeautifulSoup(resp.text, "html.parser")
            form = soup.find("form")
            if form:
                action = form.get("action", download_url)
                params = {
                    inp.get("name"): inp.get("value")
                    for inp in form.find_all("input")
                    if inp.get("name")
                }
                resp = session.get(action, params=params, headers=hdrs, stream=True, timeout=180)
                resp.raise_for_status()
                content_type = resp.headers.get("Content-Type", "")
        except ImportError:
            pass  

        if "text/html" in content_type:
            raise RuntimeError(
                "MODEL_URL returned an HTML page instead of a model file. "
                "Ensure the Google Drive file is shared as 'Anyone with the link can view' "
                "and use: https://drive.google.com/uc?export=download&id=YOUR_FILE_ID"
            )

    dest.parent.mkdir(parents=True, exist_ok=True)
    bytes_written = 0
    with open(dest, "wb") as f:
        for chunk in resp.iter_content(1024 * 1024):
            if chunk:
                f.write(chunk)
                bytes_written += len(chunk)

     # Validate file size
    if bytes_written < 10_240:  # < 10 KB → almost certainly an error page
        dest.unlink(missing_ok=True)
        raise RuntimeError(
            f"Downloaded only {bytes_written} bytes — this is not a valid model file. "
            "Check MODEL_URL and Drive sharing permissions."
        )

    print(f"[CNN] Download complete: {bytes_written / 1024 / 1024:.2f} MB → {dest}")



# Ensure model exists locally
def ensure_model():
    global MODEL_URL
    MODEL_DIR.mkdir(parents=True, exist_ok=True)

    if MODEL_PATH.exists() and MODEL_PATH.stat().st_size > 10_240:
        print("[CNN] Model already exists locally.")
        return

    MODEL_URL = MODEL_URL or os.getenv("MODEL_URL")
    if not MODEL_URL:
        raise RuntimeError(
            "MODEL_URL environment variable is not set. "
            "Add MODEL_URL to your Railway environment variables pointing to your .h5 model file."
        )

    print(f"[CNN] Fetching model …")
    download_file(MODEL_URL, MODEL_PATH)

# Load model once (singleton)
def load_model_once():
    global model, img_h, img_w
    if model is None:
        import tensorflow as tf
        ensure_model()
        model = tf.keras.models.load_model(str(MODEL_PATH))
        img_h = _detect_img_size(model)
        img_w = img_h
        print(f"[CNN] Model loaded — input {img_h}x{img_w}x3.")

        
        dummy = np.zeros((1, img_h, img_w, 3), dtype="float32")
        _ = model(tf.constant(dummy), training=False)
        print("[CNN] Warm-up done.", flush=True)
    return model



# Queue + threading for async processing
_task_queue       = queue.Queue()
_result_store     = {}
_store_lock       = threading.Lock()
_task_counter     = 0
_task_counter_lock = threading.Lock()

# Worker thread to process prediction tasks
def _worker():
   
    os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")

    while True:
        task_id, img_bytes, event = _task_queue.get()
        try:
            import tensorflow as tf
            m = load_model_once()

            img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
            img = img.resize((img_w, img_h))

            arr = np.array(img, dtype="float32") / 255.0
            arr = np.expand_dims(arr, axis=0)

            output = m(tf.constant(arr), training=False)
            probs  = output.numpy()[0]

            idx        = int(np.argmax(probs))
            confidence = float(probs[idx])

            result = {
                "soil_type":  LABELS[idx],
                "confidence": round(confidence, 4),
                "probs": {
                    label: round(float(p), 4)
                    for label, p in zip(LABELS, probs)
                },
            }
            with _store_lock:
                _result_store[task_id] = ("ok", result)

        except Exception as e:
            import traceback
            traceback.print_exc()
            with _store_lock:
                _result_store[task_id] = ("err", str(e))
        finally:
            event.set()

# Start worker thread
_worker_thread = threading.Thread(target=_worker, daemon=True, name="cnn-worker")
_worker_thread.start()



# Start worker thread
def predict_soil_type(img_bytes: bytes) -> dict:
    
    global _task_counter
    # Generate task ID
    with _task_counter_lock:
        _task_counter += 1
        tid = _task_counter

    event = threading.Event()
    _task_queue.put((tid, img_bytes, event))

    
    if not event.wait(timeout=500):
        with _store_lock:
            _result_store.pop(tid, None)
        raise RuntimeError(
            "Soil analysis timed out after 500 s. "
            "The AI model may still be downloading on first use. "
            "Please try again in a few minutes."
        )

    with _store_lock:
        status, payload = _result_store.pop(tid)

    if status == "err":
        raise RuntimeError(payload)

    return payload