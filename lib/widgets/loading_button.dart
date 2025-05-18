import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String text;

  const LoadingButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.backgroundColor,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: AppTheme.headingSmall.copyWith(color: AppTheme.backgroundColor),
              ),
      ),
    );
  }
}
