# FoodLens - Food Recognition & Calorie Estimation System

FoodLens is an end-to-end full-stack application for Indian food recognition and real-time calorie estimation using a MobileNetV2 Deep Learning model, a Node.js Express API server, and a Flutter mobile application.

---

## 🏗️ Architecture & Project Structure

```text
FoodRecognitionML/
├── app.py                      <-- Flask ML Prediction API (Port 8000)
├── models/
│   └── food_recognition_mobilenetv2.keras <-- Trained MobileNetV2 model
├── class_names.json            <-- 15 Indian food categories
├── images/                     <-- Sample images for testing
├── dataset/                    <-- Training & test dataset folders
├── venv/                       <-- Python Virtual Environment
├── backend/                    <-- Node.js Express Backend (Port 5000)
│   ├── src/
│   │   ├── server.js           <-- Server entry point
│   │   ├── app.js              <-- Express app setup
│   │   ├── routes/             <-- API routes (/api/health, /api/nutrition, /api/predict)
│   │   ├── controllers/        <-- Request handlers
│   │   ├── services/           <-- Upstream Flask Axios service
│   │   ├── middleware/         <-- Multer upload & error handling
│   │   └── data/               <-- Calorie database (nutritionData.js)
│   ├── .env
│   ├── .env.example
│   └── package.json
├── frontend/
│   └── food_recognition_app/   <-- Flutter Mobile Application
│       ├── lib/
│       │   ├── config/         <-- API config (10.0.2.2 for Android emulator)
│       │   ├── models/         <-- JSON response data models
│       │   ├── services/       <-- HTTP network service
│       │   ├── screens/        <-- Home & Result screens
│       │   ├── widgets/        <-- Reusable UI widgets
│       │   └── main.dart
│       ├── pubspec.yaml
│       └── android/            <-- Cleartext traffic & permissions
└── README.md
```

---

## 🍲 Supported Food Classes (15 Items)

1. Biryani (180 kcal/100g)
2. Chole Bhature (260 kcal/100g)
3. Dabeli (220 kcal/100g)
4. Dal (110 kcal/100g)
5. Dhokla (160 kcal/100g)
6. Dosa (170 kcal/100g)
7. Jalebi (300 kcal/100g)
8. Kathi Roll (230 kcal/100g)
9. Kofta (210 kcal/100g)
10. Naan (290 kcal/100g)
11. Pakora (270 kcal/100g)
12. Paneer Dish (265 kcal/100g)
13. Pani Puri (150 kcal/100g)
14. Pav Bhaji (190 kcal/100g)
15. Vada Pav (240 kcal/100g)

---

## 🚀 How to Run the Project (Step-by-Step)

To run the complete system, open **3 separate terminal windows** in the root directory:

### Terminal 1: Python Flask ML Service (Port 8000)
```powershell
.\venv\Scripts\python.exe app.py
```
*Listens on `http://127.0.0.1:8000`*

---

### Terminal 2: Node.js Express Backend (Port 5000)
```powershell
cd backend
npm install
npm start
```
*Listens on `http://127.0.0.1:5000`*

---

### Terminal 3: Flutter Mobile Application
```powershell
cd frontend/food_recognition_app
flutter pub get
flutter run
```
*Select your Android Emulator, Chrome, or Windows Device.*

---

## 🌐 Network Configuration

- **Android Emulator**: Uses `http://10.0.2.2:5000` to connect to Node.js on your computer.
- **Physical Phone**:
  1. Find your PC local Wi-Fi IP address (e.g., `ipconfig` -> `192.168.1.X`).
  2. Update `lib/config/api_config.dart` to use `http://192.168.1.X:5000`.
  3. Ensure Windows Firewall allows incoming connections on Port `5000`.

---

## 📊 Calorie Estimation Formula

Calories are calculated based on average nutritional benchmarks:

$$\text{Estimated Calories} = \frac{\text{Calories per 100g} \times \text{Portion Weight (g)}}{100}$$

*Note: Calorie estimates are approximate and vary based on ingredients, oil, ghee, and serving styles.*

---

## 🧪 Testing

To analyze and run Flutter tests:
```powershell
cd frontend/food_recognition_app
flutter analyze
flutter test
```
