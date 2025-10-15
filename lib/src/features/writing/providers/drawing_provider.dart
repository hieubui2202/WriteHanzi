import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

import '../../../models/hanzi_character.dart';

class DrawingProvider with ChangeNotifier {
  DrawingProvider({
    required StrokeData strokeData,
    double toleranceFactor = 0.12,
  })  : _strokeData = strokeData,
        _toleranceFactor = toleranceFactor {
    _parseReferenceStrokes();
  }

  final StrokeData _strokeData;
  final double _toleranceFactor;

  final List<Path> _normalizedPaths = [];
  final List<List<Offset>> _normalizedSamples = [];
  final List<Path> _scaledPaths = [];
  final List<List<Offset>> _scaledSamples = [];
  final List<List<bool>> _sampleHits = [];
  final List<double> _strokeProgress = [];
  final List<List<Offset>> _userStrokes = [];

  Size? _canvasSize;
  double _tolerance = 0;
  int _currentStrokeIndex = 0;
  bool _isDrawing = false;

  void _parseReferenceStrokes() {
    final width = _strokeData.width == 0 ? 1.0 : _strokeData.width.toDouble();
    final height = _strokeData.height == 0 ? 1.0 : _strokeData.height.toDouble();
    final scaleMatrix = Matrix4.identity()
      ..scale(1 / width, 1 / height);

    for (final raw in _strokeData.paths) {
      if (raw.trim().isEmpty) {
        continue;
      }

      final path = parseSvgPathData(raw).transform(scaleMatrix.storage);
      _normalizedPaths.add(path);
      _normalizedSamples.add(_samplePath(path));
      _strokeProgress.add(0);
    }
  }

  void updateCanvasSize(Size size) {
    if (size.isEmpty) return;
    if (_canvasSize != null &&
        (_canvasSize!.width - size.width).abs() < 0.5 &&
        (_canvasSize!.height - size.height).abs() < 0.5) {
      return;
    }

    final previousCompleted =
        List<bool>.generate(_strokeProgress.length, (i) => _strokeProgress[i] >= 1);

    _canvasSize = size;
    _scaledPaths.clear();
    _scaledSamples.clear();
    _sampleHits.clear();

    final side = math.min(size.width, size.height);
    final padding = side * 0.08;
    final scale = side - (padding * 2);
    final offset = Offset(
      (size.width - scale) / 2,
      (size.height - scale) / 2,
    );

    final transform = Matrix4.identity()..scale(scale, scale);

    for (var i = 0; i < _normalizedPaths.length; i++) {
      final path = _normalizedPaths[i]
          .transform(transform.storage)
          .shift(offset);
      _scaledPaths.add(path);

      final samples = _normalizedSamples[i]
          .map((point) => Offset(
                point.dx * scale + offset.dx,
                point.dy * scale + offset.dy,
              ))
          .toList();
      _scaledSamples.add(samples);
      _sampleHits.add(List<bool>.filled(samples.length, false));
    }

    _tolerance = scale * _toleranceFactor;
    _userStrokes.clear();
    _isDrawing = false;

    for (var i = 0; i < _sampleHits.length; i++) {
      _strokeProgress[i] = i < previousCompleted.length && previousCompleted[i]
          ? 1.0
          : 0.0;
      _sampleHits[i] = List<bool>.filled(_sampleHits[i].length, false);
    }

    var preservedIndex =
        previousCompleted.indexWhere((completed) => !completed);
    if (preservedIndex == -1) {
      preservedIndex = _sampleHits.length;
    }
    _currentStrokeIndex = preservedIndex.clamp(0, _sampleHits.length);
    notifyListeners();
  }

  bool get ready => _scaledPaths.isNotEmpty;

  List<Path> get guidePaths => List.unmodifiable(_scaledPaths);
  List<double> get strokeProgress => List.unmodifiable(_strokeProgress);
  List<List<Offset>> get activeUserStrokes => List.unmodifiable(_userStrokes);
  int get totalStrokes => _scaledPaths.length;
  int get currentStrokeIndex => _currentStrokeIndex;
  bool get isComplete => totalStrokes > 0 && _currentStrokeIndex >= totalStrokes;
  bool get canUndo => _isDrawing || _currentStrokeIndex > 0;
  bool get canClear =>
      _isDrawing || _strokeProgress.any((progress) => progress > 0);

  void startLine(Offset startPoint) {
    if (!ready || isComplete) return;
    _isDrawing = true;
    _userStrokes.add([startPoint]);
    _resetCurrentStrokeHits();
    notifyListeners();
  }

  void updateLine(Offset newPoint) {
    if (!_isDrawing || _userStrokes.isEmpty) return;
    _userStrokes.last.add(newPoint);
    _updateCoverage();
    notifyListeners();
  }

  bool endLine() {
    if (!_isDrawing || _userStrokes.isEmpty) {
      return false;
    }

    _isDrawing = false;
    final idx = _currentStrokeIndex;
    final stroke = _userStrokes.removeLast();
    if (idx >= _scaledSamples.length) {
      notifyListeners();
      return false;
    }

    final hits = _sampleHits[idx];
    final coverage = hits.where((hit) => hit).length / hits.length;

    final samples = _scaledSamples[idx];
    final startOk = stroke.isNotEmpty &&
        (stroke.first - samples.first).distance <= _tolerance * 1.2;
    final endOk = stroke.isNotEmpty &&
        (stroke.last - samples.last).distance <= _tolerance * 1.2;

    final success = coverage >= 0.7 && startOk && endOk;

    if (success) {
      _strokeProgress[idx] = 1.0;
      _currentStrokeIndex = math.min(idx + 1, totalStrokes);
      notifyListeners();
      return true;
    } else {
      _resetCurrentStrokeHits();
      notifyListeners();
      return false;
    }
  }

  void undo() {
    if (_isDrawing && _userStrokes.isNotEmpty) {
      _isDrawing = false;
      _userStrokes.removeLast();
      _resetCurrentStrokeHits();
      notifyListeners();
      return;
    }

    if (_currentStrokeIndex <= 0) {
      return;
    }

    final idx = _currentStrokeIndex - 1;
    _currentStrokeIndex = idx;
    _strokeProgress[idx] = 0;
    _resetHits(idx);
    notifyListeners();
  }

  void clear() {
    _userStrokes.clear();
    _currentStrokeIndex = 0;
    for (var i = 0; i < _sampleHits.length; i++) {
      _resetHits(i);
      _strokeProgress[i] = 0;
    }
    _isDrawing = false;
    notifyListeners();
  }

  double get completionRatio {
    if (totalStrokes == 0) return 0;
    final mastered =
        _strokeProgress.take(totalStrokes).where((value) => value >= 1).length;
    return mastered / totalStrokes;
  }

  List<Offset> _samplePath(Path path, {int sampleCount = 160}) {
    final samples = <Offset>[];
    final metrics = path.computeMetrics();
    double totalLength = 0;
    for (final metric in metrics) {
      totalLength += metric.length;
    }
    if (totalLength == 0) {
      return samples;
    }

    for (final metric in path.computeMetrics()) {
      final segmentFraction = metric.length / totalLength;
      final count = math.max(2, (sampleCount * segmentFraction).round());
      for (var i = 0; i < count; i++) {
        final t = metric.length * (i / (count - 1));
        final tangent = metric.getTangentForOffset(t);
        if (tangent != null) {
          samples.add(tangent.position);
        }
      }
    }
    return samples;
  }

  bool _updateCoverage() {
    final idx = _currentStrokeIndex;
    if (idx >= _scaledSamples.length || _userStrokes.isEmpty) {
      return false;
    }

    final stroke = _userStrokes.last;
    if (stroke.length < 2) {
      return false;
    }

    final samples = _scaledSamples[idx];
    final hits = _sampleHits[idx];
    var changed = false;

    for (var i = 0; i < samples.length; i++) {
      if (hits[i]) continue;
      final distance = _distanceToPolyline(samples[i], stroke);
      if (distance <= _tolerance) {
        hits[i] = true;
        changed = true;
      }
    }

    if (changed) {
      var prefixHits = 0;
      for (var i = 0; i < hits.length; i++) {
        if (!hits[i]) {
          break;
        }
        prefixHits++;
      }

      _strokeProgress[idx] = prefixHits / hits.length;
    }

    return changed;
  }

  void _resetCurrentStrokeHits() {
    final idx = math.min(_currentStrokeIndex, _sampleHits.length - 1);
    if (idx >= 0 && idx < _sampleHits.length) {
      _resetHits(idx);
      _strokeProgress[idx] = 0;
    }
  }

  void _resetHits(int idx) {
    if (idx < 0 || idx >= _sampleHits.length) return;
    _sampleHits[idx] = List<bool>.filled(_sampleHits[idx].length, false);
  }

  double _distanceToPolyline(Offset point, List<Offset> polyline) {
    var minDistance = double.infinity;
    for (var i = 0; i < polyline.length - 1; i++) {
      final segmentStart = polyline[i];
      final segmentEnd = polyline[i + 1];
      final distance = _distanceToSegment(point, segmentStart, segmentEnd);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance;
  }

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final abSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abSquared == 0) {
      return (p - a).distance;
    }
    var t = (ap.dx * ab.dx + ap.dy * ab.dy) / abSquared;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - projection).distance;
  }
}
