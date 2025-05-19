import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/services/notification_service.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Events for month provider
final eventsForMonthProvider =
    FutureProvider.family<List<Event>, DateTime>((ref, month) async {
  final dbService = ref.watch(databaseServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return [];
  }

  return await dbService.getEventsForMonth(month, userId);
});

// Event controller provider
final eventControllerProvider =
    StateNotifierProvider<EventController, AsyncValue<void>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return EventController(dbService, notificationService, ref);
});

// Event controller
class EventController extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _dbService;
  final NotificationService _notificationService;
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventController(this._dbService, this._notificationService, this._ref)
      : super(const AsyncValue.data(null));

  // Create a new event
  Future<void> createEvent(Event event) async {
    state = const AsyncValue.loading();
    try {
      // Save to SQLite
      await _dbService.insertEvent(event);

      // Save to Firestore
      final userId = _ref.read(userIdProvider);
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .set(event.toMap());
      }

      // Schedule notification if needed
      if (event.hasNotification) {
        await _notificationService.scheduleEventNotification(event);
      }

      // Refresh events list
      _ref.invalidate(eventsForMonthProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    state = const AsyncValue.loading();
    try {
      // Update in SQLite
      await _dbService.updateEvent(event);

      // Update in Firestore
      final userId = _ref.read(userIdProvider);
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .update(event.toMap());
      }

      // Cancel existing notification and schedule a new one if needed
      await _notificationService.cancelEventNotification(event);
      if (event.hasNotification) {
        await _notificationService.scheduleEventNotification(event);
      }

      // Refresh events list
      _ref.invalidate(eventsForMonthProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    state = const AsyncValue.loading();
    try {
      // Get the event first to cancel notification
      final userId = _ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final events = await _dbService.getEventsForUser(userId);
      final event = events.firstWhere((e) => e.id == id,
          orElse: () => throw Exception('Event not found'));

      // Cancel notification
      await _notificationService.cancelEventNotification(event);

      // Delete from SQLite
      await _dbService.deleteEvent(id);

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(id)
          .delete();

      // Refresh events list
      _ref.invalidate(eventsForMonthProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
