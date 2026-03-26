

import requests

from app.utils.cache import get_cache, set_cache

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"

def fetch_weather_data(lat: float, lon: float):
    try:
        # Check cache
        cache_key = f"weather:{round(lat,3)}:{round(lon,3)}"
        cached = get_cache(cache_key)

        if cached:
            print("WEATHER CACHE HIT")
            return cached, None

        print("WEATHER API CALL")
        # Call weather API
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": "temperature_2m,relative_humidity_2m,precipitation",
            "timezone": "auto"
        }

        response = requests.get(OPEN_METEO_URL, params=params, timeout=10)
        response.raise_for_status()

        data = response.json()
        current = data.get("current", {})
        # Extract weather data
        weather = {
            "temperature": current.get("temperature_2m"),
            "rainfall": current.get("precipitation"),
            "humidity": current.get("relative_humidity_2m")
        }
         # Store in cache
        set_cache(cache_key, weather)
        return weather, None

    except Exception as e:
        # Handle errors
        return None, str(e)
