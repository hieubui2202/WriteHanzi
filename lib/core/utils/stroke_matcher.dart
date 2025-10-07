import 'dart:math';
import 'dart:ui';

class StrokeMatcher {
  StrokeMatcher({this.tolerance = 0.25});

  final double tolerance;

  bool matches(List<Offset> expected, List<Offset> actual) {
    if (expected.isEmpty || actual.isEmpty) {
      return false;
    }

    final expectedBounds = _bounds(expected);
    final actualBounds = _bounds(actual);

    if (expectedBounds.width == 0 || expectedBounds.height == 0) {
      return false;
    }

    final scaleX = expectedBounds.width / (actualBounds.width == 0 ? 1 : actualBounds.width);
    final scaleY = expectedBounds.height / (actualBounds.height == 0 ? 1 : actualBounds.height);

    double total = 0;
    final sampleCount = min(expected.length, actual.length);
    for (int i = 0; i < sampleCount; i++) {
      final e = _normalize(expected[i], expectedBounds);
      final a = _normalize(actual[(actual.length * i ~/ sampleCount).clamp(0, actual.length - 1)], actualBounds);
      final distance = (Offset(a.dx * scaleX, a.dy * scaleY) - Offset(e.dx, e.dy)).distance;
      total += distance;
    }

    final average = total / sampleCount;
    return average < tolerance;
  }

  Rect _bounds(List<Offset> points) {
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final point in points) {
      minX = min(minX, point.dx);
      maxX = max(maxX, point.dx);
      minY = min(minY, point.dy);
      maxY = max(maxY, point.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Offset _normalize(Offset point, Rect bounds) {
    final width = bounds.width == 0 ? 1 : bounds.width;
    final height = bounds.height == 0 ? 1 : bounds.height;
    return Offset((point.dx - bounds.left) / width, (point.dy - bounds.top) / height);
  }
}
