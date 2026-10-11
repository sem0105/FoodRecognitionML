
import io
import json
from pathlib import Path

import numpy as np
import tensorflow as tf
from flask import Flask, jsonify, request
from flask_cors import CORS
from PIL import UnidentifiedImageError

# ----------------------------------
# Configuration
# ----------------------------------

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = BASE_DIR / "models" / "food_recognition_mobilenetv2.keras"
CLASS_NAMES_PATH = BASE_DIR / "class_names.json"

IMAGE_SIZE = (224, 224)

app = Flask(__name__)
CORS(app)
app.config["MAX_CONTENT_LENGTH"] = 10 * 1024 * 1024  # 10 MB



# ----------------------------------
# Load model and class names
# ----------------------------------

if not MODEL_PATH.is_file():
    raise FileNotFoundError(f"Model not found: {MODEL_PATH}")

if not CLASS_NAMES_PATH.is_file():
    raise FileNotFoundError(
        f"Class names file not found: {CLASS_NAMES_PATH}"
    )

print("Loading food recognition model...")

model = tf.keras.models.load_model(MODEL_PATH)

with open(CLASS_NAMES_PATH, "r", encoding="utf-8") as file:
    class_names = json.load(file)

if not isinstance(class_names, list) or not class_names:
    raise ValueError("class_names.json must contain a non-empty list.")

if model.output_shape[-1] != len(class_names):
    raise ValueError(
        "The number of model outputs does not match class_names.json."
    )

print("Model loaded successfully!")
print(f"Number of food classes: {len(class_names)}")


# ----------------------------------
# Health-check endpoint
# ----------------------------------

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "message": "Food recognition API is running.",
        "model_loaded": True,
        "number_of_classes": len(class_names)
    })


# ----------------------------------
# Food prediction endpoint
# ----------------------------------

@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({
            "error": "No image provided. Upload the file using the field name 'image'."
        }), 400

    uploaded_file = request.files["image"]

    if not uploaded_file.filename:
        return jsonify({"error": "Please select an image file."}), 400

    try:
        # Read and resize the uploaded image
        image_bytes = io.BytesIO(uploaded_file.read())

        img = tf.keras.utils.load_img(
            image_bytes,
            target_size=IMAGE_SIZE,
            color_mode="rgb"
        )

        img_array = tf.keras.utils.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)

        # IMPORTANT:
        # Your training model includes MobileNetV2 preprocessing
        # inside the model, so do not call preprocess_input here.
        predictions = model.predict(img_array, verbose=0)[0]

        predicted_index = int(np.argmax(predictions))
        predicted_food = class_names[predicted_index]
        confidence = float(predictions[predicted_index] * 100)

        # Get the three highest predictions
        top_indices = np.argsort(predictions)[-3:][::-1]

        top_predictions = []

        for index in top_indices:
            top_predictions.append({
                "food": class_names[int(index)],
                "confidence": round(float(predictions[index] * 100), 2)
            })

        return jsonify({
            "success": True,
            "predicted_food": predicted_food,
            "confidence": round(confidence, 2),
            "top_predictions": top_predictions
        }), 200

    except (UnidentifiedImageError, OSError, ValueError):
        return jsonify({
            "error": "The uploaded file is not a valid or supported image."
        }), 400

    except Exception:
        app.logger.exception("Prediction failed")
        return jsonify({
            "error": "Prediction failed. Check the server terminal for details."
        }), 500


# ----------------------------------
# Start Flask server
# ----------------------------------

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=False)

