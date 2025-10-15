import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';

class PracticeProgressService {
  PracticeProgressService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> submitProgress({
    required HanziCharacter character,
    required int xp,
    required int score,
    required int mistakes,
    required Map<String, bool> completedSteps,
    required Duration duration,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final payload = {
      'xp': FieldValue.increment(xp),
      'progress': {
        character.id: {
          'completed': completedSteps.values.every((value) => value),
          'score': score,
          'mistakes': mistakes,
          'lastReview': FieldValue.serverTimestamp(),
          'completedSteps': completedSteps,
          'durationSeconds': duration.inSeconds,
        },
      },
    };

    await _firestore.runTransaction((transaction) async {
      transaction.set(userRef, payload, SetOptions(merge: true));
    });
  }
}
