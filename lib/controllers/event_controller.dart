import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/providers/auth_provider.dart';
import 'package:calendar_app/providers/event_provider.dart';
import 'package:calendar_app/services/database_service.dart';
import 'package:calendar_app/services/push_notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventController extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _dbService;
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PushNotificationService _pushService = PushNotificationService();

  EventController(this._dbService, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createEvent(Event event) async {
    state = const AsyncValue.loading();
    try {
      // Save to local database
      await _dbService.insertEvent(event);

      final userId = _ref.read(userIdProvider);
      if (userId != null) {
        // Save to Firestore
        final eventMap = event.toMap();
        eventMap['date'] = Timestamp.fromDate(event.date);
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .set(eventMap);

        // Schedule notification if enabled
        if (event.hasNotification) {
          await _scheduleEventNotification(event, userId);
        }

        // Send confirmation notification
        await _sendEventNotification(
          event: event,
          title: 'Event Created: ${event.title}',
          body:
              'Your event "${event.title}" has been created for ${event.date}.',
        );
      }

      _ref.invalidate(eventsForMonthProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Error in createEvent: $e\n$stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    state = const AsyncValue.loading();
    try {
      await _dbService.updateEvent(event);

      final userId = _ref.read(userIdProvider);
      if (userId != null) {
        final eventMap = event.toMap();
        eventMap['date'] = Timestamp.fromDate(event.date);
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .update(eventMap);

        // Update scheduled notification
        if (event.hasNotification) {
          await _scheduleEventNotification(event, userId);
        } else {
          await _firestore
              .collection('scheduled_notifications')
              .doc(event.id)
              .delete();
        }
      }

      _ref.invalidate(eventsForMonthProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Error in updateEvent: $e\n$stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    state = const AsyncValue.loading();
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null) throw Exception('User not authenticated');

      await _dbService.deleteEvent(id);

      await Future.wait([
        _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(id)
            .delete(),
        _firestore.collection('scheduled_notifications').doc(id).delete(),
      ]);

      _ref.invalidate(eventsForMonthProvider);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      debugPrint('Error in deleteEvent: $e\n$stack');
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Stream<List<Event>> streamAllEvents() {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return const Stream.empty();

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
                date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
                color: data['color'] ?? '',
                hasNotification: data['hasNotification'] ?? false,
                userId: userId,
              );
            }).toList());
  }

  Future<void> _scheduleEventNotification(Event event, String userId) async {
    try {
      final notificationTime = event.date.subtract(const Duration(minutes: 30));
      final now = DateTime.now();

      if (notificationTime.isAfter(now)) {
        await _firestore
            .collection('scheduled_notifications')
            .doc(event.id)
            .set({
          'userId': userId,
          'eventId': event.id,
          'title': 'Upcoming Event: ${event.title}',
          'body': 'Your event "${event.title}" starts in 30 minutes',
          'scheduledTime': Timestamp.fromDate(notificationTime),
          'triggered': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> _sendEventNotification({
    required Event event,
    required String title,
    required String body,
  }) async {
    try {
      final userId = _ref.read(userIdProvider);
      if (userId == null) return;

      final tokens = await _getFcmTokens(userId);
      if (tokens.isEmpty) return;

      final success = await _pushService.sendPushNotification(
        fcmTokens: tokens,
        title: title,
        body: body,
        data: {'eventId': event.id, 'type': 'event_notification'},
      );

      if (success) {
        debugPrint('Notification sent for event ${event.id}');
      } else {
        debugPrint('Failed to send notification for event ${event.id}');
      }
    } catch (e, stack) {
      debugPrint('Error sending notification: $e\n$stack');
    }
  }

  Future<List<String>> _getFcmTokens(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .where('fcmToken', isNotEqualTo: null)
          .get();

      return snapshot.docs
          .map((doc) => doc['fcmToken'] as String)
          .where((token) => token.isNotEmpty)
          .toList();
    } catch (e, stack) {
      debugPrint('Error getting FCM tokens: $e\n$stack');
      return [];
    }
  }
}
