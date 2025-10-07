import '../entities/user_profile.dart';

abstract class ProgressRepository {
  Future<UserProfile> loadProfile(String uid, {bool guest = false});
  Future<void> updateProgress({
    required String uid,
    required String unitId,
    required String hanzi,
    required Map<String, dynamic> payload,
  });
  Future<void> updateMeta({
    required String uid,
    required int xp,
    required int streakDays,
    required DateTime lastActive,
  });
}
