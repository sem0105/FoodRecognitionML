import os
import json
import numpy as np
import tensorflow as tf
import matplotlib.pyplot as plt

from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input


# ============================================================
# 1. SETTINGS
# ============================================================

TRAIN_DIR = "dataset/train"
TEST_DIR = "dataset/test"
MODEL_DIR = "models"

IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 15
VALIDATION_SPLIT = 0.2
SEED = 42


# ============================================================
# 2. CREATE MODEL DIRECTORY
# ============================================================

os.makedirs(MODEL_DIR, exist_ok=True)


# ============================================================
# 3. LOAD TRAINING DATA
# ============================================================

print("\nLoading training dataset...")

train_dataset = tf.keras.utils.image_dataset_from_directory(
    TRAIN_DIR,
    validation_split=VALIDATION_SPLIT,
    subset="training",
    seed=SEED,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE
)


# ============================================================
# 4. LOAD VALIDATION DATA
# ============================================================

print("\nLoading validation dataset...")

validation_dataset = tf.keras.utils.image_dataset_from_directory(
    TRAIN_DIR,
    validation_split=VALIDATION_SPLIT,
    subset="validation",
    seed=SEED,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE
)


# ============================================================
# 5. LOAD TEST DATA
# ============================================================

print("\nLoading test dataset...")

test_dataset = tf.keras.utils.image_dataset_from_directory(
    TEST_DIR,
    shuffle=False,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE
)


# ============================================================
# 6. GET CLASS NAMES
# ============================================================

class_names = train_dataset.class_names

print("\n========================================")
print("Food Classes")
print("========================================")

for index, class_name in enumerate(class_names):
    print(index, "->", class_name)

print("\nNumber of classes:", len(class_names))


# ============================================================
# 7. CHECK THAT THERE ARE 15 CLASSES
# ============================================================

if len(class_names) != 15:
    print("\nERROR: Expected 15 food classes.")
    print("Found:", len(class_names))
    print("\nPlease check the dataset/train folder.")
    exit()


# ============================================================
# 8. SAVE CLASS NAMES
# ============================================================

with open("class_names.json", "w") as file:
    json.dump(class_names, file, indent=4)

print("\nclass_names.json saved successfully.")


# ============================================================
# 9. IMPROVE DATA PIPELINE
# ============================================================

AUTOTUNE = tf.data.AUTOTUNE

train_dataset = train_dataset.prefetch(
    buffer_size=AUTOTUNE
)

validation_dataset = validation_dataset.prefetch(
    buffer_size=AUTOTUNE
)

test_dataset = test_dataset.prefetch(
    buffer_size=AUTOTUNE
)


# ============================================================
# 10. DATA AUGMENTATION
# ============================================================

data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.1),
    layers.RandomZoom(0.1),
    layers.RandomContrast(0.1)
])


# ============================================================
# 11. LOAD PRE-TRAINED MOBILENETV2
# ============================================================

print("\nLoading MobileNetV2...")

base_model = MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet"
)


# Freeze pre-trained layers
base_model.trainable = False


# ============================================================
# 12. CREATE MODEL
# ============================================================

inputs = layers.Input(
    shape=(224, 224, 3)
)

x = data_augmentation(inputs)

x = preprocess_input(x)

x = base_model(
    x,
    training=False
)

x = layers.GlobalAveragePooling2D()(x)

x = layers.Dropout(0.2)(x)

outputs = layers.Dense(
    len(class_names),
    activation="softmax"
)(x)

model = models.Model(
    inputs,
    outputs
)


# ============================================================
# 13. COMPILE MODEL
# ============================================================

model.compile(
    optimizer=tf.keras.optimizers.Adam(
        learning_rate=0.001
    ),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"]
)


# ============================================================
# 14. DISPLAY MODEL
# ============================================================

model.summary()


# ============================================================
# 15. TRAIN MODEL
# ============================================================

print("\n========================================")
print("Starting model training")
print("========================================")

history = model.fit(
    train_dataset,
    validation_data=validation_dataset,
    epochs=EPOCHS
)


# ============================================================
# 16. SAVE MODEL
# ============================================================

model_path = os.path.join(
    MODEL_DIR,
    "food_recognition_mobilenetv2.keras"
)

model.save(model_path)

print("\n========================================")
print("Model saved successfully:")
print(model_path)
print("========================================")


# ============================================================
# 17. VALIDATION EVALUATION
# ============================================================

print("\nEvaluating validation dataset...")

validation_loss, validation_accuracy = model.evaluate(
    validation_dataset,
    verbose=1
)

print("\nValidation Accuracy:")
print(
    f"{validation_accuracy * 100:.2f}%"
)


# ============================================================
# 18. TEST DATA EVALUATION
# ============================================================

print("\n========================================")
print("Evaluating unseen TEST dataset")
print("========================================")

test_loss, test_accuracy = model.evaluate(
    test_dataset,
    verbose=1
)

print("\nTest Accuracy:")
print(
    f"{test_accuracy * 100:.2f}%"
)


# ============================================================
# 19. PLOT TRAINING AND VALIDATION ACCURACY
# ============================================================

plt.figure(figsize=(8, 5))

plt.plot(
    history.history["accuracy"],
    label="Training Accuracy"
)

plt.plot(
    history.history["val_accuracy"],
    label="Validation Accuracy"
)

plt.title(
    "Food Recognition Model Accuracy"
)

plt.xlabel("Epoch")

plt.ylabel("Accuracy")

plt.legend()

plt.savefig(
    "training_accuracy.png"
)

plt.close()


# ============================================================
# 20. PLOT TRAINING AND VALIDATION LOSS
# ============================================================

plt.figure(figsize=(8, 5))

plt.plot(
    history.history["loss"],
    label="Training Loss"
)

plt.plot(
    history.history["val_loss"],
    label="Validation Loss"
)

plt.title(
    "Food Recognition Model Loss"
)

plt.xlabel("Epoch")

plt.ylabel("Loss")

plt.legend()

plt.savefig(
    "training_loss.png"
)

plt.close()


# ============================================================
# 21. FINAL SUMMARY
# ============================================================

print("\n========================================")
print("TRAINING COMPLETED")
print("========================================")

print(
    f"Validation Accuracy: "
    f"{validation_accuracy * 100:.2f}%"
)

print(
    f"Test Accuracy: "
    f"{test_accuracy * 100:.2f}%"
)

print("\nModel:")
print(model_path)

print("\nClass names:")
print("class_names.json")

print("\nTraining graph:")
print("training_accuracy.png")

print("\nLoss graph:")
print("training_loss.png")

print("\n========================================")