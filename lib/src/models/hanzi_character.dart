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
