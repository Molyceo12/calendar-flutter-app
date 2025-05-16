import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/widgets/auth_form.dart';
import 'package:calendar_app/widgets/decorative_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _handleSubmit(String email, String password) async {
    if (_isLogin) {
      await ref.read(authControllerProvider.notifier).signIn(email, password);
    } else {
      await ref.read(authControllerProvider.notifier).register(email, password);
    }

    // Navigate to HomeScreen after successful login/register
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Decorative background
          const DecorativeBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Auth Form
                  AuthForm(
                    isLogin: _isLogin,
                    onToggleAuthMode: _toggleAuthMode,
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
