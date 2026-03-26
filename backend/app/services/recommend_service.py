

from app.services.crop_lgbm_service import predict_crop as _lgbm_predict


def recommend_crops(features: dict):
   

    try:
         # Extract inputs
        soil = features.get("soil", {})
        weather = features.get("weather", {})
        ph = float(features.get("ph", 6.5))

        # Determine soil type from composition
        sand = soil.get("sand") or 0
        clay = soil.get("clay") or 0
        if sand >= 60:
            soil_type = "sandy soil"
        elif clay >= 40:
            soil_type = "clay soil"
        else:
            soil_type = "loamy soil"

        # Prepare model input
        payload = {
            "temperature": weather.get("temperature") or 27.0,
            "humidity": weather.get("humidity") or 65.0,
            "rainfall": weather.get("rainfall") or 100.0,
            "ph": ph,
            "nitrogen": 40.0,
            "carbon": soil.get("organicCarbon") or 1.2,
            "soil_type": soil_type,
        }

        # Get predictions
        result = _lgbm_predict(payload)

       # Format recommendations for frontend
        recommendations = []
        for r in result.get("recommendations", []):
            recommendations.append({
                "name": r["crop"],
                "score": r["confidence"],
                "reasons": ["Based on soil texture, pH, and weather conditions"],
                "tips": ["Follow recommended agricultural practices"],
            })

        return recommendations, None

    except Exception as e:
        # Handle errors
        return None, str(e)
