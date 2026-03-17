import os

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import numpy as np
import tensorflow as tf

MODEL_PATH = "app/models/soil_cnn/soil_model.h5"

model = tf.keras.models.load_model(MODEL_PATH)

print("Input shape:", model.input_shape)
print("Output shape:", model.output_shape)
print()
print("=== TRYING INPUT SIZES ===")

for sz in [64, 100, 128, 150, 172, 224, 256, 300]:
    try:
        dummy = np.zeros((1, sz, sz, 3), dtype="float32")
        out = model(tf.constant(dummy), training=False)
        print(f"OK {sz}x{sz} => {out.shape}")
    except Exception as e:
        print(f"FAIL {sz}x{sz} => {str(e)[:120]}")