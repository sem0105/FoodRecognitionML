import os
import json
import numpy as np
import tensorflow as tf

# File paths
MODEL_PATH = "models/food_recognition_mobilenetv2.keras"
CLASS_NAMES_PATH = "class_names.json"

IMAGE_PATHS = [
    "dataset/test/biryani/0.jpg",
    "dataset/test/biryani/1.jpg",
    "images/biryani.jpg"
]

# Load trained model
print("Loading model...")
model = tf.keras.models.load_model(MODEL_PATH)

# Load class names
with open(CLASS_NAMES_PATH, "r") as file:
    class_names = json.load(file)

print("\nNumber of classes:", len(class_names))
print("Model output shape:", model.output_shape)
print("Class names:", class_names)

# Check each image
for image_path in IMAGE_PATHS:
    print("\n" + "=" * 45)
    print("Image:", image_path)

    if not os.path.exists(image_path):
        print("Image not found. Skipping.")
        continue

    # Load and resize image
    img = tf.keras.utils.load_img(
        image_path,
        target_size=(224, 224)
    )

    img_array = tf.keras.utils.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)

    # Predict using the model's built-in preprocessing
    predictions = model.predict(img_array, verbose=0)[0]

    # Display top 3 predictions
    top_indices = np.argsort(predictions)[-3:][::-1]

    for rank, index in enumerate(top_indices, start=1):
        print(
            f"{rank}. {class_names[index]}: "
            f"{predictions[index] * 100:.2f}%"
        )

print("\nDiagnostic completed.")