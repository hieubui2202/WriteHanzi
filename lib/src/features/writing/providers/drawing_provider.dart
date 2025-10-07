
import 'package:flutter/material.dart';

class DrawingProvider with ChangeNotifier {
  final List<List<Offset>> _strokes = [];

  /// Returns a deep copy of the recorded strokes so external callers cannot
  /// mutate the internal state directly.
  List<List<Offset>> get strokes =>
      _strokes.map((stroke) => List<Offset>.from(stroke)).toList(growable: false);

  /// Number of completed strokes (with at least two points).
  int get completedStrokeCount =>
      _strokes.where((stroke) => stroke.length > 1).length;

  bool get hasInk =>
      _strokes.any((stroke) => stroke.length > 1);

  void startStroke(Offset startPoint) {
    _strokes.add([startPoint]);
    notifyListeners();
  }

  void appendPoint(Offset newPoint) {
    if (_strokes.isNotEmpty) {
      _strokes.last.add(newPoint);
      notifyListeners();
    }
  }

  void endStroke() {
    if (_strokes.isEmpty) {
      return;
    }

    if (_strokes.last.length < 2) {
      // Discard taps that did not result in an actual stroke.
      _strokes.removeLast();
    }
    notifyListeners();
  }

  void undo() {
    if (_strokes.isNotEmpty) {
      _strokes.removeLast();
      notifyListeners();
    }
  }

  void clear() {
    _strokes.clear();
    notifyListeners();
  }
}
