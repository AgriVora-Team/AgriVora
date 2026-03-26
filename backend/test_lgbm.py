import os
import sys

# Add current directory to import path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.services.crop_lgbm_service import predict_crop

# Test with alkaline soil (pH 8)
print("PH 8:", predict_crop({
    "ph": 8.0,
    "temperature": 25.0,
    "humidity": 65.0,
    "rainfall": 100.0,
    "nitrogen": 40.0,
    "carbon": 1.2,
    "soil_type": "loamy soil"
}))

# Test with acidic soil (pH 5)
print("PH 5:", predict_crop({
    "ph": 5.0,
    "temperature": 25.0,
    "humidity": 65.0,
    "rainfall": 100.0,
    "nitrogen": 40.0,
    "carbon": 1.2,
    "soil_type": "loamy soil"
}))
