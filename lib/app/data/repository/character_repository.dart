
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/domain/repository/i_character_repository.dart';

// This is the concrete implementation of the ICharacterRepository.
// It uses Firestore as the data source.
class CharacterRepository implements ICharacterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<HanziCharacter>> getCharacters({int limit = 20}) async {
    try {
      final querySnapshot = await _firestore.collection('characters').limit(limit).get();
      return querySnapshot.docs
          .map((doc) => HanziCharacter.fromFirestore(doc))
          .toList();
    } catch (e) {
      // In a production app, use a dedicated logging service (e.g., Crashlytics).
      print('Error fetching characters: $e');
      // Re-throwing the exception allows the UI layer (or a use case) to handle it.
      rethrow;
    }
  }
}
