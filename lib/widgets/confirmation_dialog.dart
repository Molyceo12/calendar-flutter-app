import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

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
    this.confirmText = 'Confirm',
    this.confirmColor = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: TextStyle(color: confirmColor),
          ),
        ),
      ],
    );
  }

  // Helper method to show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    Color confirmColor = AppTheme.primaryColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
      ),
    );
  }
}
