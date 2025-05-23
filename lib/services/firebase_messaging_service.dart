import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();

  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize(String userId) async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission for notifications');
      } else {
        debugPrint('User declined or has not accepted permission for notifications');
      }

      // Get the token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('FCM token received: $token');
        // Save token to Firestore under user's document
        await _firestore.collection('users').doc(userId).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        debugPrint('FCM token updated in Firestore.');
      } else {
        debugPrint('Failed to get FCM token');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received a foreground message: ${message.messageId}');
        // Handle the message as needed
      });

      // Handle background and terminated messages are handled in native code or main.dart
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }
}
