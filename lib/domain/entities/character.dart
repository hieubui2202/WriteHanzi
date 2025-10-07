import 'package:equatable/equatable.dart';

import 'stroke_data.dart';

class Character extends Equatable {
  const Character({
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    required this.unitId,
    required this.strokeData,
    this.ttsUrl,
  });

  final String hanzi;
  final String pinyin;
  final String meaning;
  final String unitId;
  final String? ttsUrl;
  final StrokeData strokeData;

  @override
  List<Object?> get props => [hanzi, pinyin, meaning, unitId, ttsUrl, strokeData];
}
