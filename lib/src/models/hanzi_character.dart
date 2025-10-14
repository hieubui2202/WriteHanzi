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
    final unitId = _readString(
          data,
          [
            'unitId',
            'sectionId',
            'SectionID',
            'section',
            'SectionTitle',
          ],
        ) ??
        fallbackUnitId ??
        '';
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
      final svgCandidate = strokeDataRaw['svgList'] ?? strokeDataRaw['svg_list'];
      final svgParsed = _tryParseSvgList(svgCandidate, strokeDataRaw);
      if (svgParsed != null) {
        return svgParsed;
      }

      final width =
          _parseInt(strokeDataRaw['width']) ?? _parseInt(strokeDataRaw['StrokeWidth']) ?? 100;
      final height =
          _parseInt(strokeDataRaw['height']) ?? _parseInt(strokeDataRaw['StrokeHeight']) ?? 100;
      final paths = _parsePaths(strokeDataRaw['paths'] ?? strokeDataRaw['StrokePaths']);

      if (paths.isNotEmpty) {
        return StrokeData(width: width, height: height, paths: paths);
      }
    }

    final svgList = source['svgList'] ?? source['svg_list'] ?? source['svgPaths'];
    final svgParsed = _tryParseSvgList(svgList, source);
    if (svgParsed != null) {
      return svgParsed;
    }

    final width = _parseInt(source['width']) ??
        _parseInt(source['strokeWidth']) ??
        _parseInt(source['StrokeWidth']) ??
        100;
    final height = _parseInt(source['height']) ??
        _parseInt(source['strokeHeight']) ??
        _parseInt(source['StrokeHeight']) ??
        100;
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

  static StrokeData? _tryParseSvgList(dynamic raw, Map<String, dynamic> context) {
    if (raw == null) {
      return null;
    }

    final List<dynamic> entries;
    if (raw is List) {
      entries = raw;
    } else {
      entries = [raw];
    }

    final paths = <String>[];
    int? width;
    int? height;

    for (final entry in entries) {
      if (entry is Map<String, dynamic>) {
        width ??= _parseInt(entry['width']) ??
            _parseInt(entry['strokeWidth']) ??
            _parseInt(entry['StrokeWidth']);
        height ??= _parseInt(entry['height']) ??
            _parseInt(entry['strokeHeight']) ??
            _parseInt(entry['StrokeHeight']);

        final nestedPaths = _parsePaths(entry['paths'] ?? entry['strokePaths'] ?? entry['StrokePaths']);
        if (nestedPaths.isNotEmpty) {
          paths.addAll(nestedPaths);
        }

        for (final key in const ['path', 'd', 'strokePath', 'StrokePath', 'svg', 'svgPath']) {
          if (entry.containsKey(key)) {
            paths.addAll(_parsePaths(entry[key]));
          }
        }
      } else {
        paths.addAll(_parsePaths(entry));
      }
    }

    if (paths.isEmpty) {
      return null;
    }

    width ??= _parseInt(context['strokeWidth']) ?? _parseInt(context['width']);
    height ??= _parseInt(context['strokeHeight']) ?? _parseInt(context['height']);

    final dedupedPaths = <String>[];
    for (final path in paths) {
      if (path.trim().isEmpty) {
        continue;
      }
      if (!dedupedPaths.contains(path)) {
        dedupedPaths.add(path);
      }
    }

    return StrokeData(
      width: width ?? height ?? 109,
      height: height ?? width ?? 109,
      paths: dedupedPaths,
    );
  }
}
