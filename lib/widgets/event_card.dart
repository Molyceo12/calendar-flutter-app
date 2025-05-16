import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/models/event.dart'; // Assuming you have an Event model
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.description),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('h:mm a').format(event.date),
                  style: const TextStyle(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                if (event.hasNotification) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.notifications_active,
                    size: 16,
                    color: AppTheme.primaryColor,
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
              icon: const Icon(Icons.edit, color: AppTheme.secondaryColor),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
