import 'package:calendar_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onNotifyToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    this.onNotifyToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 12,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Color(
                int.parse(event.color.substring(1), radix: 16) + 0xFF000000),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
        ),
        title: Text(
          event.title,
          style: AppTheme.headingSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.description,
                style: textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(event.date),
                  style: AppTheme.bodySmall.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                if (event.hasNotification) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colorScheme.secondary),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: colorScheme.error),
              onPressed: onDelete,
            ),
            IconButton(
              icon: Icon(
                event.hasNotification
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: event.hasNotification
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onPressed: onNotifyToggle,
              tooltip: event.hasNotification
                  ? 'Disable Notification'
                  : 'Enable Notification',
            ),
          ],
        ),
      ),
    );
  }
}
