import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user ID
  String? get userId => _auth.currentUser?.uid;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? fcmToken = await FirebaseMessaging.instance.getToken();
      final String uid = credential.user!.uid;

      // Store uid in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', uid);

      // Get device ID
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId;

        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;

      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('devices')
            .doc(deviceId)
            .set({
          'fcmToken': fcmToken,
          'lastActive': FieldValue.serverTimestamp(),
          'platform': Platform.operatingSystem,
        }, SetOptions(merge: true));
      }

      // Call Cloud Function to send login notification
      try {
        final HttpsCallable callable = _functions.httpsCallable('sendLoginNotification');
        await callable.call(<String, dynamic>{
          'userId': uid,
        });
      } catch (e) {
        debugPrint('Error calling sendLoginNotification function: $e');
      }

      return credential;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // Create user document with empty subcollections devices and events
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
      await userDocRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await userDocRef.collection('devices').doc('init').set({'init': true});
      await userDocRef.collection('events').doc('init').set({'init': true});

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
