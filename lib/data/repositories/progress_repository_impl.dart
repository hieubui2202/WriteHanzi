import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/progress_repository.dart';
import '../cache/progress_cache.dart';
import '../datasources/firestore_progress_data_source.dart';
import '../models/user_profile_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    required FirebaseFirestore firestore,
    required ProgressCache cache,
  })  : _remote = FirestoreProgressDataSource(firestore),
        _cache = cache;

  final FirestoreProgressDataSource _remote;
  final ProgressCache _cache;

  @override
  Future<UserProfile> loadProfile(String uid, {bool guest = false}) async {
    try {
      final profile = await _remote.loadProfile(uid, guest: guest);
      await _cache.cacheProfile(profile.toJson());
      return profile;
    } catch (_) {
      final cached = _cache.readProfile();
      if (cached != null) {
        return UserProfileModel.fromJson(cached, uid, guest: guest);
      }
      return UserProfileModel.fromJson(null, uid, guest: guest);
    }
  }

  @override
  Future<void> updateMeta({
    required String uid,
    required int xp,
    required int streakDays,
    required DateTime lastActive,
  }) {
    return _remote.updateMeta(
      uid: uid,
      xp: xp,
      streakDays: streakDays,
      lastActive: lastActive,
    );
  }

  @override
  Future<void> updateProgress({
    required String uid,
    required String unitId,
    required String hanzi,
    required Map<String, dynamic> payload,
  }) {
    return _remote.updateProgress(
      uid: uid,
      unitId: unitId,
      hanzi: hanzi,
      payload: payload,
    );
  }
}
