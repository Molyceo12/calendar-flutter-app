import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  // Format date to display day number
  static String formatDay(DateTime date) {
    return date.day.toString();
  }

  // Format date to display short weekday (Mo, Tu, etc.)
  static String formatWeekdayShort(DateTime date) {
    return DateFormat('E').format(date).substring(0, 2);
  }

  // Format date to display full weekday (Monday, Tuesday, etc.)
  static String formatWeekday(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Format date to display month and day (Jan 21, Feb 15, etc.)
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  // Format time from 24-hour format to 12-hour format
  static String formatTime(String time) {
    // Parse the time string (e.g., "14.00")
    final parts = time.split('.');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;

    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    final hourOfPeriod =
        timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hourOfPeriod:${minute.toString().padLeft(2, '0')} $period';
  }

  // Generate a list of dates for the week
  static List<DateTime> generateWeekDays(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(
      7,
      (index) => DateTime(
        firstDayOfWeek.year,
        firstDayOfWeek.month,
        firstDayOfWeek.day + index,
      ),
    );
  }

  // Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
