import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calendar_app/services/firebase_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

enum SocialAuthProvider {
  google,
  apple,
  facebook,
}

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
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
      _setLoading(true);
      _error = null;
      await _firebaseService.signUp(email, password, name);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      await _firebaseService.signIn(email, password);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithSocial(SocialAuthProvider provider) async {
    try {
      _setLoading(true);
      _error = null;

      User? user;

      switch (provider) {
        case SocialAuthProvider.google:
          user = await _firebaseService.signInWithGoogle();
          break;
        case SocialAuthProvider.apple:
          user = await _firebaseService.signInWithApple();
          break;
        case SocialAuthProvider.facebook:
          user = await _firebaseService.signInWithFacebook();
          break;
      }

      return user != null;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _firebaseService.signOut();
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _error = _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _error = null;
      await _firebaseService.resetPassword(email);
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
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
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'invalid-credential':
          return 'The credential is invalid or has expired.';
        case 'operation-not-allowed':
          return 'This operation is not allowed. Contact support.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'popup-closed-by-user':
          return 'The sign-in popup was closed before completing the sign in.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An error occurred. Please try again.';
  }
}