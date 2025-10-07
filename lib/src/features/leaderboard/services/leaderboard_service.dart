
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/models/user_profile.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserProfile>> getLeaderboard() {
    return _firestore
        .collection('users')
        .orderBy('xp', descending: true)
        .limit(50) // Giới hạn top 50 người dùng
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
            .toList());
  }
}
