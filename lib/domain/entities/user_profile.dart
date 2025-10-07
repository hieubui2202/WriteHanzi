import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.xp,
    required this.streakDays,
    required this.lastActive,
    required this.progress,
    required this.guest,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final int xp;
  final int streakDays;
  final DateTime? lastActive;
  final Map<String, Map<String, dynamic>> progress;
  final bool guest;

  UserProfile copyWith({
    int? xp,
    int? streakDays,
    DateTime? lastActive,
    Map<String, Map<String, dynamic>>? progress,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      lastActive: lastActive ?? this.lastActive,
      progress: progress ?? this.progress,
      guest: guest,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, avatarUrl, xp, streakDays, lastActive, progress, guest];
}
