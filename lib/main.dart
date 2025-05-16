import 'package:calendar_app/firebase_options.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/theme_provider.dart';
import 'package:calendar_app/screens/auth_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/screens/onboarding_screen.dart';
import 'package:calendar_app/services/notification_service.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notification service
  await NotificationService().initialize();

  // Check if onboarding has been shown
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;

  runApp(
    ProviderScope(
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final bool showOnboarding;

  const MyApp({
    super.key,
    required this.showOnboarding,
  });

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
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              ),
              error: (_, __) => const AuthScreen(),
            ),
    );
  }
}
