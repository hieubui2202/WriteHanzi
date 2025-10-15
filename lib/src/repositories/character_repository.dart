import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hanzi_character.dart';

class CharacterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _charactersCollection =
      FirebaseFirestore.instance.collection('characters');

  Stream<List<HanziCharacter>> getCharactersByIds(List<String> characterIds) {
    if (characterIds.isEmpty) {
      return Stream.value(const []);
    }

    // Firestore limits whereIn to 10 entries. Chunk if needed.
    final chunks = <List<String>>[];
    for (var i = 0; i < characterIds.length; i += 10) {
      chunks.add(characterIds.sublist(i, i + 10 > characterIds.length ? characterIds.length : i + 10));
    }

    final streams = chunks.map((chunk) {
      return _charactersCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => HanziCharacter.fromMap(doc.data(), id: doc.id))
              .toList());
    }).toList();

    if (streams.length == 1) {
      return streams.first.map((characters) => _sortByIdList(characters, characterIds));
    }

    return StreamZip<List<HanziCharacter>>(streams).map((lists) {
      final combined = lists.expand((list) => list).toList();
      return _sortByIdList(combined, characterIds);
    });
  }

  Future<HanziCharacter?> getCharacter(String characterId) async {
    final snapshot = await _charactersCollection.doc(characterId).get();
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return HanziCharacter.fromMap(snapshot.data()!, id: snapshot.id);
  }

  // Admin function to add a character
  Future<void> addCharacter(HanziCharacter character) {
    return _charactersCollection.doc(character.id.isNotEmpty ? character.id : character.hanzi).set(character.toMap());
  }

  List<HanziCharacter> _sortByIdList(List<HanziCharacter> characters, List<String> order) {
    final orderMap = {for (var i = 0; i < order.length; i++) order[i]: i};
    final uniqueById = <String, HanziCharacter>{};
    for (final character in characters) {
      final key = character.id.isNotEmpty ? character.id : character.hanzi;
      uniqueById[key] = character;
    }

    final sorted = uniqueById.entries.toList()
      ..sort((a, b) {
        final indexA = orderMap[a.key] ?? order.length;
        final indexB = orderMap[b.key] ?? order.length;
        return indexA.compareTo(indexB);
      });

    return sorted.map((entry) => entry.value).toList();
  }
}
