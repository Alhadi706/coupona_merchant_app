import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// A change notifier that listens to Firebase auth state changes.
///
/// This notifier can be used with GoRouter's refreshListenable to react to
/// login/logout events and automatically redirect the user.
class AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _authStateSubscription;
  User? _user;

  AuthNotifier() {
    // Listen to auth state changes and notify listeners.
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
