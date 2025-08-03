# Calendar App

A minimal calendar app with three screens, built with Flutter. This app features user onboarding, authentication, event scheduling, and push notifications using Firebase Cloud Messaging. It supports light and dark themes and uses Riverpod for state management.

## Features

- User onboarding flow on first launch
- User authentication with Firebase Auth
- Event scheduling and management
- Push notifications with Firebase Cloud Messaging and local notifications
- Light and dark theme support
- State management with Riverpod
- Cross-platform support: Android, iOS, Web, Windows, macOS, Linux

## Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Firebase project setup with Authentication, Firestore, and Cloud Messaging enabled
- Android Studio or Xcode for platform-specific builds (optional)

## Installation and Setup

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd calendar_app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:

   - Follow the Firebase setup guide for Flutter: https://firebase.flutter.dev/docs/overview/
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files to the respective platform folders.
   - Update `firebase_options.dart` with your Firebase project configuration using the FlutterFire CLI.

4. (Optional) Set up environment variables in `.env` file if used.

## Running the App

- To run in debug mode on a connected device or emulator:

  ```bash
  flutter run
  ```

- To build release versions:

  - Android:

    ```bash
    flutter build apk
    ```

  - iOS:

    ```bash
    flutter build ios
    ```

  - Web:

    ```bash
    flutter build web
    ```

## Project Structure

- `lib/`
  - `controllers/` - State controllers for app logic
  - `models/` - Data models such as Event
  - `providers/` - Riverpod providers for state management
  - `screens/` - UI screens (Home, Auth, Onboarding, etc.)
  - `services/` - Services for Firebase, notifications, authentication, database
  - `theme/` - App theming and styles
  - `widgets/` - Reusable UI components
  - `main.dart` - App entry point and initialization

## Notifications Setup

- Uses Firebase Cloud Messaging (FCM) for push notifications
- Local notifications handled with `flutter_local_notifications`
- Background and foreground message handling implemented
- Notification channels configured for Android

## State Management

- Uses Riverpod for reactive and scalable state management
- Providers manage authentication state, theme, and event data

## Contributing

Contributions are welcome! Please open issues or submit pull requests for improvements or bug fixes.

## Contributors

-Irimaso Maurice

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Riverpod State Management](https://riverpod.dev/)

---

Thank you for using the Calendar App!
