import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';

class NotificationToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Event event;

  const NotificationToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.event,
  });

  @override
  State<NotificationToggle> createState() => _NotificationToggleState();
}

class _NotificationToggleState extends State<NotificationToggle> {
  late bool _toggleValue;

  @override
  void initState() {
    super.initState();
    _toggleValue = widget.value;
  }

  void _handleToggle(bool newValue) {
    setState(() {
      _toggleValue = newValue;
    });

    // Just notify the parent and do not handle any notifications
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Notify me before 30 minutes",
          style: theme.textTheme.bodyMedium,
        ),
        Switch(
          activeColor: colorScheme.primary,
          inactiveThumbColor: colorScheme.onSurface.withValues(alpha:  0.6),
          inactiveTrackColor: colorScheme.onSurface.withValues(alpha: 0.3),
          value: _toggleValue,
          onChanged: _handleToggle,
        ),
      ],
    );
  }
}
