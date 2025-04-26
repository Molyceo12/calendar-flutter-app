import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/screens/onboarding_screen.dart';
import 'package:calendar_app/screens/auth/login_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/services/firebase_service.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/providers/reminder_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your generated options
  await FirebaseService.initialize();

  // Check if first launch
  final prefs = await SharedPreferences.getInstance();
  final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({Key? key, required this.showOnboarding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Calendar App',
        theme: AppTheme.lightTheme,
        home: showOnboarding ? const OnboardingScreen() : const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.uninitialized:
      default:
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}
