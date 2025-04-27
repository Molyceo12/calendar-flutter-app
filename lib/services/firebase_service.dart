import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar_app/models/event.dart';
import 'package:calendar_app/models/reminder.dart';
import 'package:calendar_app/firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  // Email/Password Authentication methods
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Create user profile in Firestore
        await _createUserProfile(user, name, email);
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

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if this is a new user
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create user profile for new users
          await _createUserProfile(
              user,
              user.displayName ?? googleUser.displayName ?? 'User',
              user.email ?? googleUser.email);
        }
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Apple Sign In
  Future<User?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available on this device
      final isAvailable = await SignInWithApple.isAvailable();

      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Request credential for the user
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuthCredential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase with the Apple credential
      UserCredential result = await _auth.signInWithCredential(oauthCredential);
      User? user = result.user;

      if (user != null) {
        // Get user's name from the Apple credential
        String? fullName;
        if (appleCredential.givenName != null &&
            appleCredential.familyName != null) {
          fullName =
              '${appleCredential.givenName} ${appleCredential.familyName}';
        }

        // Check if this is a new user
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create user profile for new users
          await _createUserProfile(
              user,
              fullName ?? user.displayName ?? 'Apple User',
              user.email ?? 'noemail@example.com');
        }
      }

      return user;
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Facebook Sign In
  Future<User?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        throw Exception('Facebook login failed: ${loginResult.message}');
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Sign in to Firebase with the Facebook credential
      UserCredential result =
          await _auth.signInWithCredential(facebookAuthCredential);
      User? user = result.user;

      if (user != null) {
        // Get additional user data from Facebook
        final userData = await FacebookAuth.instance.getUserData();

        // Check if this is a new user
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create user profile for new users
          await _createUserProfile(
              user,
              userData['name'] ?? user.displayName ?? 'Facebook User',
              userData['email'] ?? user.email ?? 'noemail@example.com');
        }
      }

      return user;
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // Helper method to create user profile
  Future<void> _createUserProfile(User user, String name, String email) async {
    // Update display name if not set
    if (user.displayName == null || user.displayName!.isEmpty) {
      await user.updateDisplayName(name);
    }

    // Create user document in Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'photoURL': user.photoURL,
    });
  }

  Future<void> signOut() async {
    // Sign out from Firebase
    await _auth.signOut();

    // Sign out from Google
    await _googleSignIn.signOut();

    // Sign out from Facebook
    await FacebookAuth.instance.logOut();
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
