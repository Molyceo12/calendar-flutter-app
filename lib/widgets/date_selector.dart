import 'package:calendar_app/widgets/date_card.dart';
import 'package:calendar_app/widgets/other_date_card.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app/utils/date_utils.dart';

class DateSelector extends StatelessWidget {
  final List<DateTime> dates;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool showOtherOption;

  const DateSelector({
    super.key,
    required this.dates,
    required this.selectedDate,
    required this.onDateSelected,
    this.showOtherOption = true,
  });

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
          }),
          
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