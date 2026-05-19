# 🚀 NASA Explorer

NASA Explorer is a cross-platform mobile application developed using Flutter and Dart that allows users to explore real-time space content using NASA public APIs.

The application provides features such as the Astronomy Picture of the Day (APOD), NASA image and video search, offline favorites, Firebase authentication, dark mode, and local caching.

---

# ✨ Features

## 🌌 Explore Space Content

* View NASA's Astronomy Picture of the Day (APOD)
* Display image title, date, and description
* Support for both images and videos

## 🔍 Search NASA Media

* Search NASA image and video library
* Popular topic suggestions
* Recent searches stored locally

## ❤️ Favorites System

* Save favorite images and videos
* Offline access to saved content
* Local image caching using Path Provider

## 🔐 Authentication

* User signup and login using Firebase Authentication
* Logout functionality
* User profile management

## ⚙️ Settings & Preferences

* Dark mode support
* Profile editing
* Change password feature
* About application section

## 📶 Offline Support

* Favorites available offline
* Cached user profile information
* Network error handling

---

# 🛠 Technologies Used

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* SharedPreferences
* Path Provider
* REST APIs
* NASA APOD API
* NASA Image & Video Library API

---

# 🧠 Application Architecture

The application follows a structured architecture with separation of concerns:

* **Screens** → UI pages
* **Services** → API and Firebase operations
* **Models** → JSON parsing and data representation
* **Widgets** → Reusable UI components
* **Utils** → Helper functions and utilities

---

# 📱 Screenshots

>Visit My LinkedIn Profile Post
[Click Me](https://www.linkedin.com/posts/tharusha-x-dev_flutter-mobiledevelopment-firebase-ugcPost-7459986147557945344-poei?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAAEh-WqcBd-jNG7chJid5sQYY1MeHcfJYzB0)

Suggested screenshots:

* Splash Screen
* Login Screen
* Explore Screen
* Search Screen
* Favorites Screen
* Settings Screen

---

# 🔥 APIs Used

## NASA APOD API

Used to retrieve the Astronomy Picture of the Day.

## NASA Image & Video Library API

Used for searching NASA space-related images and videos.

---

# 🚀 Installation

## 1. Clone the repository

```bash
git clone https://github.com/Tharusha-X-Dev/Nasa-Explorer.git
```

## 2. Navigate to the project

```bash
cd Nasa-Explorer
```

## 3. Install dependencies

```bash
flutter pub get
```

## 4. Create `.env` file

Add your NASA API key inside:

```env
NASA_API_KEY=YOUR_API_KEY
```

## 5. Run the application

```bash
flutter run
```

---

# 📂 Project Structure

```plaintext
lib/
 ├── models/
 ├── screens/
 ├── services/
 ├── widgets/
 ├── utils/
 └── main.dart
```

---

# 🎯 Future Improvements

* Push notifications for new APOD updates
* Better video playback support
* Multi-language support
* Advanced search filters
* Cloud synchronization for favorites

---

# 👨‍💻 Developer

Developed by Tharusha

GitHub:
https://github.com/Tharusha-X-Dev

---

# 📜 License

This project was developed for educational purposes.
