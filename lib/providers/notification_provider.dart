import 'package:flutter/material.dart';
import 'package:calendar_app/models/notification_item.dart';
import 'package:calendar_app/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await NotificationService.getNotifications();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await NotificationService.markAsRead(id);

      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  Future<void> clearNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await NotificationService.clearNotifications();
      _notifications = [];
    } catch (e) {
      _error = 'Failed to clear notifications: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendTestNotification() async {
    try {
      await NotificationService.sendTestNotification();
      await fetchNotifications();
    } catch (e) {
      _error = 'Failed to send test notification: $e';
      notifyListeners();
    }
  }
}
