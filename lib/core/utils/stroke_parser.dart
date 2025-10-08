import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

class StrokeParser {
  const StrokeParser();

  Path parseSvgPath(String pathData) {
    return parseSvgPathData(pathData);
  }

  List<Offset> samplePath(Path path, {int samples = 64}) {
    final points = <Offset>[];
    for (final metric in path.computeMetrics()) {
      final length = metric.length;
      for (int i = 0; i <= samples; i++) {
        final position = metric.getTangentForOffset(length * (i / samples))?.position;
        if (position != null) {
          points.add(position);
        }
      }
    }
    return points;
  }
}
