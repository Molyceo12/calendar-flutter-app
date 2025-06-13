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

  /// Obtain OAuth2 access token for FCM API
  Future<String?> _getAccessToken() async {
    try {
      final serviceAccountJson = _getServiceAccountJson();
      if (serviceAccountJson == null) return null;

      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();
      return accessToken;
    } catch (e, stack) {
      debugPrint('Error getting access token: $e\n$stack');
      return null;
    }
  }

  /// Schedule an event notification (30 min before by default)
  Future<bool> scheduleEventNotification({
    required String userId,
    required String eventId,
    required String title,
    required String body,
    required DateTime eventTime,
    Duration reminderBefore = const Duration(minutes: 30),
  }) async {
    try {
      final tokens = await _getUserDeviceTokens(userId);
      if (tokens.isEmpty) {
        debugPrint('No device tokens for user $userId');
        return false;
      }

      final notificationTime = eventTime.subtract(reminderBefore);
      if (notificationTime.isBefore(DateTime.now())) {
        debugPrint('Notification time is in the past');
        return false;
      }

      await _firestore.collection('scheduled_notifications').add({
        'userId': userId,
        'eventId': eventId,
        'tokens': tokens,
        'title': title,
        'body': body,
        'scheduledTime': notificationTime,
        'createdAt': FieldValue.serverTimestamp(),
        'triggered': false,
      });

      debugPrint('Event notification scheduled.');
      return true;
    } catch (e, stack) {
      debugPrint('Error scheduling: $e\n$stack');
      return false;
    }
  }

  /// Send immediate push notification (e.g., login/signup)
  Future<bool> sendPushNotification({
    required List<String> fcmTokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (fcmTokens.isEmpty) return false;

    final accessToken = await _getAccessToken();
    if (accessToken == null) return false;

    final projectId = _getServiceAccountJson()?['project_id'];
    final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');

    for (final token in fcmTokens) {
      final message = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': data ?? {'type': 'default'},
        }
      };

      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode(message));

      if (response.statusCode != 200) {
        debugPrint('Error sending push to $token: ${response.body}');
        return false;
      }
    }

    debugPrint('Push sent to ${fcmTokens.length} devices');
    return true;
  }

  /// Get user device tokens
  Future<List<String>> _getUserDeviceTokens(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .get();
      return snapshot.docs
          .map((doc) => doc.data()['fcmToken'] as String?)
          .whereType<String>()
          .where((token) => token.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error getting tokens: $e');
      return [];
    }
  }

  /// Get Service Account JSON
  Map<String, dynamic>? _getServiceAccountJson() {
    try {
      final privateKey =
          StringEnv()['PRIVATE_KEY']?.replaceAll(r'\n', '\n') ?? '';
      if (privateKey.isEmpty) return null;

      return {
        "type": StringEnv()['TYPE'],
        "project_id": StringEnv()['PROJECT_ID'],
        "private_key_id": StringEnv()['PRIVATE_KEY_ID'],
        "private_key": privateKey,
        "client_email": StringEnv()['CLIENT_EMAIL'],
        "client_id": StringEnv()['CLIENT_ID'],
        "auth_uri": StringEnv()['AUTH_URI'],
        "token_uri": StringEnv()['TOKEN_URI'],
        "auth_provider_x509_cert_url":
            StringEnv()['AUTH_PROVIDER_X509_CERT_URL'],
        "client_x509_cert_url": StringEnv()['CLIENT_X509_CERT_URL'],
      };
    } catch (e, stack) {
      debugPrint('Error in service account JSON: $e\n$stack');
      return null;
    }
  }
}
