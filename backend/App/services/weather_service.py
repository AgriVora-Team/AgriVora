import requests
from app.utils.cache import get_cache, set_cache

OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast"

def fetch_weather_data(lat: float, lon: float):
    try:
        key = f"weather:{round(lat, 3)}:{round(lon, 3)}"
        cached_data = get_cache(key)

        if cached_data:
            print("WEATHER CACHE HIT")
            return cached_data, None

        print("WEATHER API CALL")

        query = {
            "latitude": lat,
            "longitude": lon,
            "current": ["temperature_2m", "relative_humidity_2m", "precipitation"],
            "timezone": "auto"
        }

        res = requests.get(OPEN_METEO_URL, params=query, timeout=10)
        res.raise_for_status()

        payload = res.json()
        current_data = payload.get("current", {})

        weather_info = {
            "temperature": current_data.get("temperature_2m"),
            "rainfall": current_data.get("precipitation"),
            "humidity": current_data.get("relative_humidity_2m")
        }

        set_cache(key, weather_info)
        return weather_info, None

    except Exception as err:
        return None, str(err)