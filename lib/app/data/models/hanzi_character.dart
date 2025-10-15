
import 'package:cloud_firestore/cloud_firestore.dart';

// Represents the data structure for a single Chinese character lesson,
// matching the structure in the Firestore 'characters' collection.
class HanziCharacter {
  final String id; // The document ID from Firestore (e.g., '七_七月')
  final String character; // The single Chinese character (e.g., '七')
  final String word; // The full word or phrase (e.g., '七月')
  final String pinyin; // The pinyin pronunciation (e.g., 'qīyuè')
  final String meaning; // The English meaning (e.g., 'July')
  final String section; // The section/unit identifier (e.g., 'Section 3, Unit 25')
  final int strokes; // The number of strokes in the character
  final List<String> svgList; // List of SVG paths for stroke animations
  final String ttsUrl; // URL for the Text-to-Speech audio

  /// Optional number of strokes that should be hidden in the
  /// "Finish the hanzi" step. Defaults to one when absent.
  final int missingCount;

  /// Layout hint for the build-the-hanzi drag & drop exercise.
  final String? layout;

  /// Optional list of pre-defined parts that compose the character.
  final List<CharacterPart> parts;

  HanziCharacter({
    required this.id,
    required this.character,
    required this.word,
    required this.pinyin,
    required this.meaning,
    required this.section,
    required this.strokes,
    required this.svgList,
    required this.ttsUrl,
    this.missingCount = 1,
    this.layout,
    this.parts = const [],
  });

  // Factory constructor to create a HanziCharacter from a Firestore document.
  factory HanziCharacter.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HanziCharacter(
      id: doc.id,
      character: data['character'] ?? '',
      word: data['word'] ?? '',
      pinyin: data['pinyin'] ?? '',
      meaning: data['meaning'] ?? '',
      section: data['section'] ?? '',
      strokes: data['strokes'] ?? 0,
      svgList: List<String>.from(data['svgList'] ?? []),
      ttsUrl: data['ttsUrl'] ?? '',
      missingCount: _readMissingCount(data['missingCount']),
      layout: (data['layout'] as String?)?.trim().isEmpty ?? true
          ? null
          : (data['layout'] as String).trim(),
      parts: _readParts(data['parts']),
    );
  }

  static int _readMissingCount(dynamic raw) {
    if (raw is int) {
      return raw.clamp(1, 3);
    }
    if (raw is num) {
      return raw.toInt().clamp(1, 3);
    }
    if (raw is String) {
      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return parsed.clamp(1, 3);
      }
    }
    return 1;
  }

  static List<CharacterPart> _readParts(dynamic raw) {
    if (raw is Iterable) {
      return raw
          .map((item) => CharacterPart.fromMap(item))
          .where((part) => part.id.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

class CharacterPart {
  const CharacterPart({
    required this.id,
    required this.label,
    this.svgList,
    this.imgUrl,
  });

  final String id;
  final String label;
  final List<String>? svgList;
  final String? imgUrl;

  factory CharacterPart.fromMap(dynamic raw) {
    if (raw is CharacterPart) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      final id = (raw['id'] ?? '').toString().trim();
      final label = (raw['label'] ?? '').toString().trim();
      if (id.isEmpty || label.isEmpty) {
        return const CharacterPart(id: '', label: '');
      }
      final svgListRaw = raw['svgList'];
      List<String>? svgList;
      if (svgListRaw is Iterable) {
        svgList =
            svgListRaw.map((item) => item?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      final imgUrl = (raw['imgUrl'] ?? '').toString().trim();
      return CharacterPart(
        id: id,
        label: label,
        svgList: svgList?.isEmpty ?? true ? null : svgList,
        imgUrl: imgUrl.isEmpty ? null : imgUrl,
      );
    }
    return const CharacterPart(id: '', label: '');
  }
}
