import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/src/data/fallback_content.dart';
import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';

class CharacterRepository {
  final CollectionReference<Map<String, dynamic>> _charactersCollection =
      FirebaseFirestore.instance.collection('characters');

  Stream<List<HanziCharacter>> getCharactersForUnit(
    String unitId, {
    Unit? unit,
    String? sectionTitle,
    List<String> fallbackIds = const [],
  }) async* {
    try {
      final liveQuery = await _resolveLiveQuery(
        unitId: unitId,
        unit: unit,
        sectionTitle: sectionTitle,
      );

      if (liveQuery != null) {
        await for (final snapshot in liveQuery.snapshots()) {
          if (snapshot.docs.isNotEmpty) {
            final characters = snapshot.docs
                .map((doc) => HanziCharacter.fromFirestore(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                      fallbackUnitId: unitId,
                    ))
                .toList();
            yield _deduplicateCharacters(characters);
            continue;
          }

          final fallbackFromIds = await _loadFromFallbackIds(
            ids: fallbackIds,
            unitId: unitId,
          );
          if (fallbackFromIds.isNotEmpty) {
            yield fallbackFromIds;
            continue;
          }

          final bundled = FallbackContent.charactersForUnit(unitId);
          if (bundled.isNotEmpty) {
            debugPrint('Using bundled characters for unit $unitId.');
            yield bundled;
            continue;
          }

          yield const <HanziCharacter>[];
        }
        return;
      }

      final fallbackFromIds = await _loadFromFallbackIds(
        ids: fallbackIds,
        unitId: unitId,
      );
      if (fallbackFromIds.isNotEmpty) {
        yield fallbackFromIds;
        return;
      }

      final bundled = FallbackContent.charactersForUnit(unitId);
      if (bundled.isNotEmpty) {
        debugPrint('Using bundled characters for unit $unitId.');
        yield bundled;
        return;
      }

      debugPrint('No characters found for unit $unitId. Returning empty list.');
      yield const <HanziCharacter>[];
    } catch (error, stackTrace) {
      debugPrint('Failed to load characters for $unitId: $error\n$stackTrace');
      yield FallbackContent.charactersForUnit(unitId);
    }
  }

  Future<Query<Map<String, dynamic>>?> _resolveLiveQuery({
    required String unitId,
    Unit? unit,
    String? sectionTitle,
  }) async {
    final candidateValues = <String>{unitId};
    if (sectionTitle != null && sectionTitle.trim().isNotEmpty) {
      candidateValues.add(sectionTitle.trim());
    }
    if (unit != null) {
      candidateValues.addAll(unit.candidateCharacterKeys());
    }

    final sanitizedValues = candidateValues
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    const fieldVariants = <String>{
      'unitId',
      'unit',
      'Unit',
      'sectionId',
      'SectionID',
      'section',
      'Section',
      'sectionKey',
      'sectionRef',
      'sectionTitle',
      'SectionTitle',
      'section_name',
    };

    final attempted = <String>{};

    for (final field in fieldVariants) {
      for (final value in sanitizedValues) {
        final signature = '$field::$value';
        if (!attempted.add(signature)) {
          continue;
        }
        try {
          final query = _charactersCollection.where(field, isEqualTo: value);
          final snapshot = await query.limit(1).get();
          if (snapshot.docs.isNotEmpty) {
            debugPrint('CharacterRepository resolved $unitId via $field == $value');
            return query;
          }
        } on FirebaseException catch (error) {
          debugPrint('Query on $field == $value failed: $error');
        }
      }
    }

    return null;
  }

  Future<List<HanziCharacter>> _loadFromFallbackIds({
    required List<String> ids,
    required String unitId,
  }) async {
    if (ids.isEmpty) {
      return const [];
    }

    final trimmedIds = ids
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    if (trimmedIds.isEmpty) {
      return const [];
    }

    final characters = <HanziCharacter>[];
    final missing = <String>[];
    for (final id in trimmedIds) {
      try {
        final doc = await _charactersCollection.doc(id).get();
        if (doc.exists && doc.data() != null) {
          characters.add(HanziCharacter.fromFirestore(
            doc.id,
            doc.data()! as Map<String, dynamic>,
            fallbackUnitId: unitId,
          ));
        } else {
          missing.add(id);
        }
      } catch (error) {
        debugPrint('Direct lookup for character $id failed: $error');
        missing.add(id);
      }
    }

    if (missing.isNotEmpty) {
      for (final field in ['hanzi', 'character', 'word', 'Word']) {
        final queried = await _queryCharactersByField(field, missing, unitId);
        if (queried.isNotEmpty) {
          characters.addAll(queried);
        }
      }

      for (final id in missing) {
        final fallbackCharacter = FallbackContent.characterById(id);
        if (fallbackCharacter != null) {
          characters.add(HanziCharacter(
            id: fallbackCharacter.id,
            hanzi: fallbackCharacter.hanzi,
            pinyin: fallbackCharacter.pinyin,
            meaning: fallbackCharacter.meaning,
            unitId: unitId,
            ttsUrl: fallbackCharacter.ttsUrl,
            strokeData: fallbackCharacter.strokeData,
          ));
        }
      }
    }

    return _deduplicateCharacters(characters);
  }

  Future<List<HanziCharacter>> _queryCharactersByField(
    String field,
    List<String> values,
    String unitId,
  ) async {
    final results = <HanziCharacter>[];
    final uniqueValues = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    for (var index = 0; index < uniqueValues.length; index += 10) {
      final chunk = uniqueValues.sublist(index, min(index + 10, uniqueValues.length));
      try {
        final snapshot = await _charactersCollection.where(field, whereIn: chunk).get();
        results.addAll(snapshot.docs.map((doc) => HanziCharacter.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
              fallbackUnitId: unitId,
            )));
      } on FirebaseException catch (error) {
        debugPrint('whereIn query on $field failed: $error');
      } catch (error) {
        debugPrint('Unexpected error querying $field for $chunk: $error');
      }
    }

    return results;
  }

  List<HanziCharacter> _deduplicateCharacters(List<HanziCharacter> characters) {
    final seen = <String>{};
    final deduplicated = <HanziCharacter>[];

    for (final character in characters) {
      final key = character.id.isNotEmpty ? character.id : character.hanzi;
      if (seen.add(key)) {
        deduplicated.add(character);
      }
    }

    return deduplicated;
  }

  // Admin function to add a character
  Future<void> addCharacter(HanziCharacter character) {
    return _charactersCollection.doc(character.hanzi).set(character.toJson());
  }
}
