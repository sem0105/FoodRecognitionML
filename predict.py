import os
import sys

try:
    import json
    import numpy as np
    import tensorflow as tf
except ModuleNotFoundError as err:
    print("\n==================================================")
    print("ERROR: Missing required Python package:", err.name)
    print("==================================================")
    print("You are running system Python instead of the virtual environment.")
    print("\nPlease activate the virtual environment in your terminal first:")
    print("   .\\venv\\Scripts\\activate")
    print("\nOr run directly with:")
    print("   .\\venv\\Scripts\\python.exe predict.py <image_path>")
    print("==================================================\n")
    sys.exit(1)


# Model and class names
MODEL_PATH = "models/food_recognition_mobilenetv2.keras"
CLASS_NAMES_PATH = "class_names.json"

IMAGE_SIZE = (224, 224)


# Check image path
if len(sys.argv) < 2:
    print("Please provide an image path.")
    print('Example: python predict.py "images\\biryani.jpg"')
    sys.exit()

IMAGE_PATH = sys.argv[1]


# Check model
if not os.path.exists(MODEL_PATH):
    print("ERROR: Model file not found.")
    print(MODEL_PATH)
    sys.exit()


# Check class names
if not os.path.exists(CLASS_NAMES_PATH):
    print("ERROR: class_names.json not found.")
    sys.exit()


# Check image
if not os.path.exists(IMAGE_PATH):
    print("ERROR: Image file not found.")
    print(IMAGE_PATH)
    sys.exit()


# Load model
print("\nLoading model...")

model = tf.keras.models.load_model(MODEL_PATH)

print("Model loaded successfully.")


# Load class names
with open(CLASS_NAMES_PATH, "r") as file:
    class_names = json.load(file)


# Load image
print("\nLoading image...")

img = tf.keras.utils.load_img(
    IMAGE_PATH,
    target_size=IMAGE_SIZE
)


# Convert image to array
img_array = tf.keras.utils.img_to_array(img)

img_array = np.expand_dims(
    img_array,
    axis=0
)


# Preprocess image (Note: model already contains preprocess_input layer)
# img_array = preprocess_input(img_array)


# Predict
print("Predicting food...")

predictions = model.predict(
    img_array,
    verbose=0
)


# Get prediction
predicted_index = np.argmax(predictions[0])

predicted_food = class_names[predicted_index]

confidence = predictions[0][predicted_index] * 100


# Display result
print("\n====================================")
print("       FOOD RECOGNITION RESULT")
print("====================================")

print("Predicted Food:", predicted_food)

print("Confidence:", f"{confidence:.2f}%")

print("====================================")


# Top 3 predictions
top_indices = np.argsort(
    predictions[0]
)[-3:][::-1]

print("\nTop 3 Predictions:")

for rank, index in enumerate(top_indices, 1):
    food_name = class_names[index]
    food_confidence = predictions[0][index] * 100

    print(
        f"{rank}. {food_name} - "
        f"{food_confidence:.2f}%"
    )

print()