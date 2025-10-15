import 'package:cloud_firestore/cloud_firestore.dart';

/// Describes the SVG stroke data used by the writing experience.
class StrokeData {
  const StrokeData({
    required this.width,
    required this.height,
    required this.paths,
  });

  final int width;
  final int height;
  final List<String> paths;

  factory StrokeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StrokeData(width: 109, height: 109, paths: <String>[]);
    }

    final rawPaths = json['paths'];
    final paths = rawPaths is Iterable
        ? rawPaths
            .map((value) => value.toString())
            .where((value) => value.trim().isNotEmpty)
            .toList()
        : const <String>[];

    return StrokeData(
      width: (json['width'] as num?)?.toInt() ?? 109,
      height: (json['height'] as num?)?.toInt() ?? 109,
      paths: paths,
    );
  }

  Map<String, dynamic> toJson() => {
        'width': width,
        'height': height,
        'paths': paths,
      };
}

/// Represents a single Hanzi character lesson used across the legacy "src"
/// feature set. The class acts as an adapter around the newer Firestore data
/// where fields such as [character] or [svgList] may be present.
class HanziCharacter {
  HanziCharacter({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.unitId,
    required StrokeData strokeData,
    this.word,
    this.ttsUrl,
    this.strokes,
    List<String>? svgList,
    Map<String, dynamic>? metadata,
  })  : strokeData = strokeData,
        svgList = List.unmodifiable(svgList ?? strokeData.paths),
        metadata = metadata == null
            ? const {}
            : Map<String, dynamic>.unmodifiable(metadata);

  final String id;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String unitId;
  final StrokeData strokeData;
  final String? word;
  final String? ttsUrl;
  final int? strokes;
  final List<String> svgList;
  final Map<String, dynamic> metadata;

  /// Provides backwards compatibility with code that still reads `character`.
  String get character => hanzi;

  /// Key used by the progress tracking service.
  String get progressKey => unitId.isEmpty ? hanzi : '${unitId}_$hanzi';

  /// Convenience constructor for previews or fallbacks.
  factory HanziCharacter.demo() => HanziCharacter(
        id: 'practice永',
        hanzi: '永',
        pinyin: 'yǒng',
        meaning: 'vĩnh cửu',
        unitId: 'practice',
        strokeData: const StrokeData(width: 109, height: 109, paths: <String>[]),
        word: '永',
        strokes: 8,
      );

  factory HanziCharacter.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    final strokeData = _strokeDataFrom(data);
    final svgList = _extractSvgList(data, strokeData.paths);

    return HanziCharacter(
      id: doc.id,
      hanzi: _readString(data, const ['hanzi', 'character', 'id', 'char']),
      pinyin: _readString(data, const ['pinyin']),
      meaning: _readString(data, const ['meaning', 'translation', 'english']),
      unitId: _readString(data, const ['unitId', 'unit', 'section']),
      strokeData: strokeData,
      word: _readOptionalString(data, const ['word', 'phrase']),
      ttsUrl: _readOptionalString(data, const ['ttsUrl', 'audioUrl']),
      strokes: _readInt(data, const ['strokes', 'strokeCount']),
      svgList: svgList,
      metadata: data,
    );
  }

  factory HanziCharacter.fromJson(Map<String, dynamic> json) {
    final strokeData = StrokeData.fromJson(
      json['strokeData'] as Map<String, dynamic>?,
    );
    final svgList = _extractSvgList(json, strokeData.paths);

    return HanziCharacter(
      id: json['id']?.toString() ?? json['hanzi']?.toString() ?? '',
      hanzi: json['hanzi']?.toString() ?? json['character']?.toString() ?? '',
      pinyin: json['pinyin']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? json['unit']?.toString() ?? '',
      strokeData: strokeData,
      word: json['word']?.toString(),
      ttsUrl: json['ttsUrl']?.toString(),
      strokes: (json['strokes'] as num?)?.toInt() ??
          (json['strokeCount'] as num?)?.toInt(),
      svgList: svgList,
      metadata: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hanzi': hanzi,
        'pinyin': pinyin,
        'meaning': meaning,
        'unitId': unitId,
        if (word != null && word!.isNotEmpty) 'word': word,
        if (ttsUrl != null && ttsUrl!.isNotEmpty) 'ttsUrl': ttsUrl,
        if (strokes != null) 'strokes': strokes,
        'svgList': svgList,
        'strokeData': strokeData.toJson(),
      };

  static StrokeData _strokeDataFrom(Map<String, dynamic> data) {
    final raw = data['strokeData'];
    if (raw is Map<String, dynamic>) {
      return StrokeData.fromJson(raw);
    }

    final width = (data['strokeWidth'] as num?)?.toInt() ?? 109;
    final height = (data['strokeHeight'] as num?)?.toInt() ?? 109;
    final svgList = _extractSvgList(data, const <String>[]);

    return StrokeData(width: width, height: height, paths: svgList);
  }

  static List<String> _extractSvgList(
    Map<String, dynamic> data,
    List<String> fallback,
  ) {
    final raw = data['svgList'] ?? data['paths'] ?? data['svg_paths'];
    if (raw is Iterable) {
      final list = raw
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .toList();
      if (list.isNotEmpty) {
        return list;
      }
    }
    return fallback;
  }

  static String _readString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static String? _readOptionalString(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return null;
  }
}
