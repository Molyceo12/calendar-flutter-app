import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class DateTimeSelectorCard extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onSelectDate;
  final VoidCallback onSelectTime;

  const DateTimeSelectorCard({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.onSelectTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
              title: Text(
                DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                style: AppTheme.bodyMedium,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onSelectDate,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time, color: AppTheme.primaryColor),
              title: Text(
                DateFormat('h:mm a').format(selectedDate),
                style: AppTheme.bodyMedium,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onSelectTime,
            ),
          ],
        ),
      ),
    );
  }
}
