"""
====================================================================
AGRIVORA LIGHTGBM CROP PREDICTION TEST SUITE (ULTRA EXTENDED)
====================================================================

This script is an advanced testing utility designed to validate
the Agrivora AI crop recommendation model.

This version includes:
✔ Extensive logging
✔ Input validation
✔ Performance tracking
✔ Stress testing
✔ Batch execution
✔ Auto-generated test scenarios
✔ Detailed debug outputs
✔ Modular design for scalability

====================================================================
"""

# ================================================================
# IMPORTS
# ================================================================

import os
import sys
import datetime
import time
import json
import random
import traceback



# ================================================================
# PATH CONFIGURATION
# ================================================================

"""
Ensure backend path is available for imports.
"""

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, BASE_DIR)



# ================================================================
# IMPORT MODEL SERVICE
# ================================================================

from app.services.crop_lgbm_service import predict_crop



# ================================================================
# GLOBAL METRICS
# ================================================================

TOTAL_TESTS = 0
SUCCESS_TESTS = 0
FAILED_TESTS = 0
SKIPPED_TESTS = 0



# ================================================================
# LOGGING SYSTEM
# ================================================================

def log_line():
    print("=" * 70)


def log_subline():
    print("-" * 70)


def log_info(msg):
    print(f"[INFO] {msg}")


def log_success(msg):
    print(f"[SUCCESS] {msg}")


def log_error(msg):
    print(f"[ERROR] {msg}")


def log_warning(msg):
    print(f"[WARNING] {msg}")


def log_debug(msg):
    print(f"[DEBUG] {msg}")



# ================================================================
# HEADER / FOOTER
# ================================================================

def print_header():

    log_line()
    print("AGRIVORA LIGHTGBM TEST SUITE - EXTENDED VERSION")
    print("Execution Started:", datetime.datetime.now())
    log_line()


def print_footer():

    log_line()
    print("FINAL RESULTS")
    log_subline()

    print("Total Tests     :", TOTAL_TESTS)
    print("Successful      :", SUCCESS_TESTS)
    print("Failed          :", FAILED_TESTS)
    print("Skipped         :", SKIPPED_TESTS)

    log_line()



# ================================================================
# VALIDATION UTILITIES
# ================================================================

def validate_input(data):

    """
    Validate input structure and value ranges.
    """

    required = [
        "ph", "temperature", "humidity",
        "rainfall", "nitrogen", "carbon", "soil_type"
    ]

    for key in required:
        if key not in data:
            raise ValueError(f"Missing field: {key}")

    if not (0 <= data["ph"] <= 14):
        raise ValueError("Invalid pH value")



# ================================================================
# DATA FORMATTING
# ================================================================

def pretty_print_json(data):
    return json.dumps(data, indent=2)



# ================================================================
# PERFORMANCE TIMER
# ================================================================

def measure_execution(func, *args, **kwargs):

    start = time.time()
    result = func(*args, **kwargs)
    end = time.time()

    return result, round(end - start, 5)



# ================================================================
# CORE TEST FUNCTION
# ================================================================

def run_test_case(title, data):

    global TOTAL_TESTS, SUCCESS_TESTS, FAILED_TESTS

    TOTAL_TESTS += 1

    log_subline()
    log_info(f"Running Test Case: {title}")

    try:

        validate_input(data)

        result, exec_time = measure_execution(predict_crop, data)

        print("INPUT:")
        print(pretty_print_json(data))

        print("OUTPUT:")
        print(result)

        print("Execution Time:", exec_time, "seconds")

        if result:
            SUCCESS_TESTS += 1
            log_success("Test Passed")

        else:
            FAILED_TESTS += 1
            log_warning("No result returned")

    except Exception as e:

        FAILED_TESTS += 1

        log_error("Test Failed")
        log_debug(traceback.format_exc())



# ================================================================
# BATCH EXECUTION
# ================================================================

def run_batch(test_cases):

    for title, data in test_cases:
        run_test_case(title, data)



# ================================================================
# STANDARD TEST CASES
# ================================================================

def get_standard_tests():

    return [

        ("Neutral Soil", {
            "ph": 6.5, "temperature": 27, "humidity": 75,
            "rainfall": 120, "nitrogen": 40,
            "carbon": 1.2, "soil_type": "loamy soil"
        }),

        ("Alkaline Soil", {
            "ph": 8.0, "temperature": 25, "humidity": 65,
            "rainfall": 100, "nitrogen": 40,
            "carbon": 1.2, "soil_type": "loamy soil"
        }),

        ("Acidic Soil", {
            "ph": 5.0, "temperature": 25, "humidity": 65,
            "rainfall": 100, "nitrogen": 40,
            "carbon": 1.2, "soil_type": "loamy soil"
        }),

        ("Tropical Climate", {
            "ph": 6.8, "temperature": 30, "humidity": 85,
            "rainfall": 200, "nitrogen": 50,
            "carbon": 1.5, "soil_type": "clay soil"
        }),

        ("Dry Climate", {
            "ph": 7.0, "temperature": 33, "humidity": 40,
            "rainfall": 40, "nitrogen": 35,
            "carbon": 0.9, "soil_type": "sandy soil"
        }),
    ]



# ================================================================
# EXTREME TEST CASES
# ================================================================

def get_extreme_tests():

    return [

        ("Extreme Heat", {
            "ph": 6.2, "temperature": 45, "humidity": 20,
            "rainfall": 10, "nitrogen": 20,
            "carbon": 0.8, "soil_type": "sandy soil"
        }),

        ("Flood Condition", {
            "ph": 6.5, "temperature": 28, "humidity": 95,
            "rainfall": 400, "nitrogen": 60,
            "carbon": 2.0, "soil_type": "clay soil"
        }),

        ("Cold Climate", {
            "ph": 6.0, "temperature": 10, "humidity": 60,
            "rainfall": 50, "nitrogen": 30,
            "carbon": 1.1, "soil_type": "loamy soil"
        }),

    ]



# ================================================================
# RANDOM STRESS TEST
# ================================================================

def generate_random_test(index):

    return (
        f"Random Test {index}",
        {
            "ph": round(random.uniform(4, 9), 2),
            "temperature": random.randint(15, 40),
            "humidity": random.randint(30, 90),
            "rainfall": random.randint(20, 300),
            "nitrogen": random.randint(10, 60),
            "carbon": round(random.uniform(0.5, 2.5), 2),
            "soil_type": random.choice([
                "loamy soil", "clay soil", "sandy soil"
            ])
        }
    )



def run_stress_tests(count=20):

    log_line()
    log_info("Running Stress Tests")

    for i in range(count):
        title, data = generate_random_test(i + 1)
        run_test_case(title, data)



# ================================================================
# MAIN EXECUTION
# ================================================================

def run_all_tests():

    print_header()

    run_batch(get_standard_tests())
    run_batch(get_extreme_tests())

    run_stress_tests(15)

    print_footer()



# ================================================================
# ENTRY POINT
# ================================================================

if __name__ == "__main__":

    run_all_tests()