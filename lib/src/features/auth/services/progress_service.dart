
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/src/models/user_profile.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserProfile.fromFirestore(snapshot.data()!);
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

      final userProfile = UserProfile.fromFirestore(snapshot.data()!);

      // 1. Update Progress
      final newProgress = Map<String, String>.from(userProfile.progress);
      newProgress[characterId] = 'completed';

      // 2. Update XP
      final newXp = userProfile.xp + xpValue;

      // 3. Update Streak
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int newStreak = userProfile.streak;
      
      if(userProfile.lastCompleted != null){
        final lastCompletedDateTime = userProfile.lastCompleted!.toDate();
        final lastCompletedDate = DateTime(lastCompletedDateTime.year, lastCompletedDateTime.month, lastCompletedDateTime.day);
        final difference = today.difference(lastCompletedDate).inDays;

        if (difference == 1) {
        newStreak++;
        } else if (difference > 1) {
        newStreak = 1; // Reset streak
        }
         // if difference is 0, do nothing
      }else{
         newStreak = 1;
      }

      transaction.update(userRef, {
        'progress': newProgress,
        'xp': newXp,
        'streak': newStreak,
        'lastCompleted': Timestamp.now(),
      });
    });
  }
}
