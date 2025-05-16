import 'package:flutter/material.dart';

class AuthToggle extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const AuthToggle({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: theme.textTheme.bodySmall,
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(
            isLogin ? "Sign Up" : "Login",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
