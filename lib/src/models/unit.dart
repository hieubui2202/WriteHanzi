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

  @JsonKey(includeIfNull: false)
  final String? sectionId;

  @JsonKey(includeIfNull: false)
  final int? sectionNumber;

  @JsonKey(includeIfNull: false)
  final int? unitNumber;

  Unit({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.characters,
    required this.xpReward,
    this.sectionId,
    this.sectionNumber,
    this.unitNumber,
  });

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
  Map<String, dynamic> toJson() => _$UnitToJson(this);

  factory Unit.fromFirestore(String id, Map<String, dynamic> data) {
    final sectionInfo = _parseSectionAndUnit(id, data);

    final title = _readString(
          data,
          [
            'title',
            'Title',
            'unitName',
            'sectionTitle',
            'SectionTitle',
          ],
        ) ??
        _fallbackTitle(id, sectionInfo);

    final description = _readString(
          data,
          [
            'description',
            'Description',
            'summary',
            'subtitle',
            'sectionDescription',
            'SectionDescription',
          ],
        ) ??
        '';

    final order = _readInt(
          data,
          [
            'order',
            'Order',
            'position',
            'sectionOrder',
            'unitOrder',
            'index',
            'unit',
            'Unit',
          ],
        ) ??
        _deriveOrder(sectionInfo) ??
        0;

    final charactersRaw = data['characters'] ??
        data['characterIds'] ??
        data['words'] ??
        data['Words'] ??
        data['hanzi'] ??
        data['hanziList'];
    final characters = _parseCharacters(charactersRaw);

    final xpReward = _readInt(
          data,
          ['xpReward', 'xp', 'reward', 'wordCount', 'WordCount'],
        ) ??
        (characters.length * 10);

    final resolvedSectionId = _resolveSectionId(id, data, sectionInfo);
    final resolvedSectionNumber = _resolveSectionNumber(data, sectionInfo, resolvedSectionId, title);
    final resolvedUnitNumber = _resolveUnitNumber(data, sectionInfo, resolvedSectionId, title);

    return Unit(
      id: id,
      title: title,
      description: description,
      order: order,
      characters: characters,
      xpReward: xpReward,
      sectionId: resolvedSectionId,
      sectionNumber: resolvedSectionNumber,
      unitNumber: resolvedUnitNumber,
    );
  }

  List<String> candidateCharacterKeys() {
    final keys = <String>{};

    void addKey(String? value) {
      if (value == null) {
        return;
      }
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      keys.add(trimmed);
      keys.add(trimmed.replaceAll('•', ' '));
      keys.add(trimmed.replaceAll(RegExp(r'[\s•]+'), ' '));
      keys.add(trimmed.replaceAll(RegExp(r'[_\s•]+'), ''));
    }

    addKey(id);
    addKey(id.replaceAll('__', '_'));

    addKey(title);
    addKey(description);
    addKey(sectionId);

    if (sectionNumber != null && unitNumber != null) {
      final section = sectionNumber!;
      final unit = unitNumber!;
      addKey('section_${section}_unit_${unit}');
      addKey('section_${section}_unit$unit');
      addKey('section${section}_unit${unit}');
      addKey('section${section}unit${unit}');
      addKey('section-$section-unit-$unit');
      addKey('Section $section, Unit $unit');
      addKey('Section $section Unit $unit');
      addKey('section $section unit $unit');
    }

    return keys.where((value) => value.trim().isNotEmpty).toList();
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

    final seen = <String>{};
    final ordered = <String>[];

    void addValue(String? value) {
      if (value == null) {
        return;
      }
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      if (seen.add(trimmed)) {
        ordered.add(trimmed);
      }
    }

    String? extract(dynamic value) {
      if (value == null) {
        return null;
      }
      if (value is String) {
        return value.trim().isEmpty ? null : value.trim();
      }
      if (value is Map) {
        for (final key in const [
          'hanzi',
          'character',
          'word',
          'Word',
          'id',
          'characterId',
          'hanziId',
          'text',
          'value',
        ]) {
          if (value.containsKey(key)) {
            final nested = extract(value[key]);
            if (nested != null) {
              return nested;
            }
          }
        }
        for (final nested in value.values) {
          final candidate = extract(nested);
          if (candidate != null) {
            return candidate;
          }
        }
        return null;
      }
      if (value is Iterable) {
        for (final item in value) {
          final candidate = extract(item);
          if (candidate != null) {
            return candidate;
          }
        }
        return null;
      }
      final asString = value.toString().trim();
      return asString.isEmpty ? null : asString;
    }

    if (raw is Iterable) {
      for (final item in raw) {
        addValue(extract(item));
      }
    } else if (raw is Map) {
      for (final value in raw.values) {
        addValue(extract(value));
      }
    } else {
      final stringValue = extract(raw);
      if (stringValue != null) {
        for (final entry in stringValue.split(',')) {
          addValue(entry);
        }
      }
    }

    return ordered;
  }

  static ({int? section, int? unit}) _parseSectionAndUnit(String id, Map<String, dynamic> data) {
    int? section = _readInt(data, ['section', 'Section', 'sectionIndex', 'sectionNumber']);
    section ??= _readInt(data, ['sectionId', 'SectionID']);

    int? unit = _readInt(data, ['unit', 'Unit', 'unitNumber', 'unitIndex']);

    final match = RegExp(r'section[_-]?(\d+).*unit[_-]?(\d+)', caseSensitive: false).firstMatch(id);
    if (match != null) {
      section ??= int.tryParse(match.group(1)!);
      unit ??= int.tryParse(match.group(2)!);
    }

    return (section: section, unit: unit);
  }

  static String _fallbackTitle(String id, ({int? section, int? unit}) info) {
    final section = info.section;
    final unit = info.unit;
    if (section != null || unit != null) {
      final sectionLabel = section != null ? 'Section $section' : 'Section';
      final unitLabel = unit != null ? 'Unit $unit' : 'Unit';
      return '$sectionLabel • $unitLabel';
    }
    return 'Unit $id';
  }

  static int? _deriveOrder(({int? section, int? unit}) info) {
    final section = info.section;
    final unit = info.unit;
    if (section == null && unit == null) {
      return null;
    }
    final sectionWeight = (section ?? 0) * 1000;
    final unitWeight = unit ?? 0;
    return sectionWeight + unitWeight;
  }

  static String? _resolveSectionId(
      String id, Map<String, dynamic> data, ({int? section, int? unit}) info) {
    final candidate = _readString(data, [
          'sectionId',
          'SectionID',
          'sectionKey',
          'sectionRef',
          'sectionPath',
          'sectionDocument',
          'sectionDoc',
        ]) ??
        _coerceToString(data['section']) ??
        _coerceToString(data['Section']);

    final section = info.section;
    final unit = info.unit;

    if (candidate != null) {
      final trimmed = candidate.trim();
      if (trimmed.isNotEmpty) {
        final numericOnly = RegExp(r'^\d+$');
        if (numericOnly.hasMatch(trimmed) && section != null && unit != null) {
          return 'section_${section}_unit_${unit}';
        }
        return trimmed;
      }
    }

    if (section != null && unit != null) {
      return 'section_${section}_unit_${unit}';
    }

    return id;
  }

  static int? _resolveSectionNumber(
    Map<String, dynamic> data,
    ({int? section, int? unit}) info,
    String? sectionId,
    String title,
  ) {
    final direct = _readInt(data, [
      'sectionNumber',
      'section',
      'Section',
      'sectionIndex',
      'sectionNo',
    ]);
    if (direct != null) {
      return direct;
    }

    final derived = info.section;
    if (derived != null) {
      return derived;
    }

    final fromSectionId = _extractFirstInt(sectionId);
    if (fromSectionId != null) {
      return fromSectionId;
    }

    return _extractFirstInt(title);
  }

  static int? _resolveUnitNumber(
    Map<String, dynamic> data,
    ({int? section, int? unit}) info,
    String? sectionId,
    String title,
  ) {
    final direct = _readInt(data, [
      'unitNumber',
      'unit',
      'Unit',
      'unitIndex',
      'unitNo',
    ]);
    if (direct != null) {
      return direct;
    }

    final derived = info.unit;
    if (derived != null) {
      return derived;
    }

    final fromSectionId = _extractLastInt(sectionId);
    if (fromSectionId != null) {
      return fromSectionId;
    }

    return _extractLastInt(title);
  }

  static String? _coerceToString(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }

  static int? _extractFirstInt(String? value) {
    if (value == null) {
      return null;
    }
    final match = RegExp(r'(\d+)').firstMatch(value);
    if (match == null) {
      return null;
    }
    return int.tryParse(match.group(1)!);
  }

  static int? _extractLastInt(String? value) {
    if (value == null) {
      return null;
    }
    final matches = RegExp(r'(\d+)').allMatches(value).toList();
    if (matches.isEmpty) {
      return null;
    }
    return int.tryParse(matches.last.group(1)!);
  }
}
