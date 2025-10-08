import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/src/models/hanzi_character.dart';

class CharacterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _charactersCollection =
      FirebaseFirestore.instance.collection('characters');

  Stream<List<HanziCharacter>> getCharactersForUnit(String unitId, {List<String> fallbackIds = const []}) {
    final query = _charactersCollection.where('unitId', isEqualTo: unitId);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          debugPrint('Loaded character ${doc.id} for unit $unitId via unitId filter');
          return HanziCharacter.fromFirestore(doc.id, data, fallbackUnitId: unitId);
        }).toList();
      }

      final altSnapshot = await _charactersCollection.where('SectionID', isEqualTo: unitId).get();
      if (altSnapshot.docs.isNotEmpty) {
        return altSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          debugPrint('Loaded character ${doc.id} for unit $unitId via SectionID fallback');
          return HanziCharacter.fromFirestore(doc.id, data, fallbackUnitId: unitId);
        }).toList();
      }

      if (fallbackIds.isEmpty) {
        debugPrint('No characters found for unit $unitId and no fallback ids provided.');
        return <HanziCharacter>[];
      }

      final futures = fallbackIds.map((id) => _charactersCollection.doc(id).get());
      final docs = await Future.wait(futures);

      final characters = docs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) =>
              HanziCharacter.fromFirestore(doc.id, doc.data()! as Map<String, dynamic>, fallbackUnitId: unitId))
          .toList();

      debugPrint('Loaded ${characters.length} characters for unit $unitId via explicit doc ids.');
      return characters;
    });
  }

  // Admin function to add a character
  Future<void> addCharacter(HanziCharacter character) {
    return _charactersCollection.doc(character.hanzi).set(character.toJson());
  }
}
