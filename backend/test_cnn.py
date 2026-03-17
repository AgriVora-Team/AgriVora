import io
import json

import requests
from PIL import Image

img = Image.new("RGB", (300, 300), color=(139, 90, 43))
buf = io.BytesIO()
img.save(buf, format="JPEG")
buf.seek(0)

print("Sending test image to /image/texture...")

try:
    resp = requests.post(
        "http://localhost:8000/image/texture",
        files={"file": ("test.jpg", buf, "image/jpeg")},
        timeout=120,
    )
    print(f"Status: {resp.status_code}")
    print(json.dumps(resp.json(), indent=2))
except Exception as e:
    print(f"Error: {e}")