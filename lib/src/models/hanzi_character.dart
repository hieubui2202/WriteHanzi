class HanziCharacter {
  final String id;
  final String hanzi;
  final String pinyin;
  final String meaning;
  final String? section;
  final int? strokeCount;
  final String? ttsUrl;
  final String? word;
  final List<String> strokePaths;

  HanziCharacter({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.meaning,
    this.section,
    this.strokeCount,
    this.ttsUrl,
    this.word,
    List<String>? strokePaths,
  }) : strokePaths = List.unmodifiable(strokePaths ?? const []);

  factory HanziCharacter.fromMap(Map<String, dynamic> data, {required String id}) {
    return HanziCharacter(
      id: id,
      hanzi: data['character']?.toString().isNotEmpty == true
          ? data['character'].toString()
          : id,
      pinyin: data['pinyin']?.toString() ?? '',
      meaning: data['meaning']?.toString() ?? '',
      section: data['section']?.toString(),
      strokeCount: (data['strokes'] as num?)?.toInt(),
      ttsUrl: data['ttsUrl']?.toString(),
      word: data['word']?.toString(),
      strokePaths: _parseStrokePaths(data),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'character': hanzi,
      'pinyin': pinyin,
      'meaning': meaning,
      if (section != null) 'section': section,
      if (strokeCount != null) 'strokes': strokeCount,
      if (ttsUrl != null) 'ttsUrl': ttsUrl,
      if (word != null) 'word': word,
      if (strokePaths.isNotEmpty) 'svgList': strokePaths,
    };
  }

  static List<String> _parseStrokePaths(Map<String, dynamic> data) {
    final svgList = data['svgList'];
    if (svgList is List) {
      return svgList.map((e) => e.toString()).toList();
    }
    if (svgList is String) {
      return svgList
          .split(RegExp(r'[|;,]'))
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();
    }

    final strokeData = data['strokeData'];
    if (strokeData is Map<String, dynamic>) {
      final paths = strokeData['paths'];
      if (paths is List) {
        return paths.map((e) => e.toString()).toList();
      }
      if (paths is String) {
        return paths
            .split('|')
            .map((e) => e.trim())
            .where((element) => element.isNotEmpty)
            .toList();
      }
    }

    return const [];
  }
}
