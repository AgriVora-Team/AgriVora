🌱 AgriVora
AI-Powered Smart Crop Recommendation System for Sri Lankan Agriculture
AgriVora is a mobile, IoT-enabled, AI-powered crop recommendation system designed to assist Sri Lankan farmers and home gardeners in selecting the most suitable crops based on soil and environmental conditions.
The system integrates computer vision, real-time pH sensing, GPS-based soil data, weather APIs, and machine learning models into a unified intelligent platform.
________________________________________
📌 Project Purpose
Agricultural decision-making in Sri Lanka often relies on traditional knowledge without precise soil and environmental analysis.
AgriVora addresses this challenge by:
•	Analyzing soil images using Computer Vision
•	Collecting real-time soil pH using IoT sensors
•	Fetching location-based soil and weather data
•	Applying Machine Learning to recommend suitable crops
•	Providing ranked crop suggestions with suitability scores and improvement tips
________________________________________
🏗️ System Architecture
ESP32 + pH Sensor
        ↓
Flutter Mobile App
        ↓
Backend (FastAPI / Node.js)
        ↓
ML Models + External APIs
        ↓
Crop Recommendations → Mobile App
Architecture Flow
1.	ESP32 collects real-time soil pH data
2.	User uploads soil image via mobile app
3.	App sends data to backend
4.	Backend processes:
o	CNN model (soil classification)
o	Random Forest model (crop recommendation)
o	SoilGrids API (soil properties)
o	OpenWeather API (weather data)
5.	Ranked crop recommendations are returned to the app
________________________________________
📱 Core Features
1️⃣ Soil Image Analysis (Computer Vision)
•	Soil texture classification (Sandy, Clayey, Loamy, etc.)
•	HSV Colour Histogram Analysis
•	Texture Analysis (GLCM, LBP)
•	Lightweight CNN (MobileNet / EfficientNet)
2️⃣ Real-Time Soil pH Testing (IoT)
•	ESP32 Microcontroller
•	Gravity Analog pH Sensor (calibrated)
•	Bluetooth / WiFi communication with mobile app
3️⃣ Location-Based Soil Data
•	GPS integration
•	Soil property retrieval via SoilGrids API
4️⃣ Weather-Based Insights
•	Real-time weather data from OpenWeather API
•	Rainfall, temperature, humidity analysis
5️⃣ Machine Learning Crop Recommendation
•	Random Forest Model
•	Ranked crop suggestions
•	Suitability scores
•	Soil improvement recommendations
6️⃣ Additional Functionalities
•	Manual soil entry mode
•	Weather insights dashboard
•	Map-based view
•	AI chatbot support
•	Historical data tracking
________________________________________
🧠 Machine Learning Models
🌾 Soil Classification Model
•	Input: Soil image
•	Techniques:
o	HSV Colour Analysis
o	GLCM Texture Features
o	LBP Features
o	Lightweight CNN
•	Output: Soil type category
🌱 Crop Recommendation Model
•	Algorithm: Random Forest
•	Input Features:
o	Soil type
o	Soil pH
o	Temperature
o	Humidity
o	Rainfall
•	Output:
o	Ranked crop list
o	Suitability score (%)
________________________________________
🛠️ Technology Stack
📱 Frontend
•	Flutter (Dart)
•	Firebase Firestore
•	Figma (UI/UX Design)
⚙️ Backend
•	FastAPI / Node.js
•	Python (scikit-learn, TensorFlow/Keras, OpenCV)
🌍 APIs
•	SoilGrids API
•	OpenWeather API
🔌 Hardware
•	ESP32
•	Gravity Analog pH Sensor
________________________________________
📂 Repository Structure (Example)
AgriVora/
│
├── frontend/               # Flutter mobile app
├── backend/                # API & ML integration
├── ml-models/              # CNN + Random Forest models
├── hardware/               # ESP32 code
├── docs/                   # Diagrams & documentation
└── README.md
________________________________________
🎯 Target Users
•	Sri Lankan farmers
•	Home gardeners
•	Agricultural students
•	Smart farming researchers
________________________________________
🌍 Sustainability Impact
AgriVora contributes to:
•	🌱 Improved crop productivity
•	💧 Efficient soil management
•	📉 Reduced crop failure risk
•	🌏 Sustainable agriculture practices
Aligned with:
•	UN SDG 2 – Zero Hunger
•	UN SDG 12 – Responsible Consumption & Production
________________________________________
🚀 Future Enhancements
•	Sinhala / Tamil language support
•	Cloud-based ML deployment
•	Government agricultural dataset integration
•	Marketplace integration for farmers
•	AI-based fertilizer optimization
________________________________________
👨‍💻 Development Team
AgriVora is developed as a Software Development group project, integrating mobile development, IoT engineering, machine learning, and backend systems.
________________________________________
📌 Status
🔧 Currently under active development.
