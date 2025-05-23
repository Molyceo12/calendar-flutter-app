import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/services/push_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class EventController extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _dbService;
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  EventController(this._dbService, this._ref)
      : super(const AsyncValue.data(null));

  // Create a new event
  Future<void> createEvent(Event event) async {
    state = const AsyncValue.loading();
    try {
      // Save to SQLite
      await _dbService.insertEvent(event);

      // Save to Firestore under user's events subcollection
      final userId = _ref.read(userIdProvider);
      if (userId != null) {
        final eventMap = event.toMap();
        eventMap['date'] = Timestamp.fromDate(event.date);
        eventMap['userId'] = userId;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .set(eventMap);
      }

      // Refresh events list
      _ref.invalidate(eventsForMonthProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Error in createEvent: $e');
      debugPrint('$stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Update an existing event
  Future<void> updateEvent(Event event) async {
    state = const AsyncValue.loading();
    try {
      await _dbService.updateEvent(event);

      final userId = _ref.read(userIdProvider);
      if (userId != null) {
        final eventMap = event.toMap();
        eventMap['date'] = Timestamp.fromDate(event.date);
        eventMap['userId'] = userId;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .update(eventMap);
      }

      _ref.invalidate(eventsForMonthProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Error in updateEvent: $e');
      debugPrint('$stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String id) async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final events = await _dbService.getEventsForUser(userId);
      final event = events.firstWhere(
        (e) => e.id == id,
        orElse: () => throw Exception('Event not found'),
      );

      await _dbService.deleteEvent(id);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(id)
          .delete();

      _ref.invalidate(eventsForMonthProvider);

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Error in deleteEvent: $e');
      debugPrint('$stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // Stream of all events for current user from Firestore
  Stream<List<Event>> streamAllEvents() {
    final userId = _ref.read(userIdProvider);
    if (userId == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Event(
                id: doc.id,
                title: data['title'] ?? '',
                description: data['description'] ?? '',
                date: (data['date'] as Timestamp).toDate(),
                color: data['color'] ?? '',
                hasNotification: data['has_notification'] ?? false,
                userId: userId,
              );
            }).toList());
  }

  // Get FCM token for current user from Firestore
  Future<String?> getFcmToken() async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return null;

    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    final data = docSnapshot.data();
    if (docSnapshot.exists && data != null && data.containsKey('fcmToken')) {
      return data['fcmToken'] as String;
    }
    return null;
  }

  // Listen to events stream and send push notification if event is 30 minutes after now
  void listenAndNotify() {
    streamAllEvents().listen((events) async {
      final now = DateTime.now();
      final fcmToken = await getFcmToken();
      if (fcmToken == null) {
        debugPrint('FCM token not found for user');
        return;
      }

      for (final event in events) {
        final difference = event.date.difference(now);
        if (difference.inMinutes == 30) {
          final title = 'Upcoming Event: ${event.title}';
          final body = 'Your event "${event.title}" starts in 30 minutes.';
          final data = {'eventId': event.id};

          final success = await PushNotificationService().sendPushNotification(
            fcmToken: fcmToken,
            title: title,
            body: body,
            data: data,
          );

          if (success) {
            debugPrint('Push notification sent for event ${event.id}');
          }
        }
      }
    });
  }
}
