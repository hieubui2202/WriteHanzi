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

  factory Unit.fromFirestore(String id, Map<String, dynamic> data) {
    final title = _readString(data, ['title', 'unitName', 'SectionTitle']) ?? 'Unit $id';
    final description =
        _readString(data, ['description', 'summary', 'subtitle', 'SectionDescription']) ?? '';
    final order = _readInt(data, ['order', 'position', 'sectionOrder', 'Order']) ?? 0;

    final charactersRaw = data['characters'] ?? data['characterIds'] ?? data['Words'];
    final characters = _parseCharacters(charactersRaw);

    final xpReward = _readInt(data, ['xpReward', 'xp', 'reward']) ?? 0;

    return Unit(
      id: id,
      title: title,
      description: description,
      order: order,
      characters: characters,
      xpReward: xpReward,
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

  static int? _readInt(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        final value = data[key];
        if (value is int) {
          return value;
        }
        if (value is double) {
          return value.round();
        }
        if (value is String && value.trim().isNotEmpty) {
          final parsed = int.tryParse(value.trim());
          if (parsed != null) {
            return parsed;
          }
        }
      }
    }
    return null;
  }

  static List<String> _parseCharacters(dynamic raw) {
    if (raw == null) {
      return const [];
    }
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    final value = raw.toString();
    if (value.trim().isEmpty) {
      return const [];
    }
    return value.split(',').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }
}
