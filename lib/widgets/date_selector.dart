import 'package:flutter/material.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/utils/date_utils.dart';

class DateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool showOtherOption;

  const DateSelector({
    Key? key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
    this.showOtherOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...dates.map((date) {
            final bool isSelected = DateTimeUtils.isSameDay(date, selectedDate);
            
            return DateCard(
              date: date,
              isSelected: isSelected,
              onTap: () => onDateSelected(date),
            );
          }).toList(),
          
          if (showOtherOption)
            OtherDateCard(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                
                if (pickedDate != null) {
                  onDateSelected(pickedDate);
                }
              },
            ),
        ],
      ),
    );
  }
}

class DateCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const DateCard({
    Key? key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.secondaryColor
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              DateTimeUtils.formatDay(date),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateTimeUtils.formatWeekdayShort(date),
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherDateCard extends StatelessWidget {
  final VoidCallback onTap;

  const OtherDateCard({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          children: [
            Text(
              "Other",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Date",
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
