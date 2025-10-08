
import 'package:flutter/material.dart';

class DrawingProvider with ChangeNotifier {
  final List<List<Offset?>> _lines = [];
  List<List<Offset?>> get lines => _lines;

  bool get hasStrokes => _lines.any((line) => line.isNotEmpty);
  bool get canUndo => _lines.isNotEmpty;

  void startLine(Offset startPoint) {
    _lines.add([startPoint]);
    notifyListeners();
  }

  void updateLine(Offset newPoint) {
    if (_lines.isNotEmpty) {
      _lines.last.add(newPoint);
      notifyListeners();
    }
  }

  void endLine() {
    if (_lines.isNotEmpty && _lines.last.isNotEmpty) {
      // Add a null to signify the end of a line segment
      _lines.last.add(null);
      notifyListeners();
    }
  }

  void undo() {
    if (canUndo) {
      _lines.removeLast();
      notifyListeners();
    }
  }

  void clear() {
    if (_lines.isNotEmpty) {
      _lines.clear();
      notifyListeners();
    }
  }
}
