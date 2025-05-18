import 'package:calendar_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Confirmation dialog for various actions (delete, logout)
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Cancel',
    required this.confirmText,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText,
              style: AppTheme.bodyMedium.copyWith(color: confirmColor)),
        ),
      ],
    );
  }
}
