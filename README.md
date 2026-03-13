# RelieFlow — Public App (Frontend)

RelieFlow is a cross-platform Flutter application that connects people in need with aid and donation resources during disaster and relief events. It allows users to request aid, make donation requests, view nearby relief centres on a map, receive real-time push notifications, and access safety tips.

---

## Features

- **Authentication** — Secure login and sign-up flow with token-based session management.
- **Home Dashboard** — At-a-glance view of relief centres on a live map, current weather conditions, and the latest aid/donation requests.
- **Aid Requests** — Submit, track, and edit aid requests.
- **Donation Requests** — Create and manage donation request listings.
- **Requests List** — Browse all active aid and donation requests in one place.
- **Push Notifications** — Firebase Cloud Messaging (FCM) integration for real-time alerts; works in foreground, background, and terminated states.
- **Tips** — Curated volunteer and safety tips.
- **Profile** — View and manage your account details.
- **Glassmorphism UI** — Modern, soft visual design using Google Fonts (Plus Jakarta Sans) and a consistent teal/blue colour palette.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev/) (Dart) |
| State Management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) |
| Notifications | Firebase Core + Firebase Messaging |
| Maps | Google Maps Flutter |
| Location | Geolocator, Geocoding |
| Weather | [weather](https://pub.dev/packages/weather) |
| HTTP | [http](https://pub.dev/packages/http) |
| Local Storage | shared_preferences |
| UI Extras | glassmorphism, star_menu, persistent_bottom_nav_bar, google_fonts |

---

## Project Structure

```
lib/
├── main.dart                  # App entry point & Firebase initialisation
├── firebase_options.dart      # Generated Firebase configuration
├── components/                # Shared UI components (header, etc.)
├── models/                    # Data models
├── screens/
│   ├── auth/                  # Login & sign-up screens
│   ├── home/                  # Home dashboard
│   ├── aid_request/           # Aid request screens
│   ├── donation_request/      # Donation request screens
│   ├── request_donation/      # Donation creation flow
│   ├── requests_list/         # Combined requests list
│   ├── notifications/         # Notification centre
│   ├── tips/                  # Safety & volunteer tips
│   ├── quiz/                  # Interactive quiz
│   ├── Profile/               # User profile & account
│   ├── views/                 # Shared view widgets (map, weather card)
│   └── main_navigation/       # Bottom navigation scaffold
├── services/
│   ├── auth_service.dart      # Authentication & session helpers
│   ├── fcm_service.dart       # Firebase Cloud Messaging service
│   ├── notification_service.dart
│   └── notification_router.dart
└── theme/
    └── app_theme.dart         # Centralised theme, colours & typography
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.9.0
- A configured [Firebase](https://firebase.google.com/) project with:
  - Android & iOS apps registered
  - `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) placed in the correct directories
  - Firebase Cloud Messaging enabled
- A [Google Maps API key](https://developers.google.com/maps/documentation/flutter-sdk/get-started) with the Maps SDK enabled for your target platforms

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/rahul-p-v-2005/reliefflow-frontend.git
cd reliefflow-frontend

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Environment Configuration

Create a `lib/env.dart` file to supply runtime constants such as the API base URL and the token storage key referenced throughout the app. This file is already listed in `.gitignore` so it will **not** be committed to version control.

```dart
// lib/env.dart  (git-ignored — do not commit)
const String kBaseUrl = 'https://your-api-host.example.com';
const String kTokenStorageKey = 'auth_token';
```

---

## Running Tests

```bash
flutter test
```

---

## Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web --release
```

---

## Contributing

1. Fork the repository and create a feature branch.
2. Follow the existing code style (`flutter analyze` must pass).
3. Submit a pull request with a clear description of your changes.

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
