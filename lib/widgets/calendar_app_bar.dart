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
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E293B), // AppTheme.textPrimaryColor
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Color(0xFF1E293B), // AppTheme.textPrimaryColor
          ),
          onPressed: () => onLogoutPressed(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
