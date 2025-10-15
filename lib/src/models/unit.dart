class Unit {
  final String id;
  final String section;
  final int sectionIndex;
  final int unitNumber;
  final List<String> characters;
  final List<String> words;
  final int wordCount;

  Unit({
    required this.id,
    required this.section,
    required this.sectionIndex,
    required this.unitNumber,
    required List<String> characters,
    required List<String> words,
    required this.wordCount,
  })  : characters = List.unmodifiable(characters),
        words = List.unmodifiable(words);

  factory Unit.fromMap(Map<String, dynamic> data, {required String id}) {
    final characters = (data['characters'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final wordsField = data['words'];
    final words = wordsField is List
        ? wordsField.map((e) => e.toString()).toList()
        : wordsField is Map
            ? (wordsField.values).map((e) => e.toString()).toList()
            : const <String>[];
    final sectionIndex = _resolveSectionIndex(id, data['section']);
    final unitNumber = (data['unit'] as num?)?.toInt() ?? _resolveUnitIndex(id);

    return Unit(
      id: id,
      section: data['section']?.toString() ?? 'Unit $unitNumber',
      sectionIndex: sectionIndex,
      unitNumber: unitNumber,
      characters: characters,
      words: words,
      wordCount: (data['wordCount'] as num?)?.toInt() ?? words.length,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'section': section,
      'unit': unitNumber,
      'characters': characters,
      'words': words,
      'wordCount': wordCount,
    };
  }

  String get displayTitle {
    return '$section · Bài $unitNumber';
  }

  String get subtitle {
    if (words.isNotEmpty) {
      final preview = words.take(3).join(' • ');
      final suffix = words.length > 3 ? '…' : '';
      return '$preview$suffix  •  $wordCount từ';
    }
    if (characters.isNotEmpty) {
      return '${characters.join(' · ')}  •  $wordCount từ';
    }
    return 'Số từ: $wordCount';
  }

  int get sortKey => sectionIndex * 100 + unitNumber;

  static int _resolveSectionIndex(String id, dynamic sectionField) {
    if (sectionField is num) {
      return sectionField.toInt();
    }
    final parsedFromField = int.tryParse(sectionField?.toString() ?? '');
    if (parsedFromField != null) {
      return parsedFromField;
    }

    final parts = id.split('_');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] == 'section' && i + 1 < parts.length) {
        final value = int.tryParse(parts[i + 1]);
        if (value != null) {
          return value;
        }
      }
    }
    return 0;
  }

  static int _resolveUnitIndex(String id) {
    final parts = id.split('_');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] == 'unit' && i + 1 < parts.length) {
        final value = int.tryParse(parts[i + 1]);
        if (value != null) {
          return value;
        }
      }
    }
    return 0;
  }
}
