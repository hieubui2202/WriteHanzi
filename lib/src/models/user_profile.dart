import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

Timestamp? _timestampFromJson(Object? value) {
  if (value is Timestamp) {
    return value;
  }
  if (value is int) {
    return Timestamp.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return Timestamp.fromDate(parsed);
    }
  }
  return null;
}

Object? _timestampToJson(Timestamp? timestamp) => timestamp;

@JsonSerializable()
class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final int xp;
  final int streak;
  final Timestamp? lastCompleted;
  final Map<String, String> progress;

  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.xp = 0,
    this.streak = 0,
    this.lastCompleted,
    this.progress = const {},
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    final rawProgress = map['progress'];
    final progress = <String, String>{};
    if (rawProgress is Map) {
      rawProgress.forEach((key, value) {
        if (key is String) {
          progress[key] = value?.toString() ?? '';
        }
      });
    }

    return UserProfile(
      uid: uid,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      lastCompleted: _timestampFromJson(map['lastCompleted']),
      progress: progress,
    );
  }

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'xp': xp,
        'streak': streak,
        'lastCompleted': _timestampToJson(lastCompleted),
        'progress': progress,
      };

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    int? xp,
    int? streak,
    Timestamp? lastCompleted,
    Map<String, String>? progress,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      progress: progress ?? this.progress,
    );
  }
}
