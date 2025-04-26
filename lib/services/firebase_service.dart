import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/reminder.dart';
import 'package:calendar_app/firebase_options.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Initialize Firebase with your generated options
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Authentication methods
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create user profile in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update display name
        await user.updateDisplayName(name);
      }

      return user;
    } catch (e) {
      print('Error during sign up: $e');
      rethrow;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error during sign in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User methods
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Event methods
  Future<String> createEvent(Event event) async {
    try {
      User? user = getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String eventId = _uuid.v4();
      await _firestore.collection('events').doc(eventId).set({
        'id': eventId,
        'title': event.title,
        'date': event.date.toIso8601String(),
        'startTime': event.startTime,
        'endTime': event.endTime,
        'category': event.category,
        'note': event.note,
        'attendees': event.attendees,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return eventId;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'title': event.title,
        'date': event.date.toIso8601String(),
        'startTime': event.startTime,
        'endTime': event.endTime,
        'category': event.category,
        'note': event.note,
        'attendees': event.attendees,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  Stream<List<Event>> getEventsStream() {
    User? user = getCurrentUser();
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('events')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Event(
          id: data['id'],
          title: data['title'],
          date: DateTime.parse(data['date']),
          startTime: data['startTime'],
          endTime: data['endTime'],
          category: data['category'],
          note: data['note'] ?? '',
          attendees: List<String>.from(data['attendees'] ?? []),
        );
      }).toList();
    });
  }

  Future<List<Event>> getEvents() async {
    User? user = getCurrentUser();
    if (user == null) {
      return [];
    }

    QuerySnapshot snapshot = await _firestore
        .collection('events')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Event(
        id: data['id'],
        title: data['title'],
        date: DateTime.parse(data['date']),
        startTime: data['startTime'],
        endTime: data['endTime'],
        category: data['category'],
        note: data['note'] ?? '',
        attendees: List<String>.from(data['attendees'] ?? []),
      );
    }).toList();
  }

  // Reminder methods
  Future<String> createReminder(Reminder reminder) async {
    try {
      User? user = getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      String reminderId = _uuid.v4();
      await _firestore.collection('reminders').doc(reminderId).set({
        'id': reminderId,
        'title': reminder.title,
        'date': reminder.date.toIso8601String(),
        'timeRange': reminder.timeRange,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return reminderId;
    } catch (e) {
      print('Error creating reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }

  Stream<List<Reminder>> getRemindersStream() {
    User? user = getCurrentUser();
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('reminders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Reminder(
          id: data['id'],
          title: data['title'],
          date: DateTime.parse(data['date']),
          timeRange: data['timeRange'],
        );
      }).toList();
    });
  }
}
