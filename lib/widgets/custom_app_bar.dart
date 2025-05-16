import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onLogout;
  final List<Widget>? additionalActions;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onLogout,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimaryColor),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        if (additionalActions != null) ...additionalActions!,
        IconButton(
          icon: const Icon(Icons.logout, color: AppTheme.textPrimaryColor),
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
