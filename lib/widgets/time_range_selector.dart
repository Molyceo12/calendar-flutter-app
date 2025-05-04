import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';

class TimeRangeSelector extends StatelessWidget {
  final String startTime;
  final String endTime;
  final Function(String) onStartTimeChanged;
  final Function(String) onEndTimeChanged;

  const TimeRangeSelector({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "From",
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _parseTimeString(startTime),
                  );
                  
                  if (pickedTime != null) {
                    onStartTimeChanged(_formatTimeOfDay(pickedTime));
                  }
                },
                child: Text(
                  startTime,
                  style: AppTheme.timeText,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward,
            size: 32,
            color: AppTheme.textSecondaryColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "To",
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _parseTimeString(endTime),
                  );
                  
                  if (pickedTime != null) {
                    onEndTimeChanged(_formatTimeOfDay(pickedTime));
                  }
                },
                child: Text(
                  endTime,
                  style: AppTheme.timeText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split('.');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return "${time.hour}.${time.minute.toString().padLeft(2, '0')}";
  }
}
