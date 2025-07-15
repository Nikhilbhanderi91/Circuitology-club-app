# ⚡ Circuitology Club App (Flutter)

A modern Flutter-based mobile application for the **Circuitology Club**, designed to handle event participation, user registration, login, and result viewing. This app connects seamlessly with the Laravel-powered backend using RESTful APIs.

---

## 📱 Features

### 👤 User Side
- Register and log in as a member
- View upcoming and finished events
- Register for events with agreement to terms
- View winners of finished events
- Smooth animations and responsive UI
- Persistent login with SharedPreferences

### 🛠️ Admin Side (from app)
- Secure admin login
- View all events with buttons to manage members or winners
- Fetch event participants and winners from API

---

## 🧰 Tech Stack

| Layer       | Technology             |
|-------------|-------------------------|
| Frontend    | Flutter (Dart)          |
| State Mgmt  | setState / FutureBuilder |
| API Comm    | HTTP package            |
| Storage     | SharedPreferences       |
| Animations  | flutter_animate         |
| UI Library  | Google Fonts, Material  |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio / VS Code
- Connected Android/iOS emulator or real device

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/circuitology_flutter_app.git

# Navigate into the project directory
cd circuitology_flutter_app

# Install dependencies
flutter pub get

# Run the app
flutter run
