"""
Tests the /image/texture endpoint using a generated image.
Useful for checking API response structure without needing a real soil image.
"""

import io
import json

import requests
from PIL import Image

# Create a simple brown synthetic image
img = Image.new("RGB", (300, 300), color=(139, 90, 43))
buf = io.BytesIO()
img.save(buf, format="JPEG")
buf.seek(0)

print("Sending synthetic test image to /image/texture...")

try:
    resp = requests.post(
        "http://localhost:8000/image/texture",
        files={"file": ("test.jpg", buf, "image/jpeg")},
        timeout=200,
    )
    print(f"Status: {resp.status_code}")
    print(json.dumps(resp.json(), indent=2))
except Exception as e:
    print(f"Error: {e}")