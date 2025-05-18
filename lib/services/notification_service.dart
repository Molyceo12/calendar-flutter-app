import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:calendar_app/models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Private constructor
  NotificationService._internal();

  // Singleton pattern
  factory NotificationService() {
    return _instance;
  }

  // Initialize notification service
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize notification settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize notification settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine platform-specific initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request notification permissions on Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  // Schedule a notification for an event
  Future<void> scheduleEventNotification(Event event) async {
    if (!event.hasNotification) return;

    // Schedule notification for 30 minutes before the event
    final notificationTime = event.date.subtract(const Duration(minutes: 30));

    debugPrint('Event date: ${event.date.toIso8601String()}');
    debugPrint('Notification time (local): ${notificationTime.toIso8601String()}');
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);
    debugPrint('Scheduled notification time (timezone aware): ${scheduledTime.toString()}');

    // Check if notification time is in the future
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('Notification time is in the past, not scheduling');
      return;
    }

    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      channelDescription: 'Notifications for calendar events',
      importance: Importance.high,
      priority: Priority.high,
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combine platform-specific notification details
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      event.id.hashCode, // Use event ID hash as notification ID
      event.title,
      event.description.isNotEmpty ? event.description : 'Event reminder',
      scheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload:
          event.id, // Use event ID as payload for handling notification tap
    );
  }

  // Cancel a notification for an event
  Future<void> cancelEventNotification(Event event) async {
    await _flutterLocalNotificationsPlugin.cancel(event.id.hashCode);
  }

  // Show an immediate test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification to verify functionality.',
      platformDetails,
      payload: 'test_payload',
    );
  }
}
