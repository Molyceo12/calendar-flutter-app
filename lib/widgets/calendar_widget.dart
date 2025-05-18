import 'package:calendar_app/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

/// A custom calendar widget that displays events with markers
class CalendarWidget extends StatelessWidget {
  final CalendarFormat calendarFormat;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;
  final AsyncValue<List<Event>> eventsAsync;

  const CalendarWidget({
    super.key,
    required this.calendarFormat,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
    required this.eventsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
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
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          weekendTextStyle: TextStyle(color: theme.colorScheme.error),
          defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
          outsideTextStyle: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          markersMaxCount: 3,
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          
          weekdayStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: theme.colorScheme.error.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            final hasEvents = eventsAsync.maybeWhen(
              data: (events) =>
                  events.any((event) => isSameDay(event.date, day)),
              orElse: () => false,
            );

            if (hasEvents) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
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
