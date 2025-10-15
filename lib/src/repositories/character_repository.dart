import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hanzi_character.dart';
import '../models/unit.dart';

class CharacterRepository {
  CharacterRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('characters');

  /// Loads the characters that belong to [unit]. The Firestore data model in
  /// production stores the character IDs inside the unit document, so this
  /// method fetches the referenced documents in batches of ten (the maximum
  /// size supported by Firestore's `whereIn`).
  Stream<List<HanziCharacter>> getCharactersForUnit(Unit unit) {
    final ids = unit.characters.where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) {
      return Stream<List<HanziCharacter>>.value(const []);
    }

    return Stream.fromFuture(_fetchCharactersByIds(ids)).map((characters) {
      final order = <String, int>{
        for (var index = 0; index < ids.length; index++) ids[index]: index,
      };

      characters.sort((a, b) {
        final aIndex = order[a.id] ?? order[a.hanzi] ?? ids.length;
        final bIndex = order[b.id] ?? order[b.hanzi] ?? ids.length;
        return aIndex.compareTo(bIndex);
      });

      return characters;
    });
  }

  Future<List<HanziCharacter>> _fetchCharactersByIds(List<String> ids) async {
    final results = <HanziCharacter>[];
    const batchSize = 10;
    for (var start = 0; start < ids.length; start += batchSize) {
      final end = math.min(start + batchSize, ids.length);
      final chunk = ids.sublist(start, end);
      final snapshot = await _collection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(
        snapshot.docs.map(HanziCharacter.fromFirestore),
      );
    }

    if (results.length < ids.length) {
      for (final id in ids) {
        final alreadyFetched =
            results.any((character) => character.id == id || character.hanzi == id);
        if (alreadyFetched) {
          continue;
        }
        final doc = await _collection.doc(id).get();
        if (doc.exists) {
          results.add(HanziCharacter.fromFirestore(doc));
        }
      }
    }

    return results;
  }

  Future<void> addCharacter(HanziCharacter character) async {
    final documentId = character.id.isNotEmpty ? character.id : character.hanzi;
    await _collection.doc(documentId).set(character.toJson());
  }
}
