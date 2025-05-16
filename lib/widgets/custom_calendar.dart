import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/models/event.dart'; // Assuming you have an Event model

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final List<Event> events; // Assuming Event is your event model

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(selectedDay, day);
        },
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          formatButtonTextStyle: TextStyle(color: AppTheme.textPrimaryColor),
        ),
        // Event markers
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            // Check if this day has events
            final hasEvents =
                this.events.any((event) => isSameDay(event.date, day));

            if (hasEvents) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
