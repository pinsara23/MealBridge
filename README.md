# MealBridge

MealBridge is a Flutter-based food redistribution platform that connects food donors, recipients, volunteers, and administrators in real time. The app is designed to reduce food waste by helping restaurants and community donors share surplus food with people in need while enabling volunteers to coordinate delivery and verification workflows.

## Overview

This project includes:

- Donor dashboards for posting and tracking food donations
- Recipient flows for browsing and claiming available food
- Volunteer tools for task coordination and QR-based verification
- Admin reporting and oversight screens
- Real-time updates through WebSocket-based status notifications
- Location-aware features using Google Maps and geolocation services
- Integration with a backend API and ML prediction service

## Features

### For Donors
- Post available food donations
- View donation analytics and monthly trends
- Review active and historical donation records
- Manage restaurant profile details and password update
- Monitor real-time status changes for posted food

### For Recipients
- Browse claimable food items
- View donation details and availability information
- Claim food and track personal claim history
- Access food collections and status updates

### For Volunteers
- View assigned delivery and collection tasks
- Review task details and progress
- Scan QR codes to validate and complete tasks

### For Admins
- Dashboard overview and operational reporting
- Monitoring of platform activity, stats, and reports

## Tech Stack

- Flutter + Dart
- Material Design UI
- Google Maps Flutter
- Geolocation and geocoding
- SharedPreferences for local session storage
- HTTP client for API communication
- WebSockets for real-time updates
- Docker Compose for deployment of backend services
- PostgreSQL/PostGIS database
- Python ML service for prediction/analytics support

## Project Structure

```text
.
├── android/                 # Android project files
├── ios/                     # iOS project files
├── lib/
│   ├── main.dart            # App entry point and route registration
│   ├── models/              # Data models
│   ├── screens/             # Role-based UI screens
│   ├── services/            # API and WebSocket services
│   ├── theme/               # Theme and design constants
│   ├── utils/               # App constants and shared utilities
│   └── widgets/             # Reusable UI widgets
├── test/                    # Automated tests
├── web/                     # Web app configuration
├── docker/                  # Docker/nginx config
├── docker-compose.yaml      # Multi-service deployment setup
├── Dockerfile               # Container configuration
├── pubspec.yaml             # Flutter dependencies and project metadata
├── analysis_options.yaml    # Linting rules
├── README.md                # Project documentation
└── assets/                  # App assets and icons
```

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK 3.8.1 or newer
- Dart SDK compatible with the Flutter version
- Android Studio / Xcode for native builds (if required)
- Chrome or an emulator/device for app testing
- Docker Desktop (if using the included Docker stack)
- Git for version control

## Environment Configuration

This Flutter app connects to a backend API configured in [lib/services/api_service.dart](lib/services/api_service.dart).

Important note: the current source code uses a hardcoded backend URL:

```dart
final String baseUrl = "http://10.34.10.142:8080/api";
```

Update this value based on your environment:

- Android emulator: `http://10.0.2.2:8080/api`
- iOS simulator: `http://localhost:8080/api`
- Web: `http://localhost:8080/api`
- Production or LAN host: replace with your deployed API URL

## Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd MealBridge
```

2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Ensure the backend API is running, or use the Docker stack included in this repo.

## Running the App

### Flutter development run

```bash
flutter run
```

To run on a specific platform:

```bash
flutter run -d chrome
flutter run -d android
```

### Run the project with the Docker stack

The project includes a Docker Compose file that starts the application services:

```bash
docker compose up -d
```

This stack includes:

- Spring Boot API service
- Python ML service
- PostgreSQL database
- Flutter web frontend
- Watchtower updater service

To stop the stack:

```bash
docker compose down
```

To stop and remove volumes:

```bash
docker compose down -v
```

## App Roles and Navigation

The app is organized around the following roles:

- Donor
- Recipient
- Volunteer
- Admin

Route registration is defined in [lib/main.dart](lib/main.dart) and includes onboarding, authentication, role-specific dashboards, and operational screens.

## Development Notes

- The project follows a role-based screen structure under [lib/screens](lib/screens)
- Shared constants and route names are centralized in [lib/utils/constants.dart](lib/utils/constants.dart)
- API calls are handled in [lib/services/api_service.dart](lib/services/api_service.dart)
- WebSocket event handling is implemented in [lib/services/websocket_service.dart](lib/services/websocket_service.dart)

## Useful Commands

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

## Troubleshooting

### API connection issues
- Confirm the backend is running
- Check that the correct host and port are configured in [lib/services/api_service.dart](lib/services/api_service.dart)
- For Android emulators, use `10.0.2.2` instead of `localhost`

### Web app fails to load
- Ensure the backend is reachable on the expected port
- Confirm CORS and API gateway settings are configured correctly

### Docker issues
- Check container logs with:

```bash
docker compose logs -f
```

## Project Status

This repository is structured as the Flutter frontend for a larger MealBridge ecosystem. The app is functional as a client application for food donation workflows, with backend integration expected through the configured API and Docker services.

## License

This project does not currently include a license file. If you plan to publish or distribute it publicly, add an appropriate license before release.

## Contributing

Contributions are welcome. Please keep code changes aligned with the app's role-based architecture and ensure API integration remains compatible with the backend contract.
