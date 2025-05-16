import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? [
            AppTheme.darkPrimaryColor.withValues(alpha: 0.7),
            AppTheme.darkSecondaryColor,
            AppTheme.darkAccentColor,
          ]
        : [
            const Color(0xFFB2DFDB).withValues(alpha: 0.7),
            const Color(0xFFF48FB1).withValues(alpha: 0.7),
            const Color(0xFFB39DDB).withValues(alpha: 0.7),
          ];

    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}
