import 'dart:math';
import 'dart:ui';

import '../../../models/hanzi_character.dart';

class WritingFeedback {
  const WritingFeedback({
    required this.score,
    required this.strokeAccuracy,
    required this.coverageAccuracy,
    required this.lengthAccuracy,
    required this.expectedStrokes,
    required this.drawnStrokes,
  });

  final double score;
  final double strokeAccuracy;
  final double coverageAccuracy;
  final double lengthAccuracy;
  final int expectedStrokes;
  final int drawnStrokes;

  bool get isSuccess => score >= 0.6;

  String get headline {
    if (score >= 0.85) return 'Tuyệt vời!';
    if (score >= 0.6) return 'Làm tốt lắm!';
    return 'Hãy thử lại nhé';
  }

  String get detail {
    if (score >= 0.85) {
      return 'Nét viết của bạn rất giống mẫu chuẩn.';
    }
    if (score >= 0.6) {
      return 'Bạn đã viết đúng phần lớn các nét. Hãy tinh chỉnh thêm một chút!';
    }
    return 'Hãy chú ý đến thứ tự và độ dài của các nét rồi thử lại.';
  }
}

class WritingEvaluator {
  static WritingFeedback evaluate({
    required StrokeData strokeData,
    required List<List<Offset>> referenceStrokes,
    required List<List<Offset>> drawnStrokes,
    required Size canvasSize,
  }) {
    final expectedStrokes = referenceStrokes.length;
    final drawnCount = drawnStrokes.where((stroke) => stroke.length > 1).length;

    final strokeAccuracy = _strokeCountAccuracy(expectedStrokes, drawnCount);
    final lengthAccuracy = _lengthAccuracy(
      referenceStrokes,
      drawnStrokes,
      Size(strokeData.width.toDouble(), strokeData.height.toDouble()),
      canvasSize,
    );
    final coverageAccuracy = _coverageAccuracy(
      referenceStrokes,
      drawnStrokes,
      Size(strokeData.width.toDouble(), strokeData.height.toDouble()),
      canvasSize,
    );

    final score = (strokeAccuracy + lengthAccuracy + coverageAccuracy) / 3;

    return WritingFeedback(
      score: score,
      strokeAccuracy: strokeAccuracy,
      coverageAccuracy: coverageAccuracy,
      lengthAccuracy: lengthAccuracy,
      expectedStrokes: expectedStrokes,
      drawnStrokes: drawnCount,
    );
  }

  static double _strokeCountAccuracy(int expected, int actual) {
    if (expected == 0 && actual == 0) {
      return 1.0;
    }
    if (expected == 0 || actual == 0) {
      return 0.0;
    }
    final difference = (expected - actual).abs();
    return max(0.0, 1.0 - difference / expected);
  }

  static double _lengthAccuracy(
    List<List<Offset>> reference,
    List<List<Offset>> drawn,
    Size referenceSize,
    Size drawnSize,
  ) {
    final expectedLength = _totalNormalizedLength(reference, referenceSize);
    final drawnLength = _totalNormalizedLength(drawn, drawnSize);

    if (expectedLength == 0 && drawnLength == 0) {
      return 1.0;
    }
    if (expectedLength == 0 || drawnLength == 0) {
      return 0.0;
    }

    final ratio = drawnLength / expectedLength;
    if (ratio >= 1) {
      return 1 / ratio;
    }
    return ratio;
  }

  static double _coverageAccuracy(
    List<List<Offset>> reference,
    List<List<Offset>> drawn,
    Size referenceSize,
    Size drawnSize,
  ) {
    final referenceRect = _bounds(reference, referenceSize);
    final drawnRect = _bounds(drawn, drawnSize);

    if (referenceRect == null || drawnRect == null) {
      return 0.0;
    }

    final intersection = referenceRect.intersect(drawnRect);
    if (intersection.isEmpty) {
      return 0.0;
    }

    final intersectionArea = intersection.width * intersection.height;
    final referenceArea = referenceRect.width * referenceRect.height;
    if (referenceArea == 0) {
      return 0.0;
    }
    return (intersectionArea / referenceArea).clamp(0.0, 1.0);
  }

  static double _totalNormalizedLength(
    List<List<Offset>> strokes,
    Size size,
  ) {
    var total = 0.0;
    for (final stroke in strokes) {
      for (var i = 1; i < stroke.length; i++) {
        final dx = (stroke[i].dx - stroke[i - 1].dx) / size.width;
        final dy = (stroke[i].dy - stroke[i - 1].dy) / size.height;
        total += sqrt(dx * dx + dy * dy);
      }
    }
    return total;
  }

  static Rect? _bounds(List<List<Offset>> strokes, Size size) {
    double? minX, minY, maxX, maxY;
    for (final stroke in strokes) {
      for (final point in stroke) {
        if (point.dx.isNaN || point.dy.isNaN) {
          continue;
        }
        final normalizedX = point.dx / size.width;
        final normalizedY = point.dy / size.height;
        minX = minX == null ? normalizedX : min(minX, normalizedX);
        minY = minY == null ? normalizedY : min(minY, normalizedY);
        maxX = maxX == null ? normalizedX : max(maxX, normalizedX);
        maxY = maxY == null ? normalizedY : max(maxY, normalizedY);
      }
    }

    if (minX == null || minY == null || maxX == null || maxY == null) {
      return null;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
