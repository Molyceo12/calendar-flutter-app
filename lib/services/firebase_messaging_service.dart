
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'local_notification_service.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  Future<void> initialize(String userId) async {
    try {
      // Initialize local notifications
      await _localNotificationService.initialize();

      // Request permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint(
          'Notification permission status: ${settings.authorizationStatus}');

      // Get and store token
      final token = await _firebaseMessaging.getToken();
      debugPrint('Retrieved FCM token: $token');
      if (token != null) {
        await _updateFcmToken(userId, token);
        debugPrint('FCM token received and stored: $token');
      } else {
        debugPrint('FCM token is null, fallback to local notifications');
        // Fallback logic can be implemented here if needed
      }

      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> _updateFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'fcmTokenUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      _handleMessageContent(message);
      // Show local notification for foreground message
      if (message.notification != null) {
        _localNotificationService.showNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'Notification',
          body: message.notification?.body ?? '',
          payload: message.data['eventId'] ?? '',
        );
      }
    });

    // Background messages when app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Background message opened: ${message.messageId}');
      _handleMessageContent(message);
      _navigateBasedOnMessage(message);
    });

    // Initial message when app is launched from terminated state
    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint(
            'Initial message from terminated state: ${message.messageId}');
        _handleMessageContent(message);
        _navigateBasedOnMessage(message);
      }
    });
  }

  void _handleMessageContent(RemoteMessage message) {
    debugPrint('Message received: ${message.messageId}');
    debugPrint('Message data: ${message.data}');
    debugPrint('Message notification: ${message.notification?.title}');
  }

  void _navigateBasedOnMessage(RemoteMessage message) {
    _navigateBasedOnData(message.data);
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    if (data['type'] == 'event_reminder' && data['eventId'] != null) {
      // Implement your navigation to event details
      debugPrint('Should navigate to event: ${data['eventId']}');
    }
  }
}
