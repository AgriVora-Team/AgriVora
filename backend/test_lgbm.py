"""
====================================================================
Agrivora LightGBM Crop Prediction Test Suite
====================================================================

This script is used to validate the crop prediction model used
in the Agrivora AI platform.

Purpose
-------
The test suite performs multiple prediction tests using
different soil and climate conditions to ensure the model
responds correctly under various agricultural scenarios.

Test Categories
---------------
1. Neutral soil environment
2. Alkaline soil conditions
3. Acidic soil conditions
4. Tropical climate environment
5. Dry climate scenario

Each test case evaluates whether the LightGBM model can
generate meaningful crop predictions based on input data.

Author: Agrivora AI Team
====================================================================
"""

# ================================================================
# IMPORTS
# ================================================================

import os
import sys
import datetime
import time



# ================================================================
# CONFIGURE PYTHON PATH
# ================================================================

"""
Ensure the backend directory is included in the Python path.

This allows the test script to import internal services
without needing to run the entire backend server.
"""

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, BASE_DIR)



# ================================================================
# IMPORT MODEL SERVICE
# ================================================================

"""
Import the crop prediction function used by the API.
"""

from app.services.crop_lgbm_service import predict_crop



# ================================================================
# TEST METRICS
# ================================================================

"""
Track overall test performance.
"""

TOTAL_TESTS = 0
SUCCESS_TESTS = 0
FAILED_TESTS = 0



# ================================================================
# HEADER DISPLAY
# ================================================================

def print_header():

    """
    Print the test suite header and start time.
    """

    print("\n===================================================")
    print("        Agrivora LightGBM Model Test Suite")
    print("        Test Execution Started")
    print("        Time:", datetime.datetime.now())
    print("===================================================")



# ================================================================
# FOOTER DISPLAY
# ================================================================

def print_footer():

    """
    Print summary of test execution.
    """

    print("\n===================================================")
    print("                TEST SUMMARY")
    print("---------------------------------------------------")
    print("Total Tests:", TOTAL_TESTS)
    print("Successful:", SUCCESS_TESTS)
    print("Failed:", FAILED_TESTS)
    print("===================================================\n")



# ================================================================
# SINGLE TEST EXECUTION
# ================================================================

def run_test_case(title, data):

    """
    Run a single test case.

    Parameters
    ----------
    title : str
        Name of the test case

    data : dict
        Input parameters passed to the model
    """

    global TOTAL_TESTS
    global SUCCESS_TESTS
    global FAILED_TESTS

    TOTAL_TESTS += 1

    print("\n---------------------------------------------------")
    print("Running Test Case:", title)
    print("Input Data:", data)

    start_time = time.time()

    try:

        result = predict_crop(data)

        execution_time = time.time() - start_time

        print("Prediction Result:", result)
        print("Execution Time:", round(execution_time, 4), "seconds")

        if result:

            SUCCESS_TESTS += 1

            print("Status: SUCCESS")

        else:

            FAILED_TESTS += 1

            print("Status: NO RESULT RETURNED")

    except Exception as e:

        FAILED_TESTS += 1

        print("Prediction Error:", str(e))
        print("Status: FAILED")



# ================================================================
# TEST SUITE EXECUTION
# ================================================================

def run_all_tests():

    """
    Execute all predefined crop prediction tests.
    """

    print_header()



    # ------------------------------------------------------------
    # TEST CASE 1
    # Neutral soil environment
    # ------------------------------------------------------------

    run_test_case(
        "Neutral Soil Environment",

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



    # ------------------------------------------------------------
    # TEST CASE 2
    # Alkaline soil conditions
    # ------------------------------------------------------------

    run_test_case(
        "Alkaline Soil Conditions",

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



    # ------------------------------------------------------------
    # TEST CASE 3
    # Acidic soil environment
    # ------------------------------------------------------------

    run_test_case(
        "Acidic Soil Environment",

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



    # ------------------------------------------------------------
    # TEST CASE 4
    # Tropical rainfall scenario
    # ------------------------------------------------------------

    run_test_case(
        "Tropical Climate Conditions",

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



    # ------------------------------------------------------------
    # TEST CASE 5
    # Dry climate environment
    # ------------------------------------------------------------

    run_test_case(
        "Dry Climate Conditions",

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



# ================================================================
# SCRIPT ENTRY POINT
# ================================================================

"""
Run the test suite when the script is executed directly.
"""

if __name__ == "__main__":

    run_all_tests()