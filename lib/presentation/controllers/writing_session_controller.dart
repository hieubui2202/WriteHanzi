import 'dart:ui';

import 'package:get/get.dart';

import '../../core/utils/stroke_parser.dart';
import '../../domain/entities/stroke_data.dart';
import '../../core/utils/stroke_matcher.dart';

class WritingSessionController extends GetxController {
  WritingSessionController({this.tolerance = 0.25})
      : matcher = StrokeMatcher(tolerance: tolerance),
        parser = const StrokeParser();

  final double tolerance;
  final StrokeMatcher matcher;
  final StrokeParser parser;

  final RxList<List<Offset>> strokes = <List<Offset>>[].obs;
  final RxBool passed = false.obs;

  void start() {
    strokes.clear();
    strokes.refresh();
    passed.value = false;
  }

  void addPoint(Offset point) {
    if (strokes.isEmpty) {
      strokes.add([point]);
    } else {
      strokes.last.add(point);
    }
    strokes.refresh();
  }

  void startStroke(Offset point) {
    strokes.add([point]);
    strokes.refresh();
  }

  void endStroke() {}

  void undo() {
    if (strokes.isNotEmpty) {
      strokes.removeLast();
      strokes.refresh();
    }
  }

  void clear() {
    strokes.clear();
    strokes.refresh();
  }

  bool evaluateWith(StrokeData data) {
    final expected = data.paths
        .map((path) => parser.samplePath(parser.parseSvgPath(path)))
        .map((points) => points.map((point) => Offset(point.dx / data.width, point.dy / data.height)).toList())
        .toList();

    final actual = strokes
        .map((stroke) => stroke.map((point) => Offset(point.dx / data.width, point.dy / data.height)).toList())
        .toList();

    if (actual.length != expected.length) {
      passed.value = false;
      return false;
    }

    for (int i = 0; i < expected.length; i++) {
      if (!matcher.matches(expected[i], actual[i])) {
        passed.value = false;
        return false;
      }
    }
    passed.value = true;
    return true;
  }
}
