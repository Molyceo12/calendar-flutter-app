import 'package:flutter/material.dart';
import 'package:calendar_app/models/reminder.dart';
import 'package:calendar_app/services/firebase_service.dart';

class ReminderProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final List<Reminder> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<List<Reminder>> get remindersStream =>
      _firebaseService.getRemindersStream();

  Future<void> addReminder(Reminder reminder) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String reminderId = await _firebaseService.createReminder(reminder);
      Reminder newReminder = Reminder(
        id: reminderId,
        title: reminder.title,
        date: reminder.date,
        timeRange: reminder.timeRange,
      );
      _reminders.add(newReminder);
    } catch (e) {
      _error = 'Failed to add reminder: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteReminder(reminderId);
      _reminders.removeWhere((reminder) => reminder.id == reminderId);
    } catch (e) {
      _error = 'Failed to delete reminder: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
