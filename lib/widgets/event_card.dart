import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/avatar_stack.dart';

class EventCard extends StatelessWidget {
  final String time;
  final String title;
  final int attendeesCount;
  final Color backgroundColor;

  const EventCard({
    Key? key,
    required this.time,
    required this.title,
    this.attendeesCount = 0,
    this.backgroundColor = AppTheme.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                if (attendeesCount > 0)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: AvatarStack(
                      count: attendeesCount,
                      backgroundColor: backgroundColor,
                      size: 32,
                      spacing: 8,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
