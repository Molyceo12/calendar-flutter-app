import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatelessWidget {
  final DateTime selectedDay;

  const DateHeader({
    super.key,
    required this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(selectedDay),
            style: AppTheme.headingSmall,
          ),
        ],
      ),
    );
  }
}
