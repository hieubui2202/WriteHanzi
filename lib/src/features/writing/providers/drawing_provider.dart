
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

class DrawingProvider with ChangeNotifier {
  final List<List<Offset?>> _lines = [];
  List<List<Offset?>> get lines => _lines;

  List<Path> _referencePaths = const [];
  List<List<Offset>> _referenceSamples = const [];
  List<double> _referenceLengths = const [];
  List<double> _strokeProgress = const [];
  List<String> _pathData = const [];
  Size? _viewBox;
  Size? _canvasSize;
  int _currentStrokeIndex = 0;
  double _currentStrokeDrawn = 0;

  List<Path> get referencePaths => _referencePaths;
  List<double> get strokeProgress => _strokeProgress;

  bool get hasStrokes => _lines.any((line) => line.isNotEmpty);
  bool get canUndo => _lines.isNotEmpty;
  bool get isConfigured => _referencePaths.isNotEmpty;

  void syncReference({
    required List<String> pathData,
    required Size viewBox,
    required Size canvasSize,
  }) {
    final hasPathChanged = !listEquals(_pathData, pathData);
    final hasViewBoxChanged = _viewBox != viewBox;
    final hasSizeChanged = _canvasSize != canvasSize;

    if (!hasPathChanged && !hasSizeChanged && !hasViewBoxChanged) {
      return;
    }

    _pathData = List.unmodifiable(pathData);
    _viewBox = viewBox;
    _canvasSize = canvasSize;
    _lines.clear();
    _currentStrokeIndex = 0;
    _currentStrokeDrawn = 0;

    if (pathData.isEmpty || viewBox.width == 0 || viewBox.height == 0) {
      _referencePaths = const [];
      _referenceSamples = const [];
      _referenceLengths = const [];
      _strokeProgress = const [];
      notifyListeners();
      return;
    }

    final scale = math.min(
      canvasSize.width / viewBox.width,
      canvasSize.height / viewBox.height,
    );
    final dx = (canvasSize.width - (viewBox.width * scale)) / 2;
    final dy = (canvasSize.height - (viewBox.height * scale)) / 2;

    final scaleMatrix = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(scale, scale);

    _referencePaths = pathData
        .map((raw) => parseSvgPathData(raw).transform(scaleMatrix.storage))
        .toList(growable: false);

    _referenceLengths = _referencePaths
        .map(
          (path) => path
              .computeMetrics()
              .fold<double>(0, (value, metric) => value + metric.length),
        )
        .toList(growable: false);

    _referenceSamples = _referencePaths
        .map((path) {
          final metrics = path.computeMetrics().toList(growable: false);
          final samples = <Offset>[];
          for (final metric in metrics) {
            final length = metric.length;
            final steps = math.max(24, (length / 4).round());
            for (int i = 0; i <= steps; i++) {
              final distance = (i / steps) * length;
              final tangent = metric.getTangentForOffset(distance);
              if (tangent != null) {
                samples.add(tangent.position);
              }
            }
          }

          if (samples.isEmpty && metrics.isNotEmpty) {
            final tangent = metrics.first.getTangentForOffset(0);
            if (tangent != null) {
              samples.add(tangent.position);
            }
          }

          return samples.isEmpty ? const <Offset>[] : List<Offset>.from(samples);
        })
        .toList(growable: false);

    _strokeProgress = List<double>.filled(_referencePaths.length, 0);
    notifyListeners();
  }

  void startLine(Offset startPoint) {
    if (_referencePaths.isNotEmpty) {
      final nextStroke = _strokeProgress.indexWhere((value) => value < 1.0);
      _currentStrokeIndex = nextStroke == -1 ? _strokeProgress.length - 1 : nextStroke;
      if (_currentStrokeIndex >= 0 &&
          _currentStrokeIndex < _referenceLengths.length &&
          _currentStrokeIndex < _strokeProgress.length) {
        final seededProgress = _strokeProgress[_currentStrokeIndex].clamp(0.0, 1.0);
        _currentStrokeDrawn = _referenceLengths[_currentStrokeIndex] * seededProgress;
      } else {
        _currentStrokeDrawn = 0;
      }
    }

    _lines.add([startPoint]);
    notifyListeners();
  }

  void updateLine(Offset newPoint) {
    if (_lines.isEmpty) {
      return;
    }

    final currentLine = _lines.last;
    final Offset? previousPoint = currentLine.isNotEmpty ? currentLine.last : null;
    currentLine.add(newPoint);

    if (previousPoint != null &&
        _referenceSamples.isNotEmpty &&
        _currentStrokeIndex >= 0 &&
        _currentStrokeIndex < _referenceSamples.length) {
      final projection = _projectOntoStroke(newPoint, _currentStrokeIndex);
      if (projection != null) {
        final tolerance = _hitTolerance();
        if (projection.distance <= tolerance) {
          final existing = _strokeProgress[_currentStrokeIndex];
          final updated = math.max(existing, projection.progress);
          if (!updated.isNaN && updated > existing + 0.001) {
            _strokeProgress[_currentStrokeIndex] = updated.clamp(0.0, 1.0);
          }
        }
      }
    }

    notifyListeners();
  }

  void endLine() {
    if (_lines.isEmpty || _lines.last.isEmpty) {
      return;
    }

    var shouldRemoveLine = false;

    if (_strokeProgress.isNotEmpty &&
        _currentStrokeIndex >= 0 &&
        _currentStrokeIndex < _strokeProgress.length) {
      if (_strokeProgress[_currentStrokeIndex] >= 0.9) {
        _strokeProgress[_currentStrokeIndex] = 1.0;
        shouldRemoveLine = true;
      }

      _currentStrokeDrawn = 0;
      final nextStroke = _strokeProgress.indexWhere((value) => value < 1.0);
      _currentStrokeIndex = nextStroke == -1 ? _strokeProgress.length - 1 : nextStroke;
    }

    if (shouldRemoveLine) {
      _lines.removeLast();
    } else {
      _lines.last.add(null);
    }

    notifyListeners();
  }

  void undo() {
    if (!canUndo) {
      return;
    }

    _lines.removeLast();

    if (_strokeProgress.isNotEmpty) {
      int targetIndex = -1;
      for (int i = _strokeProgress.length - 1; i >= 0; i--) {
        if (_strokeProgress[i] > 0) {
          targetIndex = i;
          break;
        }
      }

      if (targetIndex != -1) {
        _strokeProgress[targetIndex] = 0;
        _currentStrokeIndex = targetIndex;
      } else {
        _currentStrokeIndex = 0;
      }
    }

    _currentStrokeDrawn = 0;
    notifyListeners();
  }

  void clear() {
    if (_lines.isEmpty && _strokeProgress.every((value) => value == 0)) {
      return;
    }

    _lines.clear();
    if (_strokeProgress.isNotEmpty) {
      _strokeProgress = List<double>.filled(_strokeProgress.length, 0);
    }
    _currentStrokeIndex = 0;
    _currentStrokeDrawn = 0;
    notifyListeners();
  }

  _StrokeProjection? _projectOntoStroke(Offset point, int strokeIndex) {
    if (strokeIndex < 0 || strokeIndex >= _referenceSamples.length) {
      return null;
    }

    final samples = _referenceSamples[strokeIndex];
    if (samples.isEmpty) {
      return null;
    }

    double bestDistance = double.infinity;
    int bestIndex = 0;
    for (var i = 0; i < samples.length; i++) {
      final distance = (samples[i] - point).distance;
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }

    final progress = samples.length == 1
        ? 1.0
        : bestIndex / math.max(1, samples.length - 1);

    return _StrokeProjection(progress: progress.clamp(0.0, 1.0), distance: bestDistance);
  }

  double _hitTolerance() {
    if (_canvasSize == null) {
      return 24;
    }
    final shortest = _canvasSize!.shortestSide;
    return (shortest * 0.08).clamp(16.0, 36.0);
  }
}

class _StrokeProjection {
  const _StrokeProjection({required this.progress, required this.distance});

  final double progress;
  final double distance;
}
