import os
import sys

# Ensure backend directory is in Python path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)

from app.services.crop_lgbm_service import predict_crop


def run_test_case(title, data):
    """
    Helper function to run a prediction test
    """
    print("\n----------------------------------------")
    print(f"Running Test Case: {title}")
    print("Input Data:", data)

    try:
        result = predict_crop(data)
        print("Prediction Result:", result)
    except Exception as e:
        print("Prediction Error:", str(e))


def run_all_tests():
    """
    Execute multiple crop prediction tests
    """

    print("\n=== LightGBM Crop Prediction Test Suite ===")

    # Neutral soil test
    run_test_case(
        "Neutral Soil",
        {
            "ph": 6.5,
            "temperature": 27.0,
            "humidity": 75.0,
            "rainfall": 120.0,
            "nitrogen": 40.0,
            "carbon": 1.2,
            "soil_type": "loamy soil"
        }
    )

    # Alkaline soil test
    run_test_case(
        "Alkaline Soil",
        {
            "ph": 8.0,
            "temperature": 25.0,
            "humidity": 65.0,
            "rainfall": 100.0,
            "nitrogen": 40.0,
            "carbon": 1.2,
            "soil_type": "loamy soil"
        }
    )

    # Acidic soil test
    run_test_case(
        "Acidic Soil",
        {
            "ph": 5.0,
            "temperature": 25.0,
            "humidity": 65.0,
            "rainfall": 100.0,
            "nitrogen": 40.0,
            "carbon": 1.2,
            "soil_type": "loamy soil"
        }
    )

    # High rainfall tropical test
    run_test_case(
        "Tropical Climate",
        {
            "ph": 6.8,
            "temperature": 30.0,
            "humidity": 85.0,
            "rainfall": 200.0,
            "nitrogen": 50.0,
            "carbon": 1.5,
            "soil_type": "clay soil"
        }
    )

    print("\n=== Test Suite Completed ===")


if __name__ == "__main__":
    run_all_tests()