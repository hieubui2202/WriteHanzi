import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:myapp/app/data/models/chapter_model.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/data/models/lesson_model.dart';

class HomeRepository {
  HomeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _unitsCollection =>
      _firestore.collection('units');
  CollectionReference<Map<String, dynamic>> get _charactersCollection =>
      _firestore.collection('characters');

  // Fetch all chapters from Firestore
  Future<List<Chapter>> getChapters() async {
    try {
      final snapshot = await _unitsCollection.get();
      final sections = <int, String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final sectionNumber = _readSection(data, doc.id);
        if (sectionNumber == null) {
          continue;
        }

        sections.putIfAbsent(sectionNumber, () => 'Section $sectionNumber');
      }

      final sortedSections = sections.keys.toList()..sort();
      return sortedSections
          .map((section) => Chapter(
                id: _chapterId(section),
                title: sections[section]!,
              ))
          .toList();
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
      return [];
    }
  }

  // Fetch lessons for a specific chapter from Firestore
  Future<List<Lesson>> getLessonsForChapter(String chapterId) async {
    try {
      final targetSection = _sectionFromChapterId(chapterId);
      final snapshot = await _unitsCollection.get();

      final unitDocs = snapshot.docs.where((doc) {
        if (targetSection == null) {
          return doc.id == chapterId;
        }
        final docSection = _readSection(doc.data(), doc.id);
        return docSection == targetSection;
      }).toList();

      unitDocs.sort((a, b) {
        final aUnit = _readUnit(a.data(), a.id) ?? 0;
        final bUnit = _readUnit(b.data(), b.id) ?? 0;
        return aUnit.compareTo(bUnit);
      });

      final lessons = <Lesson>[];
      for (final doc in unitDocs) {
        final data = doc.data();
        final unitNumber = _readUnit(data, doc.id);
        final lessonTitle = _readTitle(data, unitNumber);
        final characterIds = _extractCharacterIds(data);
        final characters = await _fetchCharacters(characterIds);

        lessons.add(Lesson(
          id: doc.id,
          title: lessonTitle,
          characters: characters,
        ));
      }

      return lessons;
    } catch (e) {
      debugPrint('Error fetching lessons: $e');
      return [];
    }
  }

  Future<List<HanziCharacter>> _fetchCharacters(List<String> ids) async {
    if (ids.isEmpty) {
      return const [];
    }

    final futures = ids.map(_loadCharacter).toList(growable: false);
    final results = await Future.wait(futures);

    final characters = <HanziCharacter>[];
    for (var index = 0; index < ids.length; index++) {
      final character = results[index];
      if (character != null) {
        characters.add(character);
      }
    }

    return characters;
  }

  Future<HanziCharacter?> _loadCharacter(String rawId) async {
    final id = rawId.trim();
    if (id.isEmpty) {
      return null;
    }

    try {
      final directDoc = await _charactersCollection.doc(id).get();
      if (directDoc.exists) {
        return HanziCharacter.fromFirestore(directDoc);
      }

      final query = await _charactersCollection
          .where('character', isEqualTo: id)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return HanziCharacter.fromFirestore(query.docs.first);
      }
    } catch (e) {
      debugPrint('Error loading character "$id": $e');
    }

    return null;
  }

  List<String> _extractCharacterIds(Map<String, dynamic> data) {
    final characters = _stringList(data['characters']);
    if (characters.isNotEmpty) {
      return characters;
    }
    final words = _stringList(data['words']);
    if (words.isNotEmpty) {
      return words;
    }
    return const [];
  }

  List<String> _stringList(dynamic value) {
    if (value is Iterable) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((segment) => segment.trim())
          .where((segment) => segment.isNotEmpty)
          .toList();
    }
    return const [];
  }

  int? _readSection(Map<String, dynamic> data, String docId) {
    final value = data['section'];
    final parsed = _parseInt(value);
    if (parsed != null) {
      return parsed;
    }
    final lowerId = docId.toLowerCase();
    final match = RegExp(r'section[_\-]?(\d+)').firstMatch(lowerId);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  int? _readUnit(Map<String, dynamic> data, String docId) {
    final value = data['unit'];
    final parsed = _parseInt(value);
    if (parsed != null) {
      return parsed;
    }
    final lowerId = docId.toLowerCase();
    final match = RegExp(r'unit[_\-]?(\d+)').firstMatch(lowerId);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String _readTitle(Map<String, dynamic> data, int? unitNumber) {
    final raw = data['title'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw;
    }
    if (unitNumber != null && unitNumber > 0) {
      return 'Unit $unitNumber';
    }
    return 'Unit';
  }

  int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  int? _sectionFromChapterId(String chapterId) {
    final match = RegExp(r'(\d+)').firstMatch(chapterId);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  String _chapterId(int section) => 'section_$section';
}
