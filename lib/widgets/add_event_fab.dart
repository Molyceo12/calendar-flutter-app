import 'package:flutter/material.dart';

/// A custom floating action button with app theme styling
class AddEventFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddEventFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colorScheme.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.add,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
