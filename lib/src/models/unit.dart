import 'package:json_annotation/json_annotation.dart';

part 'unit.g.dart';

@JsonSerializable()
class Unit {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<String> characters; // List of hanzi characters
  final int xpReward;

  Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.characters,
    required this.xpReward,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);
}
