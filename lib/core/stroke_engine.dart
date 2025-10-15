import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// Utility helpers for converting SVG stroke data into Flutter [Path] objects,
/// resampling them to a fixed number of points, and matching user strokes
/// against canonical references with a DTW-based similarity metric.
class StrokeEngine {
  StrokeEngine({this.samplePoints = 64, this.tolerance = 28});

  /// Number of evenly spaced samples taken from each path.
  final int samplePoints;

  /// Maximum DTW distance (in logical pixels) tolerated when matching strokes.
  final double tolerance;

  /// Parses raw SVG path commands into a [Path].
  Path parse(String svgPath) {
    return parseSvgPathData(svgPath);
  }

  /// Samples a path into [samplePoints] offsets along its length.
  List<Offset> samplePath(Path path) {
    final iterator = path.computeMetrics().iterator;
    if (!iterator.moveNext()) {
      return const [];
    }
    final metric = iterator.current;
    final samples = <Offset>[];
    final length = metric.length;
    if (length == 0) {
      return const [];
    }

    for (int i = 0; i < samplePoints; i++) {
      final t = (i / (samplePoints - 1)) * length;
      final tangent = metric.getTangentForOffset(t);
      if (tangent != null) {
        samples.add(tangent.position);
      }
    }
    return _normalize(samples);
  }

  /// Samples an arbitrary set of points (e.g. from a drag gesture) to a fixed
  /// number of values using linear interpolation along the drawn polyline.
  List<Offset> resamplePoints(List<Offset> points) {
    if (points.length <= 2) {
      return _normalize(points);
    }
    final distances = <double>[0];
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
      distances.add(total);
    }
    if (total == 0) {
      return _normalize(points);
    }

    final step = total / (samplePoints - 1);
    final resampled = <Offset>[];
    double target = 0;
    int segment = 0;

    for (int i = 0; i < samplePoints; i++) {
      while (segment < distances.length - 1 && distances[segment + 1] < target) {
        segment++;
      }
      final start = points[segment];
      final end = points[math.min(segment + 1, points.length - 1)];
      final segmentStart = distances[segment];
      final segmentEnd = distances[math.min(segment + 1, distances.length - 1)];
      final range = math.max(segmentEnd - segmentStart, 0.0001);
      final lerpT = ((target - segmentStart) / range).clamp(0.0, 1.0);
      resampled.add(Offset.lerp(start, end, lerpT)!);
      target += step;
    }
    return _normalize(resampled);
  }

  /// Computes the DTW (Dynamic Time Warping) distance between two point sets.
  double dtwDistance(List<Offset> a, List<Offset> b) {
    if (a.isEmpty || b.isEmpty) {
      return double.infinity;
    }
    final rows = a.length;
    final cols = b.length;
    final dp = List.generate(rows, (_) => List<double>.filled(cols, double.infinity));

    dp[0][0] = (a[0] - b[0]).distance;
    for (int i = 1; i < rows; i++) {
      dp[i][0] = (a[i] - b[0]).distance + dp[i - 1][0];
    }
    for (int j = 1; j < cols; j++) {
      dp[0][j] = (a[0] - b[j]).distance + dp[0][j - 1];
    }
    for (int i = 1; i < rows; i++) {
      for (int j = 1; j < cols; j++) {
        final cost = (a[i] - b[j]).distance;
        final best = math.min(dp[i - 1][j], math.min(dp[i][j - 1], dp[i - 1][j - 1]));
        dp[i][j] = cost + best;
      }
    }
    return dp[rows - 1][cols - 1] / math.max(rows, cols);
  }

  /// Returns true when the user stroke matches the canonical path within the
  /// configured tolerance.
  bool matches(List<Offset> userStroke, Path standardPath) {
    if (userStroke.length < 2) {
      return false;
    }
    final sampledUser = resamplePoints(userStroke);
    final sampledStandard = samplePath(standardPath);
    final distance = dtwDistance(sampledUser, sampledStandard);
    return distance <= tolerance;
  }

  List<Offset> _normalize(List<Offset> points) {
    if (points.isEmpty) {
      return const [];
    }
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;
    for (final point in points) {
      minX = math.min(minX, point.dx);
      minY = math.min(minY, point.dy);
      maxX = math.max(maxX, point.dx);
      maxY = math.max(maxY, point.dy);
    }
    final width = math.max(maxX - minX, 0.0001);
    final height = math.max(maxY - minY, 0.0001);
    return points
        .map((point) => Offset((point.dx - minX) / width, (point.dy - minY) / height))
        .toList(growable: false);
  }
}
