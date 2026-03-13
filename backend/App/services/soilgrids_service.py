import requests
from app.utils.cache import get_cache, set_cache

SOILGRIDS_URL = "https://rest.isric.org/soilgrids/v2.0/properties/query"
REQUEST_TIMEOUT = 10

SOIL_PERCENT_DIVISOR = 10
SOC_DIVISOR = 100

def fetch_soil_data(lat: float, lon: float):
    try:
        cache_key = f"soil:{round(lat,3)}:{round(lon,3)}"
        cached = get_cache(cache_key)

        if cached:
            print("SOIL CACHE HIT")
            return cached, None

        print("SOIL API CALL")

        params = {
            "lat": lat,
            "lon": lon,
            "property": ["sand", "clay", "soc"],
            "depth": ["0-5cm"]
        }

        response = requests.get(SOILGRIDS_URL, params=params, timeout=REQUEST_TIMEOUT)
        response.raise_for_status()

        data = response.json()
        layers = data.get("properties", {}).get("layers", [])

        soil = {
            "sand": None,
            "clay": None,
            "organicCarbon": None
        }

        for layer in layers:
            name = layer.get("name")
            mean = layer.get("depths", [{}])[0].get("values", {}).get("mean")

            if mean is None:
                continue

            if name == "sand":
                soil["sand"] = round(mean / SOIL_PERCENT_DIVISOR, 2)
            elif name == "clay":
                soil["clay"] = round(mean / SOIL_PERCENT_DIVISOR, 2)
            elif name == "soc":
                soil["organicCarbon"] = round(mean / SOC_DIVISOR, 2)

        set_cache(cache_key, soil)
        return soil, None

    except Exception as e:
        return None, str(e)