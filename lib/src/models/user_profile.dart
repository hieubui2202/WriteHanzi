
import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_profile.g.dart';

// Helper to handle Firestore Timestamps
Timestamp? _timestampFromJson(dynamic value) => value as Timestamp?;

dynamic _timestampToJson(Timestamp? timestamp) => timestamp;

@JsonSerializable()
class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL; // Using the name from Firebase Auth

  final int xp; // Experience Points
  final int streak; // Consecutive days of practice

  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final Timestamp? lastCompleted;

  // Map of <characterId, status>
  // Status can be 'completed', 'learning', etc.
  final Map<String, String> progress;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.xp = 0,
    this.streak = 0,
    this.lastCompleted,
    this.progress = const {},
  });

 factory UserProfile.fromFirestore(Map<String, dynamic> firestoreData) {
    return UserProfile(
      uid: firestoreData['uid'],
      email: firestoreData['email'],
      displayName: firestoreData['displayName'],
      photoURL: firestoreData['photoURL'],
      xp: firestoreData['xp'] ?? 0,
      streak: firestoreData['streak'] ?? 0,
      lastCompleted: firestoreData['lastCompleted'] as Timestamp?,
      progress: Map<String, String>.from(firestoreData['progress'] ?? {}),
    );
  }

  // A copyWith method to easily update the object
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    int? xp,
    int? streak,
    Timestamp? lastCompleted,
    Map<String, String>? progress,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      progress: progress ?? this.progress,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
