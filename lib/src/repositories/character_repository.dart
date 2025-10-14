import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/src/data/fallback_content.dart';
import 'package:myapp/src/models/hanzi_character.dart';

class CharacterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _charactersCollection =
      FirebaseFirestore.instance.collection('characters');

  Stream<List<HanziCharacter>> getCharactersForUnit(
    String unitId, {
    String? sectionTitle,
    List<String> fallbackIds = const [],
  }) async* {
    final query = _charactersCollection.where('unitId', isEqualTo: unitId);

    try {
      await for (final snapshot in query.snapshots()) {
        if (snapshot.docs.isNotEmpty) {
          yield snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return HanziCharacter.fromFirestore(doc.id, data, fallbackUnitId: unitId);
          }).toList();
          continue;
        }

        final alternative = await _loadFromAlternateFields(unitId: unitId, sectionTitle: sectionTitle);
        if (alternative != null) {
          yield alternative;
          continue;
        }

        final fallbackCharacters = FallbackContent.charactersForUnit(unitId);
        if (fallbackCharacters.isNotEmpty) {
          debugPrint('Using bundled characters for unit $unitId.');
          yield fallbackCharacters;
          continue;
        }

        if (fallbackIds.isEmpty) {
          debugPrint('No characters found for unit $unitId and no fallback ids provided.');
          yield const <HanziCharacter>[];
          continue;
        }

        final futures = fallbackIds.map((id) => _charactersCollection.doc(id).get());
        final docs = await Future.wait(futures);

        final characters = docs
            .where((doc) => doc.exists && doc.data() != null)
            .map((doc) => HanziCharacter.fromFirestore(
                doc.id, doc.data()! as Map<String, dynamic>,
                fallbackUnitId: unitId))
            .toList();

        yield characters;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load characters for $unitId: $error\n$stackTrace');
      yield FallbackContent.charactersForUnit(unitId);
    }
  }

  Future<List<HanziCharacter>?> _loadFromAlternateFields({
    required String unitId,
    String? sectionTitle,
  }) async {
    final candidates = <String>{};
    if (unitId.isNotEmpty) {
      candidates.add(unitId);
    }
    if (sectionTitle != null && sectionTitle.trim().isNotEmpty) {
      candidates.add(sectionTitle.trim());
    }

    const fieldVariants = <String>[
      'SectionID',
      'sectionId',
      'section',
      'SectionTitle',
      'unit',
      'unitName',
    ];

    for (final value in candidates) {
      for (final field in fieldVariants) {
        try {
          final snapshot = await _charactersCollection.where(field, isEqualTo: value).get();
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs
                .map((doc) => HanziCharacter.fromFirestore(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                      fallbackUnitId: unitId,
                    ))
                .toList();
          }
        } on FirebaseException catch (error) {
          debugPrint('Query on $field == $value failed: $error');
        }
      }
    }

    return null;
  }

  // Admin function to add a character
  Future<void> addCharacter(HanziCharacter character) {
    return _charactersCollection.doc(character.hanzi).set(character.toJson());
  }
}
