import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

class StrokeParser {
  const StrokeParser();

  Path parseSvgPath(String pathData) {
    final path = Path();
    writeSvgPathDataToPath(pathData, PathProxyFillType(path));
    return path;
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

class PathProxyFillType extends PathProxy {
  PathProxyFillType(this.path);

  final Path path;

  @override
  void close() => path.close();

  @override
  void cubicTo(double x1, double y1, double x2, double y2, double x3, double y3) =>
      path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) =>
      path.quadraticBezierTo(x1, y1, x2, y2);

  @override
  void arcToPoint(Offset arcEnd, {Radius radius = Radius.zero, double rotation = 0.0, bool largeArc = false, bool clockwise = true}) =>
      path.arcToPoint(arcEnd, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);

  @override
  void relativeArcToPoint(Offset arcEndDelta, {Radius radius = Radius.zero, double rotation = 0.0, bool largeArc = false, bool clockwise = true}) =>
      path.relativeArcToPoint(arcEndDelta, radius: radius, rotation: rotation, largeArc: largeArc, clockwise: clockwise);

  @override
  void relativeCubicTo(double x1, double y1, double x2, double y2, double x3, double y3) =>
      path.relativeCubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void relativeLineTo(double x, double y) => path.relativeLineTo(x, y);

  @override
  void relativeMoveTo(double x, double y) => path.relativeMoveTo(x, y);

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) =>
      path.relativeQuadraticBezierTo(x1, y1, x2, y2);
}
