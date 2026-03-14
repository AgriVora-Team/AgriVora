import os
import sys
import datetime

# Ensure backend directory is in Python path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)

from app.services.crop_lgbm_service import predict_crop


def print_header():
    print("\n==============================================")
    print("      LightGBM Crop Prediction Test Suite")
    print("      Started:", datetime.datetime.now())
    print("==============================================")


def print_footer():
    print("\n==============================================")
    print("      Test Suite Completed")
    print("==============================================\n")


def run_test_case(title, data):
    """
    Run a single crop prediction test case
    """

    print("\n----------------------------------------")
    print(f"Running Test Case: {title}")
    print("Input Data:", data)

    try:
        result = predict_crop(data)

        print("Prediction Result:", result)

        if result:
            print("Status: SUCCESS")
        else:
            print("Status: NO RESULT RETURNED")

    except Exception as e:
        print("Prediction Error:", str(e))
        print("Status: FAILED")


def run_all_tests():
    """
    Execute multiple crop prediction tests
    """

    print_header()

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

    # Tropical rainfall test
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

    # Dry climate test
    run_test_case(
        "Dry Climate",
        {
            "ph": 7.0,
            "temperature": 33.0,
            "humidity": 40.0,
            "rainfall": 40.0,
            "nitrogen": 35.0,
            "carbon": 0.9,
            "soil_type": "sandy soil"
        }
    )

    print_footer()


if __name__ == "__main__":
    run_all_tests()