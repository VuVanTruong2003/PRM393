import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import 'auth_controller.dart';
import '../services/remote/profile_firestore_service.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    required AuthController authController,
    ProfileFirestoreService? profileService,
  })  : _auth = authController,
        _profileService = profileService ?? ProfileFirestoreService() {
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  final AuthController _auth;
  final ProfileFirestoreService _profileService;

  StreamSubscription<UserProfile>? _profileSub;
  UserProfile _profile = const UserProfile();
  bool _loading = true;
  Object? _error;
  bool _saving = false;

  UserProfile get profile => _profile;
  bool get loading => _loading;
  Object? get error => _error;
  bool get saving => _saving;

  void _onAuthChanged() {
    final uid = _auth.user?.uid;
    _profileSub?.cancel();
    _profileSub = null;
    if (uid == null) {
      _profile = const UserProfile();
      _loading = false;
      _error = null;
      notifyListeners();
      return;
    }
    _loading = true;
    _error = null;
    notifyListeners();
    _profileSub = _profileService.watchProfile(uid).listen(
      (p) {
        _profile = p;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Tên hiển thị: ưu tiên profile (Firestore) rồi Auth displayName rồi email.
  String displayNameOrFallback() {
    final name = _profile.displayName.trim();
    if (name.isNotEmpty) return name;
    final authName = _auth.user?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) return authName;
    return _auth.user?.email ?? 'Người dùng';
  }

  Future<void> saveProfile(UserProfile next) async {
    final uid = _auth.user?.uid;
    if (uid == null) return;
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _profileService.setProfile(uid, next);
      _profile = next;
      if (next.displayName.trim().isNotEmpty) {
        await _auth.user?.updateDisplayName(next.displayName.trim());
      }
    } catch (e) {
      _error = e;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _profileSub?.cancel();
    super.dispose();
  }
}
