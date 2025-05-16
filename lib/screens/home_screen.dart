import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/screens/set_schedule_screen.dart';
import 'package:calendar_app/widgets/custom_app_bar.dart';
import 'package:calendar_app/widgets/custom_calendar.dart';
import 'package:calendar_app/widgets/date_header.dart';
import 'package:calendar_app/widgets/empty_events_view.dart';
import 'package:calendar_app/widgets/event_card.dart';
import 'package:calendar_app/widgets/confirmation_dialog.dart';
import 'package:calendar_app/widgets/custom_snackbar.dart';
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
      appBar: CustomAppBar(
        title: 'Calendar',
        onLogout: _showLogoutDialog,
      ),
      body: Column(
        children: [
          // Calendar widget
          eventsAsync.when(
            data: (events) => CustomCalendar(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              calendarFormat: _calendarFormat,
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
              events: events,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox(height: 300),
          ),

          // Selected day header
          if (_selectedDay != null) DateHeader(selectedDay: _selectedDay!),

          const Divider(),

          // Events list for selected day
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                final dayEvents = events
                    .where((event) => isSameDay(event.date, _selectedDay))
                    .toList();

                if (dayEvents.isEmpty) {
                  return EmptyEventsView(
                    onAddEvent: () => _navigateToAddEvent(_selectedDay!),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dayEvents.length,
                  itemBuilder: (context, index) {
                    final event = dayEvents[index];
                    return EventCard(
                      event: event,
                      onEdit: () => _navigateToEditEvent(event),
                      onDelete: () => _deleteEvent(event.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error loading events: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEvent(_selectedDay!),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Navigate to add event screen
  void _navigateToAddEvent(DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetScheduleScreen(selectedDate: selectedDate),
      ),
    );
  }

  // Navigate to edit event screen
  void _navigateToEditEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetScheduleScreen(event: event),
      ),
    );
  }

  // Delete an event
  Future<void> _deleteEvent(String id) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Event',
      content: 'Are you sure you want to delete this event?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirmed == true) {
      try {
        await ref.read(eventControllerProvider.notifier).deleteEvent(id);
        if (!mounted) return;
        CustomSnackbar.showSuccess(context, 'Event deleted successfully');
      } catch (e) {
        if (!mounted) return;
        CustomSnackbar.showError(context, 'Failed to delete event: $e');
      }
    }
  }

  // Show logout dialog
  Future<void> _showLogoutDialog() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (confirmed == true) {
      try {
        await ref.read(authControllerProvider.notifier).signOut();
      } catch (e) {
        if (!mounted) return;
        CustomSnackbar.showError(context, 'Failed to logout: $e');
      }
    }
  }
}