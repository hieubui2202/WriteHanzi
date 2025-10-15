import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/hanzi_character.dart';
import '../models/unit.dart';

class CharacterRepository {
  CharacterRepository()
      : _charactersCollection =
            FirebaseFirestore.instance.collection('characters');

  final CollectionReference<Map<String, dynamic>> _charactersCollection;

  Stream<List<HanziCharacter>> getCharactersForUnit(Unit unit) {
    return Stream.fromFuture(_loadCharactersForUnit(unit));
  }

  Future<List<HanziCharacter>> _loadCharactersForUnit(Unit unit) async {
    final results = <HanziCharacter>[];
    final seen = <String>{};

    await _fetchByDocumentIds(unit.characters, results, seen);

    if (results.isEmpty) {
      final lookupValues = <String>{};
      void addLookup(String? value) {
        if (value == null) return;
        final trimmed = value.trim();
        if (trimmed.isEmpty) return;
        lookupValues.add(trimmed);
      }

      addLookup(unit.id);
      addLookup(unit.title);
      addLookup(unit.description);
      addLookup(unit.id.replaceAll('_', ' ').replaceAll('-', ' '));
      addLookup(_sectionLabelFromUnit(unit));

      final fieldCandidates = <String>{
        'unitId',
        'unit',
        'sectionId',
        'section',
        'sectionTitle',
      };

      for (final field in fieldCandidates) {
        for (final value in lookupValues) {
          try {
            final snapshot = await _charactersCollection
                .where(field, isEqualTo: value)
                .get();
            if (snapshot.docs.isEmpty) {
              continue;
            }
            for (final doc in snapshot.docs) {
              final data = doc.data();
              final character = HanziCharacter.fromFirestore(data, doc.id);
              if (seen.add(character.id)) {
                results.add(character);
              }
            }
            if (results.isNotEmpty) {
              break;
            }
          } catch (error, stackTrace) {
            if (kDebugMode) {
              debugPrint('Character query failed for $field=$value: $error');
              debugPrintStack(stackTrace: stackTrace);
            }
          }
        }
        if (results.isNotEmpty) {
          break;
        }
      }
    }

    if (results.isEmpty) {
      return results;
    }

    if (unit.characters.isNotEmpty) {
      final orderMap = <String, int>{};
      for (var i = 0; i < unit.characters.length; i++) {
        final key = unit.characters[i];
        orderMap[key] = i;
      }
      for (final entry in List<MapEntry<String, int>>.from(orderMap.entries)) {
        orderMap.putIfAbsent(entry.key.trim(), () => entry.value);
      }

      results.sort((a, b) {
        final aIndex = orderMap[a.id] ?? orderMap[a.hanzi] ?? 9999;
        final bIndex = orderMap[b.id] ?? orderMap[b.hanzi] ?? 9999;
        return aIndex.compareTo(bIndex);
      });
    }

    return results;
  }

  Future<void> _fetchByDocumentIds(
    List<String> ids,
    List<HanziCharacter> results,
    Set<String> seen,
  ) async {
    final filtered = ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toList();
    if (filtered.isEmpty) {
      return;
    }

    for (var i = 0; i < filtered.length; i += 10) {
      final chunk = filtered.sublist(i, math.min(i + 10, filtered.length));
      try {
        final snapshot = await _charactersCollection
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final character = HanziCharacter.fromFirestore(data, doc.id);
          if (seen.add(character.id)) {
            results.add(character);
          }
        }
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('Character lookup failed for ids $chunk: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }
    }
  }

  Future<void> addCharacter(HanziCharacter character) {
    final documentId = character.id.isNotEmpty ? character.id : character.hanzi;
    return _charactersCollection.doc(documentId).set(character.toJson());
  }
}

String? _sectionLabelFromUnit(Unit unit) {
  final matches = RegExp(r'\d+').allMatches(unit.id);
  final numbers = matches
      .map((match) => int.tryParse(match.group(0) ?? ''))
      .whereType<int>()
      .toList();
  if (numbers.length < 2) {
    return null;
  }
  return 'Section ${numbers[0]}, Unit ${numbers[1]}';
}
