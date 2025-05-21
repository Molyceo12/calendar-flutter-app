import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:calendar_app/models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  factory NotificationService() => _instance;

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Kigali')); // Important!

    const AndroidNotificationChannel eventChannel = AndroidNotificationChannel(
      'event_channel', // id
      'Event Notifications', // title
      description: 'Notifications for scheduled events', // description
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(eventChannel);

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Android 13+ notifications permission
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (!await Permission.notification.isGranted) {
        await Permission.notification.request();
      }
    }

    // FCM permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received: ${message.messageId}');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'fcm_default_channel',
              'FCM Notifications',
              channelDescription: 'Default FCM channel',
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

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          'Notification clicked (onMessageOpenedApp): ${message.messageId}');
    });

    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched via notification: ${initialMessage.messageId}');
    }
  }

  /// Schedule a local notification
  Future<void> scheduleEventNotification(Event event) async {
    final bool shouldNotify = event.hasNotification;
    if (!shouldNotify) return;

    final DateTime eventDate = event.date;

    final DateTime notificationTime =
        eventDate.subtract(const Duration(minutes: 30));

    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint('Event is in the past. Skipping notification.');
      return;
    }

    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(notificationTime, tz.local);

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'event_channel',
        'Event Notifications',
        channelDescription: 'Notifications for scheduled events',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    debugPrint(
        'Scheduling notification: ${event.title} at $scheduledTime for event: ${event.id}');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      event.id.hashCode,
      event.title,
      event.description.isNotEmpty
          ? event.description
          : 'You have an upcoming event.',
      scheduledTime,
      notificationDetails,
      payload: event.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Schedule a test notification 1 minute from now for debugging
  Future<void> scheduleTestNotification() async {
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Notifications for testing purposes',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    debugPrint('Scheduling test notification at $scheduledTime');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Test Notification',
      'This is a test notification scheduled 1 minute from now.',
      scheduledTime,
      notificationDetails,
      payload: 'test_notification',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelEventNotification(Event event) async {
    await _flutterLocalNotificationsPlugin.cancel(event.id.hashCode);
    debugPrint('Cancelled notification for event: ${event.id}');
  }
}
