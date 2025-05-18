import 'package:calendar_app/widgets/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerCard extends StatelessWidget {
  final DateTime selectedDate;
  final Function(BuildContext) selectDate;
  final Function(BuildContext) selectTime;

  const DateTimePickerCard({
    super.key,
    required this.selectedDate,
    required this.selectDate,
    required this.selectTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DateTimeTile(
              icon: Icons.calendar_today,
              text: DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
              onTap: () => selectDate(context),
            ),
            const Divider(),
            DateTimeTile(
              icon: Icons.access_time,
              text: DateFormat('h:mm a').format(selectedDate),
              onTap: () => selectTime(context),
            ),
          ],
        ),
      ),
    );
  }
}
