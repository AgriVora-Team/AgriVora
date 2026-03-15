"""
Crop Recommendation Service (Random Forest)
------------------------------------------------------------

This module provides crop recommendations based on
soil properties and weather conditions using a
trained Random Forest machine learning model.

The service is responsible for:

1. Loading the trained ML model
2. Receiving structured feature inputs
3. Preparing features for prediction
4. Running the prediction model
5. Ranking predicted crops
6. Formatting recommendation output

The recommendation system uses the following inputs:

SOIL FEATURES
-------------
- sand percentage
- clay percentage
- organic carbon content

WEATHER FEATURES
----------------
- temperature
- rainfall
- humidity

SOIL CHEMISTRY
--------------
- soil pH

The ML model outputs probability scores for
each supported crop type.

Author: Agrivora AI System
"""

# ---------------------------------------------------------
# IMPORTS
# ---------------------------------------------------------

import joblib
import numpy as np
import os


# ---------------------------------------------------------
# MODEL FILE LOCATION
# ---------------------------------------------------------

"""
Define the path to the trained Random Forest model.

The model is stored inside:

app/models/rf_model.pkl

This model was trained using historical agricultural
datasets that relate soil conditions and weather
to crop performance.
"""

MODEL_PATH = os.path.join("app", "models", "rf_model.pkl")


# ---------------------------------------------------------
# GLOBAL MODEL VARIABLES
# ---------------------------------------------------------

"""
These variables store the loaded ML model
and potential loading errors.

rf_model
    Stores the loaded Random Forest model

model_error
    Stores the error message if loading fails
"""

rf_model = None
model_error = None


# ---------------------------------------------------------
# LOAD MODEL DURING SERVICE INITIALIZATION
# ---------------------------------------------------------

try:

    print("--------------------------------------------------")
    print("Initializing Crop Recommendation Model Service")
    print("Attempting to load Random Forest model...")
    print("Model path:", MODEL_PATH)

    rf_model = joblib.load(MODEL_PATH)

    print("Model successfully loaded.")
    print("Recommendation service ready.")
    print("--------------------------------------------------")

except Exception as e:

    model_error = str(e)

    print("--------------------------------------------------")
    print("ERROR: Failed to load recommendation model")
    print("Error message:", model_error)
    print("System will use fallback recommendation")
    print("--------------------------------------------------")


# ---------------------------------------------------------
# SUPPORTED CROP LABELS
# ---------------------------------------------------------

"""
These labels correspond to the classes
used during model training.

The model predicts probabilities for each
crop in this list.
"""

CROP_LABELS = [
    "Rice",
    "Maize",
    "Wheat",
    "Chili",
    "Potato"
]


# ---------------------------------------------------------
# MAIN RECOMMENDATION FUNCTION
# ---------------------------------------------------------

def recommend_crops(features: dict):
    """
    Generate crop recommendations based on
    soil conditions and weather parameters.

    Parameters
    ----------
    features : dict
        Dictionary containing:

        {
            "soil": {
                "sand": float,
                "clay": float,
                "organicCarbon": float
            },
            "weather": {
                "temperature": float,
                "rainfall": float,
                "humidity": float
            },
            "ph": float
        }

    Returns
    -------
    tuple
        (recommendations, error)

        recommendations : list
            List of crop recommendations

        error : str or None
            Error message if prediction fails
    """

    try:

        print("--------------------------------------------------")
        print("Recommendation service invoked")
        print("Received features:", features)

        # -------------------------------------------------
        # FALLBACK IF MODEL IS UNAVAILABLE
        # -------------------------------------------------

        if rf_model is None:

            print("Model unavailable — using fallback recommendation")

            return [
                {
                    "name": "Rice",
                    "score": 0.75,
                    "reasons": [
                        "Machine learning model unavailable",
                        "Fallback crop recommendation used"
                    ],
                    "tips": [
                        "Apply organic compost",
                        "Ensure adequate irrigation"
                    ]
                }
            ], None


        # -------------------------------------------------
        # FEATURE EXTRACTION
        # -------------------------------------------------

        """
        Convert dictionary features into
        numerical input array for the model.

        Feature order must match the order
        used during model training.
        """

        X = np.array([[

            # Soil composition
            features["soil"]["sand"],
            features["soil"]["clay"],
            features["soil"]["organicCarbon"],

            # Weather conditions
            features["weather"]["temperature"],
            features["weather"]["rainfall"],
            features["weather"]["humidity"],

            # Soil chemistry
            features["ph"]

        ]])

        print("Prepared model input array:", X)


        # -------------------------------------------------
        # RUN MACHINE LEARNING PREDICTION
        # -------------------------------------------------

        probs = rf_model.predict_proba(X)[0]

        print("Model probability output:", probs)


        # -------------------------------------------------
        # RANK CROPS BY PROBABILITY
        # -------------------------------------------------

        ranked = sorted(
            zip(CROP_LABELS, probs),
            key=lambda x: x[1],
            reverse=True
        )

        print("Ranked crop predictions:", ranked)


        # -------------------------------------------------
        # BUILD RECOMMENDATION LIST
        # -------------------------------------------------

        recommendations = []

        for crop, score in ranked[:3]:

            recommendation = {
                "name": crop,

                # Round probability score for readability
                "score": round(float(score), 2),

                # Reasoning for recommendation
                "reasons": [
                    "Recommended based on soil composition",
                    "Weather conditions are suitable"
                ],

                # Farming tips
                "tips": [
                    "Follow recommended agricultural practices",
                    "Monitor soil moisture regularly"
                ]
            }

            recommendations.append(recommendation)


        print("Final recommendations generated:")
        print(recommendations)

        print("--------------------------------------------------")

        return recommendations, None


    except Exception as e:

        print("--------------------------------------------------")
        print("ERROR during crop recommendation")
        print("Error message:", str(e))
        print("--------------------------------------------------")

        return None, str(e)