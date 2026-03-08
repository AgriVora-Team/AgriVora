from fastapi import APIRouter, HTTPException
from app.services.soilgrids_service import fetch_soil_data
from app.services.weather_service import fetch_weather_data
import requests

router = APIRouter()

@router.post("/location/summary")
def location_summary(payload: dict):
    lat = payload.get("lat")
    lon = payload.get("lon")

    if lat is None or lon is None:
        raise HTTPException(status_code=400, detail="lat and lon are required")

    if not (-90 <= lat <= 90 and -180 <= lon <= 180):
        raise HTTPException(status_code=400, detail="Invalid latitude or longitude")

    warnings = []

    # --- Soil ---
    soil_data, soil_error = fetch_soil_data(lat, lon)
    if soil_error or soil_data is None:
        warnings.append("SoilGrids data unavailable")
        soil_data = {
            "sand": None,
            "clay": None,
            "organicCarbon": None
        }

    # --- Weather ---
    weather_data, weather_error = fetch_weather_data(lat, lon)
    if weather_error or weather_data is None:
        warnings.append("Weather data unavailable")
        weather_data = {
            "temperature": None,
            "rainfall": None,
            "humidity": None
        }

    # --- Reverse Geocoding (Location Name) ---
    location_name = "My Fields"
    try:
        # User-Agent is strictly required by Nominatim usage terms
        headers = {'User-Agent': 'AgriVoraApp/1.0'}
        geo_url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}&zoom=10"
        geo_res = requests.get(geo_url, headers=headers, timeout=5)
        if geo_res.status_code == 200:
            geo_data = geo_res.json()
            address = geo_data.get("address", {})
            location_name = address.get("city") or address.get("town") or address.get("village") or address.get("county") or "My Fields"
    except Exception as e:
        warnings.append("Reverse geocoding unavailable")

    return {
        "success": True,
        "data": {
            "location": location_name,
            "soilSummary": soil_data,
            "weatherSummary": weather_data,
            "warnings": warnings
        },
        "error": None
    }

