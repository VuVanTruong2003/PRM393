import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_profile.dart';

/// Đọc/ghi 1 document profile cho mỗi user: users/{userId}/profile/me
class ProfileFirestoreService {
  ProfileFirestoreService() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _profileDoc(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc(UserProfile.docId);
  }

  Stream<UserProfile> watchProfile(String userId) {
    return _profileDoc(userId).snapshots().map((snap) {
      return UserProfile.fromMap(snap.data());
    });
  }

  Future<void> setProfile(String userId, UserProfile profile) async {
    await _profileDoc(userId).set(profile.toMap());
  }
}
