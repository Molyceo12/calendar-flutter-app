import 'package:calendar_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56.0,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.backgroundColor,
        ),
        child: isLoading
            ? CircularProgressIndicator(color: AppTheme.backgroundColor)
            : Text(text, style: AppTheme.headingSmall),
      ),
    );
  }
}
