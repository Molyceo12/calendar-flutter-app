import 'package:calendar_app/services/string_env.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();

  PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  /// Send push notification using FCM HTTP API and server key
  Future<bool> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Use the actual FCM server key (legacy server key) from StringEnv
      final serverKey = StringEnv()['FCM_SERVER_KEY'];
      if (serverKey == null || serverKey.isEmpty) {
        debugPrint('FCM server key is missing');
        return false;
      }

      debugPrint('Using FCM Server Key: $serverKey');

      final postUrl = Uri.parse('https://fcm.googleapis.com/fcm/send');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final notification = {
        'title': title,
        'body': body,
      };

      final message = {
        'to': fcmToken,
        'notification': notification,
        'data': data ?? {},
      };

      final response = await http.post(
        postUrl,
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('Push notification sent successfully.');
        return true;
      } else {
        debugPrint('Failed to send push notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending push notification: $e');
      return false;
    }
  }
}
