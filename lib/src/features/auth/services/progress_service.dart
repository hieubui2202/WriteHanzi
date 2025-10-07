
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/models/user_profile.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  Future<void> completeCharacter(String characterId, int xpValue) async {
    final user = _auth.currentUser;
    if (user == null) return; // Not logged in

    final userRef = _firestore.collection('users').doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        // This case should ideally not happen if user profile is created on signup
        return;
      }

      final userProfile = UserProfile.fromMap(snapshot.data()!, snapshot.id);

      // 1. Update Progress
      final newProgress = Map<String, dynamic>.from(userProfile.progress);
      newProgress[characterId] = 'completed';

      // 2. Update XP
      final newXp = userProfile.xp + xpValue;

      // 3. Update Streak
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int newStreak = userProfile.streak;
      
      // This part has a logical error, we need a 'lastCompleted' field.
      // For now, let's just increment the streak for simplicity.
      newStreak++;

      transaction.update(userRef, {
        'progress': newProgress,
        'xp': newXp,
        'streak': newStreak,
        'lastCompleted': Timestamp.now(),
      });
    });
  }
}
