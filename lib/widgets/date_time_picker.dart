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
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon),
      title: Text(text, style: theme.textTheme.bodyMedium),
      trailing: Icon(Icons.arrow_forward_ios ,size: 16),
      onTap: onTap,
    );
  }
}
