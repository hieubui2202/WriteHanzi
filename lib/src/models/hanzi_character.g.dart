// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hanzi_character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HanziCharacter _$HanziCharacterFromJson(Map<String, dynamic> json) =>
    HanziCharacter(
      hanzi: json['hanzi'] as String,
      pinyin: json['pinyin'] as String,
      meaning: json['meaning'] as String,
      unitId: json['unitId'] as String,
      ttsUrl: json['ttsUrl'] as String?,
      strokeData: StrokeData.fromJson(
        json['strokeData'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$HanziCharacterToJson(HanziCharacter instance) =>
    <String, dynamic>{
      'hanzi': instance.hanzi,
      'pinyin': instance.pinyin,
      'meaning': instance.meaning,
      'unitId': instance.unitId,
      'ttsUrl': instance.ttsUrl,
      'strokeData': instance.strokeData.toJson(),
    };

StrokeData _$StrokeDataFromJson(Map<String, dynamic> json) => StrokeData(
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  paths: (json['paths'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$StrokeDataToJson(StrokeData instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'paths': instance.paths,
    };
