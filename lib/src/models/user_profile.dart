import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

Timestamp? _timestampFromJson(Object? value) {
  if (value is Timestamp) {
    return value;
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

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

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
