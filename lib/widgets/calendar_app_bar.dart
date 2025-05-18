import 'package:calendar_app/theme/app_theme.dart';
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
        style: AppTheme.headingSmall,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: AppTheme.textPrimaryColor,
          ),
          onPressed: () => onLogoutPressed(),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
