import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

import 'package:myapp/core/stroke_engine.dart';

enum HanziCanvasMode { animate, practice }

class HanziStrokeCanvas extends StatefulWidget {
  const HanziStrokeCanvas({
    super.key,
    required this.svgList,
    this.mode = HanziCanvasMode.practice,
    this.preRenderedCount = 0,
    this.expectPaths,
    this.onStrokeMatched,
    this.onStrokeRejected,
  });

  final List<String> svgList;
  final HanziCanvasMode mode;
  final int preRenderedCount;
  final List<int>? expectPaths;
  final ValueChanged<int>? onStrokeMatched;
  final VoidCallback? onStrokeRejected;

  @override
  HanziStrokeCanvasState createState() => HanziStrokeCanvasState();
}

class HanziStrokeCanvasState extends State<HanziStrokeCanvas> {
  final StrokeEngine _engine = StrokeEngine();

  late List<Path> _paths;
  late Set<int> _matched;
  late int _preRenderedCount;
  late List<int> _expectedOrder;

  List<Offset> _activeStroke = [];

  Timer? _replayTimer;
  bool _isReplaying = false;
  double _replayProgress = 0;
  int _replayStroke = 0;

  Timer? _hintTimer;
  int? _hintStroke;

  final Map<int, DateTime> _highlights = {};

  @override
  void initState() {
    super.initState();
    _initializeFromWidget();
  }

  @override
  void didUpdateWidget(covariant HanziStrokeCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.svgList != widget.svgList) {
      _initializeFromWidget();
    } else if (oldWidget.preRenderedCount != widget.preRenderedCount ||
        oldWidget.expectPaths != widget.expectPaths) {
      _configureExpectations();
    }
  }

  void _initializeFromWidget() {
    _hintTimer?.cancel();
    _hintStroke = null;

    final parsed = widget.svgList.map(_engine.parse).toList(growable: false);
    if (parsed.isEmpty) {
      _paths = List<Path>.empty(growable: false);
    } else {
      Rect bounds = parsed.first.getBounds();
      for (final path in parsed.skip(1)) {
        bounds = bounds.expandToInclude(path.getBounds());
      }
      final width = bounds.width;
      final height = bounds.height;
      final largestSide = math.max(width, height);
      final scale = largestSide == 0 ? 1.0 : 1 / largestSide;
      final dx = (1 - width * scale) / 2;
      final dy = (1 - height * scale) / 2;
      _paths = parsed
          .map(
            (path) => path
                .shift(Offset(-bounds.left, -bounds.top))
                .transform((vmath.Matrix4.identity()..scale(scale, scale)).storage)
                .shift(Offset(dx, dy)),
          )
          .toList(growable: false);
    }
    _preRenderedCount = widget.preRenderedCount.clamp(0, _paths.length);
    _matched = <int>{};
    for (int i = 0; i < _preRenderedCount; i++) {
      _matched.add(i);
    }
    _activeStroke = [];
    _configureExpectations();
  }

  void _configureExpectations() {
    if (widget.expectPaths != null && widget.expectPaths!.isNotEmpty) {
      _expectedOrder = widget.expectPaths!
          .where((index) => index >= 0 && index < _paths.length)
          .toList(growable: false);
    } else {
      _expectedOrder = List<int>.generate(_paths.length, (index) => index);
    }
    setState(() {
      _matched.removeWhere((index) => index >= _paths.length);
      for (int i = 0; i < _preRenderedCount; i++) {
        _matched.add(i);
      }
      if (_hintStroke != null && (_hintStroke! < 0 || _hintStroke! >= _paths.length)) {
        _hintStroke = null;
      }
    });
  }

  int? get _nextExpectedIndex {
    for (final index in _expectedOrder) {
      if (!_matched.contains(index)) {
        return index;
      }
    }
    return null;
  }

  Offset? get _pointerHint {
    final target = _nextExpectedIndex;
    if (target == null || target >= _paths.length) {
      return null;
    }
    final metricIterator = _paths[target].computeMetrics().iterator;
    if (!metricIterator.moveNext()) {
      return null;
    }
    return metricIterator.current.getTangentForOffset(0)?.position;
  }

  void replay() {
    _replayTimer?.cancel();
    _hintTimer?.cancel();
    _hintStroke = null;
    setState(() {
      _isReplaying = true;
      _replayStroke = 0;
      _replayProgress = 0;
    });
    _replayTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _replayProgress += 0.03;
        if (_replayProgress >= 1) {
          _replayProgress = 0;
          _replayStroke += 1;
          if (_replayStroke >= _paths.length) {
            _isReplaying = false;
            timer.cancel();
          }
        }
      });
    });
  }

  void clear() {
    setState(() {
      _activeStroke = [];
      _matched = _matched.where((index) => index < _preRenderedCount).toSet();
      for (int i = 0; i < _preRenderedCount; i++) {
        _matched.add(i);
      }
      _hintTimer?.cancel();
      _hintStroke = null;
    });
  }

  void setPreRendered(int count) {
    setState(() {
      _preRenderedCount = count.clamp(0, _paths.length);
      _matched = _matched.where((index) => index < _preRenderedCount).toSet();
      for (int i = 0; i < _preRenderedCount; i++) {
        _matched.add(i);
      }
      _hintTimer?.cancel();
      _hintStroke = null;
    });
  }

  void showHint({bool hold = false}) {
    final index = _nextExpectedIndex;
    if (index == null) {
      return;
    }
    _hintTimer?.cancel();
    setState(() {
      _hintStroke = index;
    });
    if (!hold) {
      _hintTimer = Timer(const Duration(milliseconds: 1600), () {
        if (!mounted) {
          return;
        }
        if (_matched.contains(index)) {
          return;
        }
        setState(() {
          if (_hintStroke == index) {
            _hintStroke = null;
          }
        });
      });
    }
  }

  bool get isComplete => _expectedOrder.every(_matched.contains);
  int get matchedCount => (_matched.length - _preRenderedCount).clamp(0, _paths.length);

  @override
  void dispose() {
    _replayTimer?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details, BoxConstraints constraints) {
    if (widget.mode == HanziCanvasMode.animate) {
      return;
    }
    if (_nextExpectedIndex == null) {
      return;
    }
    final offset = _mapToUnitSquare(details.localPosition, constraints.biggest);
    setState(() {
      _activeStroke = [offset];
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    if (_activeStroke.isEmpty) {
      return;
    }
    final offset = _mapToUnitSquare(details.localPosition, constraints.biggest);
    setState(() {
      _activeStroke = List.of(_activeStroke)..add(offset);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_activeStroke.length < 2) {
      setState(() {
        _activeStroke = [];
      });
      return;
    }
    final targetIndex = _nextExpectedIndex;
    if (targetIndex == null) {
      setState(() {
        _activeStroke = [];
      });
      return;
    }
    final standard = _paths[targetIndex];
    final normalizedUser = List<Offset>.from(_activeStroke);
    final standardResampled = _engine.samplePath(standard);
    final userResampled = _engine.resamplePoints(normalizedUser);
    final match =
        _engine.dtwDistance(userResampled, standardResampled) <= _engine.tolerance;
    if (match) {
      setState(() {
        _matched.add(targetIndex);
        _hintTimer?.cancel();
        _hintStroke = null;
        _highlights[targetIndex] = DateTime.now();
        _activeStroke = [];
      });
      widget.onStrokeMatched?.call(targetIndex);
    } else {
      setState(() {
        _activeStroke = [];
      });
      widget.onStrokeRejected?.call();
    }
  }

  Offset _mapToUnitSquare(Offset input, Size size) {
    final dx = (input.dx / size.width).clamp(0.0, 1.0);
    final dy = (input.dy / size.height).clamp(0.0, 1.0);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: showHint,
          onDoubleTap: replay,
          onPanStart: (details) => _handlePanStart(details, constraints),
          onPanUpdate: (details) => _handlePanUpdate(details, constraints),
          onPanEnd: _handlePanEnd,
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _HanziCanvasPainter(
                paths: _paths,
                matched: _matched,
                activeStroke: _activeStroke,
                pointer: _pointerHint,
                highlights: _highlights,
                replayStroke: _isReplaying ? _replayStroke : null,
                replayProgress: _replayProgress,
                preRenderedCount: _preRenderedCount,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HanziCanvasPainter extends CustomPainter {
  _HanziCanvasPainter({
    required this.paths,
    required this.matched,
    required this.activeStroke,
    required this.pointer,
    required this.highlights,
    required this.replayStroke,
    required this.replayProgress,
    required this.preRenderedCount,
  });

  final List<Path> paths;
  final Set<int> matched;
  final List<Offset> activeStroke;
  final Offset? pointer;
  final Map<int, DateTime> highlights;
  final int? replayStroke;
  final double replayProgress;
  final int preRenderedCount;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawStandard(canvas, size);
    _drawHighlights(canvas, size);
    _drawPointer(canvas, size);
    _drawActiveStroke(canvas, size);
    _drawReplay(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF141922);
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), gridPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), gridPaint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), gridPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), gridPaint);
  }

  void _drawStandard(Canvas canvas, Size size) {
    if (_hintStroke == null) {
      return;
    }
    final index = _hintStroke!;
    if (index < 0 || index >= paths.length || matched.contains(index)) {
      return;
    }
    final ghostPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final matrix = vmath.Matrix4.identity()..scale(size.width, size.height);
    final transformed = paths[index].transform(matrix.storage);
    final dashed = dashPath(transformed, dashArray: CircularIntervalList<double>(const <double>[10, 10]));
    canvas.drawPath(dashed, ghostPaint);
  }

  void _drawHighlights(Canvas canvas, Size size) {
    final now = DateTime.now();
    for (final entry in highlights.entries) {
      final age = now.difference(entry.value).inMilliseconds;
      if (age > 450) {
        continue;
      }
      final t = 1 - (age / 450);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 18
        ..color = const Color(0xFF18E06F).withOpacity(0.35 * t);
      final scale = vmath.Matrix4.identity()..scale(size.width, size.height);
      canvas.drawPath(paths[entry.key].transform(scale.storage), paint);
    }

    final solidPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 12
      ..color = Colors.white;
    final scale = vmath.Matrix4.identity()..scale(size.width, size.height);
    for (int i = 0; i < paths.length; i++) {
      if (!matched.contains(i)) {
        continue;
      }
      canvas.drawPath(paths[i].transform(scale.storage), solidPaint);
    }
  }

  void _drawActiveStroke(Canvas canvas, Size size) {
    if (activeStroke.isEmpty) {
      return;
    }
    final path = Path();
    for (int i = 0; i < activeStroke.length; i++) {
      final p = _denormalize(activeStroke[i], size);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 10
      ..color = Colors.cyanAccent.withOpacity(0.9);
    canvas.drawPath(path, paint);
  }

  void _drawPointer(Canvas canvas, Size size) {
    if (pointer == null) {
      return;
    }
    final pos = _denormalize(pointer!, size);
    final circlePaint = Paint()..color = const Color(0xFF18E06F);
    canvas.drawCircle(pos, 10, circlePaint);
    final arrowPaint = Paint()
      ..color = const Color(0xFF18E06F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(pos, pos + const Offset(24, -12), arrowPaint);
    canvas.drawLine(pos, pos + const Offset(24, 12), arrowPaint);
  }

  void _drawReplay(Canvas canvas, Size size) {
    if (replayStroke == null || replayStroke! >= paths.length) {
      return;
    }
    final iterator = paths[replayStroke!].computeMetrics().iterator;
    if (!iterator.moveNext()) {
      return;
    }
    final metric = iterator.current;
    final length = metric.length;
    final preview = metric.extractPath(0, length * replayProgress.clamp(0, 1));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 12
      ..color = Colors.white.withOpacity(0.9);
    final scale = vmath.Matrix4.identity()..scale(size.width, size.height);
    canvas.drawPath(preview.transform(scale.storage), paint);
  }

  Offset _denormalize(Offset offset, Size size) {
    return Offset(offset.dx * size.width, offset.dy * size.height);
  }

  @override
  bool shouldRepaint(covariant _HanziCanvasPainter oldDelegate) {
    return true;
  }
}
