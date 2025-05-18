import 'package:flutter/material.dart';
/// Widget to display a custom app bar with transparent background
class CalendarAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Function onLogoutPressed;

  const CalendarAppBar({
    super.key,
    required this.title,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => onLogoutPressed(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
