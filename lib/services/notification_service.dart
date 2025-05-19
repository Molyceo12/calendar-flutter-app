import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:calendar_app/models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
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

    // Initialize flutter_local_notifications for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize flutter_local_notifications for iOS
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
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request notification permissions for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request notification permissions on Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }

    // Get the token for this device
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle foreground messages and show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a foreground message: ${message.messageId}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'fcm_default_channel',
              'FCM Notifications',
              channelDescription: 'Firebase Cloud Messaging notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: message.data['payload'] ?? '',
        );
      }
    });

    // Handle background and terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked with message: ${message.messageId}');
      // Handle navigation or other logic on notification tap
    });
  }

  // Schedule a notification for an event 30 minutes before event time
  Future<void> scheduleEventNotification(Event event) async {
    if (!event.hasNotification) return;

    final notificationTime = event.date.subtract(const Duration(minutes: 30));
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('Notification time is in the past, not scheduling');
      return;
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(notificationTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_channel',
      'Event Notifications',
      channelDescription: 'Notifications for calendar events',
      importance: Importance.high,
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

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      event.id.hashCode,
      event.title,
      event.description.isNotEmpty ? event.description : 'Event reminder',
      scheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: event.id,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  // Cancel a notification for an event
  Future<void> cancelEventNotification(Event event) async {
    await _flutterLocalNotificationsPlugin.cancel(event.id.hashCode);
  }
}
