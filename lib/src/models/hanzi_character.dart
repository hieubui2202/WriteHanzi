import 'package:json_annotation/json_annotation.dart';

part 'hanzi_character.g.dart';

@JsonSerializable()
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

  factory HanziCharacter.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final hanziValue = (data['hanzi'] ?? data['character'] ?? data['word'] ?? documentId).toString();
    final pinyinValue = (data['pinyin'] ?? data['transliteration'] ?? data['romanization'] ?? '').toString();
    final meaningValue = (data['meaning'] ?? data['translation'] ?? data['definition'] ?? '').toString();
    final unitValue = (data['unitId'] ?? data['unit'] ?? data['sectionId'] ?? data['section'] ?? '').toString();
    final ttsValue = (data['ttsUrl'] ?? data['tts'] ?? data['audioUrl'] ?? data['audio'])?.toString();

    final strokeDataMap = _extractStrokeDataMap(data);
    final width = _parseInt(
      strokeDataMap['width'] ??
          strokeDataMap['strokeWidth'] ??
          strokeDataMap['w'] ??
          data['strokeWidth'] ??
          data['strokeW'],
      fallback: 109,
    );
    final height = _parseInt(
      strokeDataMap['height'] ??
          strokeDataMap['strokeHeight'] ??
          strokeDataMap['h'] ??
          data['strokeHeight'] ??
          data['strokeH'],
      fallback: 109,
    );

    final rawPaths = strokeDataMap['paths'] ??
        strokeDataMap['svgList'] ??
        data['svgList'] ??
        data['paths'];
    final pathList = _normalizePathList(rawPaths);

    return HanziCharacter(
      id: documentId,
      hanzi: hanziValue,
      pinyin: pinyinValue,
      meaning: meaningValue,
      unitId: unitValue,
      ttsUrl: ttsValue,
      strokeData: StrokeData(
        width: width,
        height: height,
        paths: pathList,
      ),
    );
  }

  HanziCharacter copyWithId(String id) {
    return HanziCharacter(
      id: id,
      hanzi: this.hanzi,
      pinyin: this.pinyin,
      meaning: this.meaning,
      unitId: this.unitId,
      ttsUrl: this.ttsUrl,
      strokeData: this.strokeData,
    );
  }

  String get progressKey => id.isNotEmpty ? id : hanzi;
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

}

Map<String, dynamic> _extractStrokeDataMap(Map<String, dynamic> data) {
  final strokeData = data['strokeData'];
  if (strokeData is Map<String, dynamic>) {
    return strokeData;
  }
  return const <String, dynamic>{};
}

int _parseInt(
  dynamic value, {
  int fallback = 0,
}) {
  if (value == null) {
    return fallback;
  }
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

List<String> _normalizePathList(dynamic value) {
  if (value is List) {
    return value
        .map((entry) => entry.toString())
        .where((entry) => entry.trim().isNotEmpty)
        .toList();
  }
  if (value is String && value.isNotEmpty) {
    return value
        .split('|')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();
  }
  return const [];
}
