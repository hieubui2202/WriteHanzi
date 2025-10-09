import 'package:json_annotation/json_annotation.dart';

part 'hanzi_character.g.dart';

@JsonSerializable(explicitToJson: true)
class HanziCharacter {
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String id;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String unitId;
  final String? ttsUrl;
  final StrokeData strokeData;

  HanziCharacter({
    this.id = '',
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.unitId,
    this.ttsUrl,
    required this.strokeData,
  });

  factory HanziCharacter.fromJson(Map<String, dynamic> json) => _$HanziCharacterFromJson(json);
  Map<String, dynamic> toJson() => _$HanziCharacterToJson(this);

  /// Creates a [HanziCharacter] from Firestore documents that may use
  /// different field names (legacy imports, admin tools, etc.).
  factory HanziCharacter.fromFirestore(String id, Map<String, dynamic> data, {String? fallbackUnitId}) {
    final hanzi = _readString(data, ['hanzi', 'character', 'word', 'Word']) ?? id;
    final pinyin = _readString(data, ['pinyin', 'transliteration', 'pinyinText', 'Transliteration']) ?? '';
    final meaning = _readString(data, ['meaning', 'translation', 'meaningEn', 'Translation']) ?? '';
    final unitId =
        _readString(data, ['unitId', 'sectionId', 'SectionID']) ?? fallbackUnitId ?? '';
    final ttsUrl = _readString(data, ['ttsUrl', 'ttsURL', 'audioUrl', 'audio', 'TTS URL']);

    final strokeData = StrokeData.fromFirestore(data);

    return HanziCharacter(
      id: id,
      hanzi: hanzi,
      pinyin: pinyin,
      meaning: meaning,
      unitId: unitId,
      ttsUrl: ttsUrl,
      strokeData: strokeData,
    );
  }

  HanziCharacter copyWithId(String id) {
    return HanziCharacter(
      id: id,
      hanzi: hanzi,
      pinyin: pinyin,
      meaning: meaning,
      unitId: unitId,
      ttsUrl: ttsUrl,
      strokeData: strokeData,
    );
  }

  static String? _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is String) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) {
            return trimmed;
          }
        } else {
          return value.toString();
        }
      }
    }
    return null;
  }
}

@JsonSerializable()
class StrokeData {
  final int width;
  final int height;
  final List<String> paths;

  StrokeData({
    required this.width,
    required this.height,
    required this.paths,
  });

  factory StrokeData.fromJson(Map<String, dynamic> json) => _$StrokeDataFromJson(json);
  Map<String, dynamic> toJson() => _$StrokeDataToJson(this);

  factory StrokeData.fromFirestore(Map<String, dynamic> source) {
    final strokeDataRaw = source['strokeData'];

    if (strokeDataRaw is Map<String, dynamic>) {
      final width = _parseInt(strokeDataRaw['width']) ?? _parseInt(strokeDataRaw['StrokeWidth']) ?? 100;
      final height = _parseInt(strokeDataRaw['height']) ?? _parseInt(strokeDataRaw['StrokeHeight']) ?? 100;
      final paths = _parsePaths(strokeDataRaw['paths'] ?? strokeDataRaw['StrokePaths']);
      return StrokeData(width: width, height: height, paths: paths);
    }

    final width = _parseInt(source['width']) ?? _parseInt(source['strokeWidth']) ?? _parseInt(source['StrokeWidth']) ?? 100;
    final height = _parseInt(source['height']) ?? _parseInt(source['strokeHeight']) ?? _parseInt(source['StrokeHeight']) ?? 100;
    final paths = _parsePaths(source['paths'] ?? source['strokePaths'] ?? source['StrokePaths']);
    return StrokeData(width: width, height: height, paths: paths);
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String && value.trim().isNotEmpty) {
      return int.tryParse(value.trim());
    }
    return null;
  }

  static List<String> _parsePaths(dynamic raw) {
    if (raw == null) {
      return const [];
    }
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    final value = raw.toString();
    if (value.trim().isEmpty) {
      return const [];
    }
    return value
        .split('|')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();
  }
}
