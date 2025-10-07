import 'dart:ui';

import '../../../models/hanzi_character.dart';

/// Utility helpers for parsing the SVG-style stroke data stored in
/// [StrokeData.paths]. The dataset currently uses a very small subset of the
/// SVG path grammar (only `M` and `L` commands with absolute coordinates),
/// which keeps the parsing logic lightweight while still allowing us to
/// visualize and analyse stroke order.
class StrokeParser {
  static final _commandPattern =
      RegExp(r'([MmLl])\s*([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)');

  /// Parses the [strokeData] paths into a list of strokes. Each stroke is
  /// represented as an ordered list of [Offset] points expressed in the
  /// original coordinate system of the stroke data.
  static List<List<Offset>> parsePaths(StrokeData strokeData) {
    final parsed = <List<Offset>>[];
    for (final rawPath in strokeData.paths) {
      final stroke = _parseSinglePath(rawPath);
      if (stroke != null) {
        parsed.add(stroke);
      }
    }
    return List<List<Offset>>.unmodifiable(parsed);
  }

  static List<Offset>? _parseSinglePath(String rawPath) {
    final matches = _commandPattern.allMatches(rawPath);
    if (matches.isEmpty) {
      return null;
    }

    final points = <Offset>[];
    for (final match in matches) {
      final x = double.tryParse(match.group(2) ?? '');
      final y = double.tryParse(match.group(3) ?? '');
      if (x == null || y == null) {
        continue;
      }
      points.add(Offset(x, y));
    }

    return points.isEmpty ? null : points;
  }
}
