import os

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import tensorflow as tf

MODEL_PATH = "app/models/soil_cnn/soil_model.h5"

model = tf.keras.models.load_model(MODEL_PATH)

print("Input shape:", model.input_shape)
print("Output shape:", model.output_shape)
print("Layer count:", len(model.layers))
print()

for layer in model.layers:
    try:
        print(f"{layer.name} | {type(layer).__name__} | output: {layer.output_shape}")
    except Exception:
        print(f"{layer.name} | {type(layer).__name__} | output: ERROR")