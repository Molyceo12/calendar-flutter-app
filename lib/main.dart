import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:calendar_app/firebase_options.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/theme_provider.dart';
import 'package:calendar_app/screens/auth_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/screens/onboarding_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Handle any background message processing here
  if (message.data.isNotEmpty) {
    debugPrint('Background message data: ${message.data}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure FCM
    await _configureFirebaseMessaging();

    final prefs = await SharedPreferences.getInstance();
    final showOnboarding = prefs.getBool('showOnboarding') ?? true;

    runApp(
      ProviderScope(
        child: MyApp(showOnboarding: showOnboarding),
      ),
    );
  } catch (e, stack) {
    debugPrint('Initialization error: $e\n$stack');
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

Future<void> _configureFirebaseMessaging() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  debugPrint('Notification permissions: ${settings.authorizationStatus}');

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final token = await messaging.getToken();
  debugPrint('FCM Token: $token');
  messaging.onTokenRefresh.listen((newToken) async {
    debugPrint('Token refreshed: $newToken');
    try {
      // Obtain current user ID from your auth provider
      final container = ProviderContainer();
      final user = container.read(authStateProvider).value;
      if (user != null) {
        final userId = user.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': newToken,
          'fcmTokenUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint('FCM token updated in Firestore for user $userId');
      }
    } catch (e) {
      debugPrint('Failed to update FCM token in Firestore: $e');
    }
  });
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    _handleBackgroundMessage(initialMessage);
  }
}

void _handleForegroundMessage(RemoteMessage message) {
  debugPrint('Foreground message: ${message.messageId}');
  _processMessageData(message.data);
}

void _handleBackgroundMessage(RemoteMessage message) {
  debugPrint('Background message: ${message.messageId}');
  _processMessageData(message.data);
}

void _processMessageData(Map<String, dynamic> data) {
  debugPrint('Message data: $data');
  // Implement your navigation logic based on message data
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
