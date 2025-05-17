import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class NotificationToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NotificationToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Enable Notification",
          style: AppTheme.headingSmall,
        ),
        Switch(
          activeColor: AppTheme.primaryColor,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
