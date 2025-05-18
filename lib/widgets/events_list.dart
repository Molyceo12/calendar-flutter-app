import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/screens/set_schedule_screen.dart';
import 'package:calendar_app/widgets/event_card.dart';
import 'package:calendar_app/widgets/no_events_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_app/providers/event_provider.dart';

/// Widget to display the list of events for a selected day
class EventsList extends ConsumerWidget {
  final DateTime selectedDay;
  final AsyncValue<List<Event>> eventsAsync;
  final Function(String) onDeleteEvent;

  const EventsList({
    super.key,
    required this.selectedDay,
    required this.eventsAsync,
    required this.onDeleteEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    void toggleNotification(Event event) {
      final updatedEvent = event.copyWith(hasNotification: !event.hasNotification);
      ref.read(eventControllerProvider.notifier).updateEvent(updatedEvent);
    }

    return eventsAsync.when(
      data: (events) {
        final dayEvents = events
            .where((event) => isSameDay(event.date, selectedDay))
            .toList();

        if (dayEvents.isEmpty) {
          return NoEventsView(selectedDate: selectedDay);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dayEvents.length,
          itemBuilder: (context, index) {
            final event = dayEvents[index];
            return EventCard(
              event: event,
              onDelete: () => onDeleteEvent(event.id),
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetScheduleScreen(event: event),
                  ),
                );
              },
              onNotifyToggle: () => toggleNotification(event),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Error loading events: $error',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        ),
      ),
    );
  }
}
