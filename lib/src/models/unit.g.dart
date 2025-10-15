// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Unit _$UnitFromJson(Map<String, dynamic> json) => Unit(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: (json['order'] as num).toInt(),
      characters: (json['characters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      xpReward: (json['xpReward'] as num).toInt(),
      sectionId: json['sectionId'] as String?,
      sectionNumber: (json['sectionNumber'] as num?)?.toInt(),
      unitNumber: (json['unitNumber'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UnitToJson(Unit instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
    'description': instance.description,
    'order': instance.order,
    'characters': instance.characters,
    'xpReward': instance.xpReward,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('sectionId', instance.sectionId);
  writeNotNull('sectionNumber', instance.sectionNumber);
  writeNotNull('unitNumber', instance.unitNumber);
  return val;
}
