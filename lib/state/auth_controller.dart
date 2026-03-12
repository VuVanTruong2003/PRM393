import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../firebase_bootstrap.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    _ensureFirebaseListening();
  }

  StreamSubscription<User?>? _authSub;

  User? _user;
  bool _initializingFirebase = false;
  Object? _lastError;

  bool get isSignedIn => _user != null;
  User? get user => _user;
  bool get isFirebaseInitializing => _initializingFirebase;
  Object? get lastError => _lastError;

  Future<void> _ensureFirebaseListening() async {
    if (_authSub != null || _initializingFirebase) return;
    _initializingFirebase = true;
    notifyListeners();

    try {
      final ok = await FirebaseBootstrap.ensureInitialized();
      if (!ok) {
        _lastError =
            'Firebase chưa được cấu hình. Mở lib/firebase_options.dart và thay REPLACE_ME.';
        _initializingFirebase = false;
        notifyListeners();
        return;
      }

      _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
        _user = u;
        notifyListeners();
      });
    } catch (e) {
      _lastError = e;
    } finally {
      _initializingFirebase = false;
      notifyListeners();
    }
  }

  void _stopFirebaseListening() {
    _authSub?.cancel();
    _authSub = null;
  }

  Future<void> signOut() async {
    _lastError = null;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      _lastError = e;
    }

    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      final ok = await FirebaseBootstrap.ensureInitialized();
      if (!ok) {
        _lastError =
            'Firebase chưa được cấu hình. Mở lib/firebase_options.dart và thay REPLACE_ME.';
        notifyListeners();
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      _lastError = e;
      notifyListeners();
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      final ok = await FirebaseBootstrap.ensureInitialized();
      if (!ok) {
        _lastError =
            'Firebase chưa được cấu hình. Mở lib/firebase_options.dart và thay REPLACE_ME.';
        notifyListeners();
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      _lastError = e;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    _lastError = null;
    notifyListeners();

    try {
      final ok = await FirebaseBootstrap.ensureInitialized();
      if (!ok) {
        _lastError =
            'Firebase chưa được cấu hình. Mở lib/firebase_options.dart và thay REPLACE_ME.';
        notifyListeners();
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      _lastError = e;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopFirebaseListening();
    super.dispose();
  }
}

