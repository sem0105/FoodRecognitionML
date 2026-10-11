from datasets import load_dataset
from pathlib import Path

print("Downloading Indian Foods Dataset...")

dataset = load_dataset("shardulkamde/indian-foods-dataset")

print(dataset)

# Create folders
base_dir = Path("dataset")

train_dir = base_dir / "train"
test_dir = base_dir / "test"

train_dir.mkdir(parents=True, exist_ok=True)
test_dir.mkdir(parents=True, exist_ok=True)

# Save training images
print("\nSaving training images...")

for i, item in enumerate(dataset["train"]):
    image = item["image"]
    label = item["label"]

    class_name = dataset["train"].features["label"].int2str(label)

    class_dir = train_dir / class_name
    class_dir.mkdir(parents=True, exist_ok=True)

    image_path = class_dir / f"{i}.jpg"
    image.convert("RGB").save(image_path)

    if (i + 1) % 500 == 0:
        print(f"Saved {i + 1} training images")

# Save test images
print("\nSaving test images...")

for i, item in enumerate(dataset["test"]):
    image = item["image"]
    label = item["label"]

    class_name = dataset["test"].features["label"].int2str(label)

    class_dir = test_dir / class_name
    class_dir.mkdir(parents=True, exist_ok=True)

    image_path = class_dir / f"{i}.jpg"
    image.convert("RGB").save(image_path)

    if (i + 1) % 200 == 0:
        print(f"Saved {i + 1} test images")

print("\nDataset preparation completed!")
print("Training folder:", train_dir)
print("Test folder:", test_dir)