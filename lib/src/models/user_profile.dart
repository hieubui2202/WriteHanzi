class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final int xp;
  final int streak;
  final Map<String, dynamic> progress;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.xp,
    required this.streak,
    required this.progress,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String id) {
    return UserProfile(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      xp: data['xp'] ?? 0,
      streak: data['streak'] ?? 0,
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'xp': xp,
      'streak': streak,
      'progress': progress,
    };
  }
}
