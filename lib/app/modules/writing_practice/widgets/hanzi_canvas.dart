import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import 'hanzi_painter.dart';

class HanziCanvas extends StatefulWidget {
  const HanziCanvas({
    super.key,
    required this.referencePaths,
    required this.referenceBounds,
    required this.strokeColor,
    required this.strokeWidth,
    this.preRenderedCount = 0,
    this.expectPaths,
    this.onStrokeMatched,
    this.onStrokeRejected,
  });

  final List<Path> referencePaths;
  final Rect referenceBounds;
  final Color strokeColor;
  final double strokeWidth;
  final int preRenderedCount;
  final List<Path>? expectPaths;
  final ValueChanged<int>? onStrokeMatched;
  final VoidCallback? onStrokeRejected;

  @override
  HanziCanvasState createState() => HanziCanvasState();
}

class HanziCanvasState extends State<HanziCanvas> {
  static const _paddingRatio = 0.1;
  static const _samplePoints = 64;

  final List<List<Offset>> _lines = <List<Offset>>[];

  late int _preRenderedCount;
  late List<Path> _rawExpectedPaths;

  List<Path> _scaledReferencePaths = const [];
  List<Path> _scaledExpectedPaths = const [];

  int _matchedCount = 0;
  Size? _canvasSize;
  Offset? _pointerStart;
  Offset? _pointerDirection;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _preRenderedCount = widget.preRenderedCount.clamp(0, widget.referencePaths.length);
    _rawExpectedPaths = widget.expectPaths ??
        widget.referencePaths.sublist(_preRenderedCount, widget.referencePaths.length);
  }

  @override
  void didUpdateWidget(covariant HanziCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.referencePaths, oldWidget.referencePaths) ||
        widget.referenceBounds != oldWidget.referenceBounds) {
      _canvasSize = null; // triggers recompute on next layout
    }
    if (widget.preRenderedCount != oldWidget.preRenderedCount) {
      _preRenderedCount = widget.preRenderedCount.clamp(0, widget.referencePaths.length);
      _resetProgress();
    }
    if (!identical(widget.expectPaths, oldWidget.expectPaths)) {
      _rawExpectedPaths = widget.expectPaths ??
          widget.referencePaths.sublist(_preRenderedCount, widget.referencePaths.length);
      _resetProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_canvasSize != size) {
          _canvasSize = size;
          _updateScaledPaths(size);
        }

        return GestureDetector(
          onPanStart: (details) => _startStroke(details.localPosition),
          onPanUpdate: (details) => _extendStroke(details.localPosition),
          onPanEnd: (_) => _endStroke(),
          onPanCancel: _cancelStroke,
          child: CustomPaint(
            painter: HanziPainter(
              lines: _lines,
              strokeColor: widget.strokeColor,
              strokeWidth: widget.strokeWidth,
              referencePaths: _scaledReferencePaths,
              referenceBounds: _canvasSize == null
                  ? const Rect.fromLTWH(0, 0, 1, 1)
                  : Rect.fromLTWH(0, 0, _canvasSize!.width, _canvasSize!.height),
              preRenderedCount: _preRenderedCount,
              matchedCount: _matchedCount,
              showHint: _showHint,
              hintIndex: _matchedCount,
              pointerStart: _pointerStart,
              pointerDirection: _pointerDirection,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  void _startStroke(Offset point) {
    setState(() {
      _lines.add([point]);
    });
  }

  void _extendStroke(Offset point) {
    if (_lines.isEmpty) {
      return;
    }
    setState(() {
      final updated = List<Offset>.from(_lines.last)..add(point);
      _lines[_lines.length - 1] = updated;
    });
  }

  void _endStroke() {
    if (_lines.isEmpty) {
      return;
    }
    final current = _lines.last;
    if (current.length < 2) {
      _removeLastStroke();
      return;
    }
    if (_matchStroke(current)) {
      setState(() {
        _matchedCount += 1;
        widget.onStrokeMatched?.call(_matchedCount);
        _updatePointer();
      });
    } else {
      widget.onStrokeRejected?.call();
      _removeLastStroke();
    }
  }

  void _cancelStroke() {
    if (_lines.isEmpty) {
      return;
    }
    _removeLastStroke();
  }

  void _removeLastStroke() {
    setState(() {
      if (_lines.isNotEmpty) {
        _lines.removeLast();
      }
    });
  }

  void _resetProgress() {
    setState(() {
      _lines.clear();
      _matchedCount = 0;
      _updatePointer();
    });
  }

  void _updateScaledPaths(Size size) {
    if (widget.referencePaths.isEmpty) {
      _scaledReferencePaths = const [];
      _scaledExpectedPaths = const [];
      _pointerStart = null;
      _pointerDirection = null;
      return;
    }

    final bounds = widget.referenceBounds;
    final availableWidth = size.width * (1 - _paddingRatio);
    final availableHeight = size.height * (1 - _paddingRatio);
    final width = bounds.width == 0 ? 1.0 : bounds.width;
    final height = bounds.height == 0 ? 1.0 : bounds.height;
    final scale = math.min(availableWidth / width, availableHeight / height);
    final scaledWidth = width * scale;
    final scaledHeight = height * scale;
    final offsetX = (size.width - scaledWidth) / 2;
    final offsetY = (size.height - scaledHeight) / 2;

    final matrix = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale, scale)
      ..translate(-bounds.left, -bounds.top);

    _scaledReferencePaths = widget.referencePaths
        .map((path) => path.transform(matrix.storage))
        .toList(growable: false);

    _scaledExpectedPaths = _rawExpectedPaths
        .map((path) => path.transform(matrix.storage))
        .toList(growable: false);

    _updatePointer();
  }

  void _updatePointer() {
    if (_scaledExpectedPaths.isEmpty || _matchedCount >= _scaledExpectedPaths.length) {
      _pointerStart = null;
      _pointerDirection = null;
      return;
    }

    final metric = _firstMetric(_scaledExpectedPaths[_matchedCount]);
    if (metric == null || metric.length == 0) {
      _pointerStart = null;
      _pointerDirection = null;
      return;
    }

    final tangent = metric.getTangentForOffset(0);
    if (tangent == null) {
      _pointerStart = null;
      _pointerDirection = null;
      return;
    }

    _pointerStart = tangent.position;
    _pointerDirection = tangent.vector;
  }

  bool _matchStroke(List<Offset> stroke) {
    if (_scaledExpectedPaths.isEmpty || _matchedCount >= _scaledExpectedPaths.length) {
      return true;
    }

    final targetPath = _scaledExpectedPaths[_matchedCount];
    final metric = _firstMetric(targetPath);
    if (metric == null || metric.length == 0) {
      return false;
    }

    final expectedStart = metric.getTangentForOffset(0)?.position;
    final expectedEnd = metric.getTangentForOffset(metric.length)?.position;
    if (expectedStart == null || expectedEnd == null) {
      return false;
    }

    final userStart = stroke.first;
    final userEnd = stroke.last;

    final tolerance = (_canvasSize == null)
        ? 28.0
        : (_canvasSize!.shortestSide * 0.08).clamp(18.0, 36.0);

    if ((userStart - expectedStart).distance > tolerance * 1.5) {
      return false;
    }

    final userVector = userEnd - userStart;
    if (userVector.distance < 8) {
      return false;
    }

    final expectedVector = expectedEnd - expectedStart;
    final directionDot = (userVector.dx * expectedVector.dx) + (userVector.dy * expectedVector.dy);
    final directionNorm = userVector.distance * expectedVector.distance;
    if (directionNorm == 0) {
      return false;
    }
    final cosTheta = directionDot / directionNorm;
    if (cosTheta < 0.2) {
      return false;
    }

    final userSamples = _resamplePolyline(stroke, _samplePoints);
    final expectedSamples = _resamplePath(targetPath, _samplePoints);
    final distance = _averageBidirectionalDistance(userSamples, expectedSamples);
    return distance <= tolerance;
  }

  void setPreRendered(int count) {
    _preRenderedCount = count.clamp(0, widget.referencePaths.length);
    _rawExpectedPaths = widget.expectPaths ??
        widget.referencePaths.sublist(_preRenderedCount, widget.referencePaths.length);
    _resetProgress();
    if (_canvasSize != null) {
      _updateScaledPaths(_canvasSize!);
    }
  }

  void clearUserStrokes() {
    _resetProgress();
  }

  void replayHint() {
    if (_scaledExpectedPaths.isEmpty || _matchedCount >= _scaledExpectedPaths.length) {
      return;
    }
    setState(() {
      _showHint = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  bool get isComplete => _scaledExpectedPaths.isEmpty || _matchedCount >= _scaledExpectedPaths.length;

  int get matchedCount => _matchedCount;

  PathMetric? _firstMetric(Path path) {
    final iterator = path.computeMetrics().iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }

  List<Offset> _resamplePath(Path path, int sampleCount) {
    final metrics = path.computeMetrics();
    final segments = metrics.toList();
    if (segments.isEmpty) {
      return const [];
    }

    final totalLength = segments.fold<double>(0, (sum, metric) => sum + metric.length);
    final distanceStep = totalLength / (sampleCount - 1);
    final points = <Offset>[];
    var currentDistance = 0.0;
    for (var i = 0; i < sampleCount; i++) {
      final targetDistance = math.min(currentDistance, totalLength);
      var traversed = 0.0;
      for (final metric in segments) {
        if (traversed + metric.length >= targetDistance) {
          final tangent = metric.getTangentForOffset(targetDistance - traversed);
          if (tangent != null) {
            points.add(tangent.position);
          }
          break;
        }
        traversed += metric.length;
      }
      currentDistance += distanceStep;
    }
    return points;
  }

  List<Offset> _resamplePolyline(List<Offset> points, int sampleCount) {
    if (points.length <= 1) {
      return List<Offset>.from(points);
    }

    final distances = <double>[0];
    for (var i = 1; i < points.length; i++) {
      final segmentLength = (points[i] - points[i - 1]).distance;
      distances.add(distances.last + segmentLength);
    }

    final totalLength = distances.last;
    if (totalLength == 0) {
      return List<Offset>.filled(sampleCount, points.first);
    }

    final result = <Offset>[];
    final step = totalLength / (sampleCount - 1);
    var target = 0.0;
    var segmentIndex = 0;

    for (var i = 0; i < sampleCount; i++) {
      while (segmentIndex < distances.length - 1 && distances[segmentIndex + 1] < target) {
        segmentIndex++;
      }

      final start = points[segmentIndex];
      final end = points[segmentIndex + 1];
      final segmentStart = distances[segmentIndex];
      final segmentEnd = distances[segmentIndex + 1];
      final segmentLength = segmentEnd - segmentStart;
      final t = segmentLength == 0
          ? 0.0
          : ((target - segmentStart) / segmentLength).clamp(0.0, 1.0);
      result.add(Offset.lerp(start, end, t)!);
      target += step;
    }
    return result;
  }

  double _averageBidirectionalDistance(List<Offset> a, List<Offset> b) {
    if (a.isEmpty || b.isEmpty) {
      return double.infinity;
    }
    final forward = _averageMinDistance(a, b);
    final backward = _averageMinDistance(b, a);
    return (forward + backward) / 2;
  }

  double _averageMinDistance(List<Offset> from, List<Offset> to) {
    double sum = 0;
    for (final point in from) {
      var best = double.infinity;
      for (final candidate in to) {
        final distance = (point - candidate).distance;
        if (distance < best) {
          best = distance;
        }
      }
      sum += best;
    }
    return sum / from.length;
  }
}
