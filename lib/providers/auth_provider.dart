import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calendar_app/services/firebase_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    // Listen for auth state changes
    _firebaseService.authStateChanges.listen((User? user) {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
      } else {
        _user = user;
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _error = null;
      await _firebaseService.signUp(email, password, name);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _error = null;
      await _firebaseService.signIn(email, password);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _error = null;
      await _firebaseService.resetPassword(email);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred. Please try again.';
  }
}
