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

  factory Unit.fromFirestore(Map<String, dynamic> data, String documentId) {
    final charactersField = data['characters'] ?? data['words'] ?? data['wordList'];
    final characters = _stringList(charactersField);

    final title = (data['title'] ??
            data['sectionTitle'] ??
            data['name'] ??
            _titleFromIdentifier(documentId))
        .toString();

    final description = (data['description'] ??
            data['sectionDescription'] ??
            data['subtitle'] ??
            '')
        .toString();

    final orderValue = data['order'] ?? data['position'] ?? data['index'];
    final computedOrder = _parseInt(orderValue, fallback: _deriveOrderFromId(documentId));

    final xp = _parseInt(data['xpReward'] ?? data['xp'] ?? data['reward'],
        fallback: (characters.isNotEmpty ? characters.length * 10 : 10));

    return Unit(
      id: documentId,
      title: title,
      description: description,
      order: computedOrder,
      characters: characters,
      xpReward: xp,
    );
  }
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  if (value is String && value.isNotEmpty) {
    return value
        .split(',')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();
  }
  return const [];
}

int _parseInt(
  dynamic value, {
  required int fallback,
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

int _deriveOrderFromId(String id) {
  final matches = RegExp(r'\d+').allMatches(id);
  final numbers = matches
      .map((match) => int.tryParse(match.group(0) ?? ''))
      .whereType<int>()
      .toList();
  if (numbers.isEmpty) {
    return 0;
  }
  if (numbers.length == 1) {
    return numbers.first;
  }
  // Weight the section more heavily than the unit number so ordering is
  // deterministic even without an explicit `order` field.
  return numbers[0] * 100 + numbers[1];
}

String _titleFromIdentifier(String id) {
  return id.replaceAll('_', ' ').replaceAll('-', ' ').split(' ').map((word) {
    if (word.isEmpty) return word;
    final lower = word.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }).join(' ');
}
