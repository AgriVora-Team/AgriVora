
import requests
import io
from PIL import Image


# Create test image in memory
img = Image.new("RGB", (300, 300), color=(139, 90, 43))
buf = io.BytesIO()
img.save(buf, format="JPEG")
buf.seek(0)

# Send image to API
print("Sending test image to /image/texture (may take ~30s on first call) ...")
try:
    resp = requests.post(
        "http://localhost:8000/image/texture",
        files={"file": ("test.jpg", buf, "image/jpeg")},
        timeout=200,  # generous timeout for model load + inference
    )
    
    # Print response
    print(f"Status: {resp.status_code}")
    import json
    print(json.dumps(resp.json(), indent=2))
except Exception as e:
    
     # Handle request errors
    print(f"Error: {e}")
