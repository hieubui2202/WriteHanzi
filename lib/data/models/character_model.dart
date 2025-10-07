import '../../domain/entities/character.dart';
import '../../domain/entities/stroke_data.dart';
import 'stroke_data_model.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.hanzi,
    required super.pinyin,
    required super.meaning,
    required super.unitId,
    required super.strokeData,
    super.ttsUrl,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final strokeData = json['strokeData'];
    return CharacterModel(
      hanzi: json['hanzi']?.toString() ?? '',
      pinyin: json['pinyin']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      ttsUrl: json['ttsUrl']?.toString(),
      strokeData: strokeData is Map<String, dynamic>
          ? StrokeDataModel.fromJson(strokeData)
          : StrokeDataModel(width: 100, height: 100, paths: const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hanzi': hanzi,
      'pinyin': pinyin,
      'meaning': meaning,
      'unitId': unitId,
      'ttsUrl': ttsUrl,
      'strokeData': (strokeData is StrokeDataModel)
          ? (strokeData as StrokeDataModel).toJson()
          : {
              'width': strokeData.width,
              'height': strokeData.height,
              'paths': strokeData.paths,
            },
    };
  }
}
