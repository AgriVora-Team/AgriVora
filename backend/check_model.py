import os

os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

import numpy as np
import tensorflow as tf

MODEL_PATH = "app/models/soil_cnn/soil_model.h5"

model = tf.keras.models.load_model(MODEL_PATH)

lines = []
lines.append(f"Input shape: {model.input_shape}")
lines.append(f"Output shape: {model.output_shape}")
lines.append(f"Layer count: {len(model.layers)}")
lines.append("")

for layer in model.layers:
    try:
        lines.append(
            f"  {layer.name} | {type(layer).__name__} | output: {layer.output_shape}"
        )
    except Exception:
        lines.append(
            f"  {layer.name} | {type(layer).__name__} | output: ERROR"
        )

lines.append("")
lines.append("=== TRYING INPUT SIZES ===")

for sz in [64, 100, 128, 150, 172, 224, 256, 300]:
    try:
        dummy = np.zeros((1, sz, sz, 3), dtype="float32")
        out = model(tf.constant(dummy), training=False)
        lines.append(f"  OK {sz}x{sz} => {out.shape}")
    except Exception as e:
        lines.append(f"  FAIL {sz}x{sz} => {str(e)[:120]}")

with open("model_info.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(lines))

print("Written to model_info.txt")
print(lines[0])
print(lines[1])