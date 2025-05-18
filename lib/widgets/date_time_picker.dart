import 'package:calendar_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DateTimeTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const DateTimeTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(text, style: AppTheme.bodyMedium),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
