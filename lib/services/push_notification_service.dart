import 'dart:convert';
import 'package:calendar_app/services/string_env.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

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
    } catch (e) {
      debugPrint('Error obtaining access token: $e');
      return null;
    }
  }

  /// Send push notification using FCM HTTP v1 API with OAuth2 access token
  Future<bool> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
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

      final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/${serviceAccountJson['project_id']}/messages:send');

      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data ?? {},
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

  Map<String, dynamic>? _getServiceAccountJson() {
    try {
      final privateKey =
          StringEnv()['PRIVATE_KEY']?.replaceAll('\n', '\\n') ?? '';
      final jsonString = '''{
        "type": "${StringEnv()['TYPE']}",
        "project_id": "${StringEnv()['PROJECT_ID']}",
        "private_key_id": "${StringEnv()['PRIVATE_KEY_ID']}",
        "private_key": "$privateKey",
        "client_email": "${StringEnv()['CLIENT_EMAIL']}",
        "client_id": "${StringEnv()['CLIENT_ID']}",
        "auth_uri": "${StringEnv()['AUTH_URI']}",
        "token_uri": "${StringEnv()['TOKEN_URI']}",
        "auth_provider_x509_cert_url": "${StringEnv()['AUTH_PROVIDER_X509_CERT_URL']}",
        "client_x509_cert_url": "${StringEnv()['CLIENT_X509_CERT_URL']}"
      }''';

      return json.decode(jsonString);
    } catch (e) {
      debugPrint('Error parsing service account JSON: $e');
      return null;
    }
  }
}
