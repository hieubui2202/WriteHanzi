import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.uid,
    required super.email,
    required super.displayName,
    required super.avatarUrl,
    required super.xp,
    required super.streakDays,
    required super.lastActive,
    required super.progress,
    required super.guest,
  });

  factory UserProfileModel.fromJson(
    Map<String, dynamic>? json,
    String uid, {
    bool guest = false,
  }) {
    if (json == null) {
      return UserProfileModel(
        uid: uid,
        email: null,
        displayName: null,
        avatarUrl: null,
        xp: 0,
        streakDays: 0,
        lastActive: null,
        progress: {},
        guest: guest,
      );
    }

    final progress = <String, Map<String, dynamic>>{};
    final rawProgress = json['progress'];
    if (rawProgress is Map<String, dynamic>) {
      for (final entry in rawProgress.entries) {
        if (entry.value is Map<String, dynamic>) {
          progress[entry.key] = Map<String, dynamic>.from(entry.value as Map<String, dynamic>);
        }
      }
    }

    return UserProfileModel(
      uid: uid,
      email: json['email']?.toString(),
      displayName: json['displayName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      lastActive: json['lastActive'] != null
          ? DateTime.tryParse(json['lastActive'].toString())
          : null,
      progress: progress,
      guest: guest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'xp': xp,
      'streakDays': streakDays,
      'lastActive': lastActive?.toIso8601String(),
      'progress': progress,
    };
  }
}
