import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:calendar_app/firebase_options.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/theme_provider.dart';
import 'package:calendar_app/screens/auth_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/screens/onboarding_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';

// Global instance for notifications
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _showNotification(message);

  // Handle any background message processing here
  if (message.data.isNotEmpty) {
    debugPrint('Background message data: ${message.data}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services sequentially with error handling
  try {
    // Firebase initialization
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notifications
    await _initializeNotifications();

    // Configure FCM
    await _configureFirebaseMessaging();

    // Load preferences
    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('showOnboarding') ?? true;

    runApp(
      ProviderScope(
        child: MyApp(showOnboarding: showOnboarding),
      ),
    );
  } catch (e, stack) {
    debugPrint('Initialization error: $e\n$stack');
    // Fallback UI if initialization fails
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app. Please restart.'),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
    onDidReceiveNotificationResponse: (response) {
      // Handle notification taps
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        debugPrint('Notification tapped with data: $data');
      }
    },
  );

  // Android notification channel
  const androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    playSound: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

Future<void> _configureFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  // Request permissions (platform-aware)
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false, // For iOS - non-provisional permissions
  );
  debugPrint('Notification permissions: ${settings.authorizationStatus}');

  // Configure foreground presentation
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // Token handling
  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');
  messaging.onTokenRefresh.listen((newToken) async {
    debugPrint('Token refreshed: $newToken');
    // Send token to backend for storage and user association
    try {
      await http.post(
        Uri.parse('YOUR_BACKEND_URL/update-token'),
        body: {'token': newToken},
        headers: {'Authorization': 'Bearer USER_AUTH_TOKEN'},
      );
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  });

  // Message handlers
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initial message (app opened from terminated state)
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    _handleBackgroundMessage(initialMessage);
  }
}

Future<void> _showNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        icon: message.notification?.android?.smallIcon,
        color: Colors.blue,
        priority: Priority.high,
        importance: Importance.max,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

void _handleForegroundMessage(RemoteMessage message) {
  debugPrint('Foreground message: ${message.messageId}');
  _showNotification(message);
  _processMessageData(message.data);
}

void _handleBackgroundMessage(RemoteMessage message) {
  debugPrint('Background message: ${message.messageId}');
  _processMessageData(message.data);
}

void _processMessageData(Map<String, dynamic> data) {
  debugPrint('Message data: $data');
  // Implement your navigation logic based on message data
  // Example:
  // if (data['type'] == 'event_reminder') {
  //   navigatorKey.currentState?.pushNamed('/event/${data['eventId']}');
  // }
}

class MyApp extends ConsumerWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider).themeMode;

    return MaterialApp(
      title: 'Calendar App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: showOnboarding
          ? const OnboardingScreen()
          : authState.when(
              data: (user) =>
                  user != null ? const HomeScreen() : const AuthScreen(),
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const AuthScreen(),
            ),
    );
  }
}
