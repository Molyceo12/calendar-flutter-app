import 'package:flutter/material.dart';
import 'package:calendar_app/widgets/custom_form_field.dart';
import 'package:calendar_app/widgets/custom_button.dart';
import 'package:calendar_app/widgets/auth_toggle.dart';

class AuthForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onSubmit;
  final bool isLogin;
  final VoidCallback onToggleAuthMode;

  const AuthForm({
    super.key,
    required this.onSubmit,
    required this.isLogin,
    required this.onToggleAuthMode,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      String errorMsg = e.toString();
      // Extract only the error message after the last ']'
      if (errorMsg.contains(']')) {
        errorMsg = errorMsg.split(']').last.trim();
      }
      setState(() {
        _errorMessage = errorMsg;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            widget.isLogin ? "Welcome Back!" : "Create Account",
            style: theme.textTheme.displayLarge,
          ),
          const SizedBox(height: 10),
          Text(
            widget.isLogin ? "Sign in to continue" : "Sign up to get started",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 40),

          // Email Field
          CustomFormField(
            controller: _emailController,
            labelText: "Email",
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password Field
          CustomFormField(
            controller: _passwordController,
            labelText: "Password",
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: theme.iconTheme.color,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),

          const SizedBox(height: 30),

          // Login/Register Button
          CustomButton(
            text: widget.isLogin ? "Login" : "Sign Up",
            onPressed: _submit,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 20),

          // Toggle login/register
          Center(
            child: AuthToggle(
              isLogin: widget.isLogin,
              onToggle: widget.onToggleAuthMode,
            ),
          ),
        ],
      ),
    );
  }
}
