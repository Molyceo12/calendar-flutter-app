import 'dart:convert';
import 'package:calendar_app/services/string_env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  /// Obtain OAuth2 access token using service account credentials
  Future<String?> _getAccessToken() async {
    try {
      final serviceAccountJson = _getServiceAccountJson();
      if (serviceAccountJson == null) {
        debugPrint('Service account JSON is missing or invalid');
        return null;
      }

      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();

      return accessToken;
    } catch (e, stack) {
      debugPrint('Error obtaining access token: $e\n$stack');
      return null;
    }
  }

  /// Schedules a notification for a calendar event
  Future<bool> scheduleEventNotification({
    required String userId,
    required String eventId,
    required String title,
    required String body,
    required DateTime eventTime,
    Duration reminderBefore = const Duration(minutes: 30),
  }) async {
    try {
      // Validate input parameters
      if (userId.isEmpty || eventId.isEmpty || title.isEmpty) {
        debugPrint('Invalid parameters for scheduling notification');
        return false;
      }

      // Get the user's active device tokens
      final tokens = await _getUserDeviceTokens(userId);
      if (tokens.isEmpty) {
        debugPrint('No device tokens found for user $userId');
        return false;
      }

      // Calculate notification time
      final notificationTime = eventTime.subtract(reminderBefore);
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('Notification time is in the past');
        return false;
      }

      // Create the notification document
      await _firestore.collection('scheduled_notifications').add({
        'userId': userId,
        'eventId': eventId,
        'tokens': tokens,
        'title': title,
        'body': body,
        'scheduledTime': notificationTime,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'scheduled',
        'reminderBeforeMinutes': reminderBefore.inMinutes,
      });

      debugPrint('Notification scheduled successfully for event $eventId');
      return true;
    } catch (e, stack) {
      debugPrint('Error scheduling notification: $e\n$stack');
      return false;
    }
  }

  /// Retrieves all active device tokens for a user
  Future<List<String>> _getUserDeviceTokens(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .where('fcmToken', isNotEqualTo: null)
          .get();

      return userDoc.docs
          .where((doc) => doc.id != 'init')
          .map((doc) => doc['fcmToken'] as String)
          .where((token) => token.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error getting user device tokens: $e');
      return [];
    }
  }

  /// Sends an immediate push notification
  Future<bool> sendPushNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (fcmTokens.isEmpty) {
      debugPrint('No FCM tokens provided');
      return false;
    }

    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        debugPrint('Failed to obtain access token');
        return false;
      }

      final serviceAccountJson = _getServiceAccountJson();
      if (serviceAccountJson == null) {
        debugPrint('Service account JSON is missing or invalid');
        return false;
      }

      final projectId = serviceAccountJson['project_id'];
      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

      // Send to each token (in production, you might want to batch these)
      for (final token in fcmTokens) {
        final message = {
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': body,
            },
            'data': data ??
                {
                  'type': 'event_reminder',
                  'timestamp': DateTime.now().toString()
                },
          }
        };

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(message),
        );

        if (response.statusCode != 200) {
          debugPrint(
              'Failed to send push notification to $token: ${response.body}');
          return false;
        }
      }

      debugPrint(
          'Push notifications sent successfully to ${fcmTokens.length} devices');
      return true;
    } catch (e, stack) {
      debugPrint('Error sending push notification: $e\n$stack');
      return false;
    }
  }

  /// Helper method to get service account credentials
  Map<String, dynamic>? _getServiceAccountJson() {
    try {
      final privateKey =
          StringEnv()['PRIVATE_KEY']?.replaceAll('\n', '\\n') ?? '';
      if (privateKey.isEmpty) {
        debugPrint('Private key is empty');
        return null;
      }

      return {
        "type": StringEnv()['TYPE'] ?? "service_account",
        "project_id": StringEnv()['PROJECT_ID'] ?? "",
        "private_key_id": StringEnv()['PRIVATE_KEY_ID'] ?? "",
        "private_key": privateKey,
        "client_email": StringEnv()['CLIENT_EMAIL'] ?? "",
        "client_id": StringEnv()['CLIENT_ID'] ?? "",
        "auth_uri": StringEnv()['AUTH_URI'] ??
            "https://accounts.google.com/o/oauth2/auth",
        "token_uri":
            StringEnv()['TOKEN_URI'] ?? "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            StringEnv()['AUTH_PROVIDER_X509_CERT_URL'] ??
                "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": StringEnv()['CLIENT_X509_CERT_URL'] ?? "",
      };
    } catch (e, stack) {
      debugPrint('Error parsing service account JSON: $e\n$stack');
      return null;
    }
  }
}
