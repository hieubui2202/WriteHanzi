import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile_model.dart';

class FirestoreProgressDataSource {
  FirestoreProgressDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  Future<UserProfileModel> loadProfile(String uid, {bool guest = false}) async {
    final snapshot = await _collection.doc(uid).get();
    return UserProfileModel.fromJson(snapshot.data(), uid, guest: guest);
  }

  Future<void> updateProgress({
    required String uid,
    required String unitId,
    required String hanzi,
    required Map<String, dynamic> payload,
  }) async {
    await _collection.doc(uid).set({
      'progress': {
        unitId: {
          hanzi: payload,
        },
      },
    }, SetOptions(merge: true));
  }

  Future<void> updateMeta({
    required String uid,
    required int xp,
    required int streakDays,
    required DateTime lastActive,
  }) async {
    await _collection.doc(uid).set({
      'xp': xp,
      'streakDays': streakDays,
      'lastActive': lastActive.toIso8601String(),
    }, SetOptions(merge: true));
  }
}
