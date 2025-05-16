import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/screens/set_schedule_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';
import 'package:calendar_app/widgets/add_event_fab.dart';
import 'package:calendar_app/widgets/calendar_app_bar.dart';
import 'package:calendar_app/widgets/calendar_widget.dart';
import 'package:calendar_app/widgets/confirmation_dialog.dart';
import 'package:calendar_app/widgets/events_list.dart';
import 'package:calendar_app/widgets/selected_date_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // Get events for the current month
    final eventsAsync = ref.watch(eventsForMonthProvider(_focusedDay));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CalendarAppBar(
        title: 'Calendar',
        onLogoutPressed: _showLogoutDialog,
      ),
      body: Column(
        children: [
          // Calendar widget
          CalendarWidget(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventsAsync: eventsAsync,
          ),

          // Selected day header
          SelectedDateHeader(selectedDay: _selectedDay!),

          const Divider(),

          // Events list for selected day
          Expanded(
            child: EventsList(
              selectedDay: _selectedDay!,
              eventsAsync: eventsAsync,
              onDeleteEvent: _deleteEvent,
            ),
          ),
        ],
      ),
      floatingActionButton: AddEventFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SetScheduleScreen(selectedDate: _selectedDay!),
            ),
          );
        },
      ),
    );
  }

  // Delete an event
  Future<void> _deleteEvent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Delete Event',
        content: 'Are you sure you want to delete this event?',
        confirmText: 'Delete',
        confirmColor: Colors.red,
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(eventControllerProvider.notifier).deleteEvent(id);
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show logout dialog
  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const ConfirmationDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        confirmText: 'Logout',
        confirmColor: AppTheme.primaryColor,
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authControllerProvider.notifier).signOut();
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: $e')),
        );
      }
    }
  }
}
