import 'package:flutter/material.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/services/firebase_service.dart';

class EventProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EventProvider() {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _firebaseService.getEvents();
    } catch (e) {
      _error = 'Failed to load events: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<Event>> get eventsStream => _firebaseService.getEventsStream();

  List<Event> getEventsForDate(DateTime date) {
    return _events.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();
  }

  Future<void> addEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String eventId = await _firebaseService.createEvent(event);
      Event newEvent = Event(
        id: eventId,
        title: event.title,
        date: event.date,
        startTime: event.startTime,
        endTime: event.endTime,
        category: event.category,
        note: event.note,
        attendees: event.attendees,
      );
      _events.add(newEvent);
    } catch (e) {
      _error = 'Failed to add event: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateEvent(event);
      int index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = event;
      }
    } catch (e) {
      _error = 'Failed to update event: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteEvent(eventId);
      _events.removeWhere((event) => event.id == eventId);
    } catch (e) {
      _error = 'Failed to delete event: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
