import 'package:flutter/material.dart';
import 'package:calendar_app/services/notification_service.dart';
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

  Future<void> _handleToggle(bool newValue) async {
    setState(() {
      _toggleValue = newValue;
    });

    final updatedEvent = widget.event.copyWith(hasNotification: newValue);

    if (newValue) {
      await NotificationService().scheduleEventNotification(updatedEvent);
    } else {
      await NotificationService().cancelEventNotification(updatedEvent);
    }

    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Notify me before 30 minutes",
          style: theme.textTheme.bodyMedium,
        ),
        Switch(
          activeColor: theme.primaryColor,
          value: _toggleValue,
          onChanged: _handleToggle,
        ),
      ],
    );
  }
}
