import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:calendar_app/firebase_options.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/theme_provider.dart';
import 'package:calendar_app/screens/auth_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/screens/onboarding_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Starting Firebase initialization...');
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase initialized.');

  debugPrint('Starting NotificationService initialization...');
  // Initialize notification service
  debugPrint('Getting FCM token...');
  // Get FCM token and update in Firestore
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final token = await messaging.getToken();
  debugPrint('FCM token received: $token');
  if (token != null) {
    await _updateTokenInFirestore(token);
    debugPrint('FCM token updated in Firestore.');
  }

  // Listen for token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    debugPrint('FCM token refreshed: $newToken');
    await _updateTokenInFirestore(newToken);
  });

  // Check if onboarding has been shown
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;

  debugPrint('Running app with showOnboarding=$showOnboarding');
  runApp(
    ProviderScope(
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

Future<void> _updateTokenInFirestore(String token) async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uid');

  if (uid != null) {
    String? deviceId = prefs.getString('deviceId');

    // Generate and save a new deviceId if not found
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('deviceId', deviceId);
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId)
          .set({
        'fcmToken': token,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update token in Firestore: $e');
    }
  } else {
    debugPrint('UID not found in SharedPreferences.');
  }
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
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              error: (_, __) => const AuthScreen(),
            ),
    );
  }
}
