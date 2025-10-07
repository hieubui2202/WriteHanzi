import '../../domain/entities/unit_model.dart';

class UnitModelData extends UnitModel {
  const UnitModelData({
    required super.id,
    required super.title,
    required super.description,
    required super.order,
    required super.characters,
    required super.xpReward,
  });

  factory UnitModelData.fromJson(Map<String, dynamic> json, String id) {
    return UnitModelData(
      id: id,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      characters: (json['characters'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'order': order,
        'characters': characters,
        'xpReward': xpReward,
      };
}
