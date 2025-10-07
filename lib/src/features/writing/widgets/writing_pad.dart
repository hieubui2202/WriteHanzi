
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/hanzi_character.dart';
import '../providers/drawing_provider.dart';

class WritingPad extends StatelessWidget {
  const WritingPad({
    super.key,
    required this.boardKey,
    required this.strokeData,
    required this.referenceStrokes,
    required this.showOutline,
    this.strokePreview,
  });

  final GlobalKey boardKey;
  final StrokeData strokeData;
  final List<List<Offset>> referenceStrokes;
  final bool showOutline;
  final Animation<double>? strokePreview;

  @override
  Widget build(BuildContext context) {
    final drawingProvider = context.watch<DrawingProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return RepaintBoundary(
          key: boardKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                ),
                CustomPaint(
                  painter: _CalligraphyGridPainter(),
                ),
                AnimatedOpacity(
                  opacity: showOutline ? 0.28 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomPaint(
                    painter: _StrokeOutlinePainter(
                      strokeData: strokeData,
                      referenceStrokes: referenceStrokes,
                    ),
                  ),
                ),
                GestureDetector(
                  onPanStart: (details) =>
                      drawingProvider.startStroke(details.localPosition),
                  onPanUpdate: (details) =>
                      drawingProvider.appendPoint(details.localPosition),
                  onPanEnd: (_) => drawingProvider.endStroke(),
                  child: CustomPaint(
                    painter: _WritingPainter(drawingProvider.strokes),
                  ),
                ),
                if (strokePreview != null)
                  IgnorePointer(
                    child: AnimatedBuilder(
                      animation: strokePreview!,
                      builder: (context, _) => CustomPaint(
                        painter: _StrokeOrderPainter(
                          strokeData: strokeData,
                          referenceStrokes: referenceStrokes,
                          progress: strokePreview!.value,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WritingPainter extends CustomPainter {
  _WritingPainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawPoints(
          ui.PointMode.points,
          stroke,
          paint,
        );
        continue;
      }

      for (var i = 0; i < stroke.length - 1; i++) {
        final current = stroke[i];
        final next = stroke[i + 1];
        canvas.drawLine(current, next, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WritingPainter oldDelegate) => true;
}

class _CalligraphyGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final step = size.width / 2;
    for (var i = 1; i < 2; i++) {
      final offset = i * step;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }

    final diagonalPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), diagonalPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), diagonalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StrokeOutlinePainter extends CustomPainter {
  _StrokeOutlinePainter({
    required this.strokeData,
    required this.referenceStrokes,
  });

  final StrokeData strokeData;
  final List<List<Offset>> referenceStrokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / strokeData.width;
    final scaleY = size.height / strokeData.height;

    for (final stroke in referenceStrokes) {
      final path = Path();
      for (var i = 0; i < stroke.length; i++) {
        final point = Offset(stroke[i].dx * scaleX, stroke[i].dy * scaleY);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StrokeOrderPainter extends CustomPainter {
  _StrokeOrderPainter({
    required this.strokeData,
    required this.referenceStrokes,
    required this.progress,
  });

  final StrokeData strokeData;
  final List<List<Offset>> referenceStrokes;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (referenceStrokes.isEmpty) {
      return;
    }

    final scaleX = size.width / strokeData.width;
    final scaleY = size.height / strokeData.height;

    final ghostPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.12)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final totalStrokes = referenceStrokes.length;
    final scaledProgress = (progress % 1.0) * totalStrokes;
    final activeIndex = scaledProgress.floor();
    final activeProgress = scaledProgress - activeIndex;

    for (var i = 0; i < referenceStrokes.length; i++) {
      final stroke = referenceStrokes[i]
          .map((offset) => Offset(offset.dx * scaleX, offset.dy * scaleY))
          .toList(growable: false);

      final path = Path();
      for (var j = 0; j < stroke.length; j++) {
        final point = stroke[j];
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(path, ghostPaint);

      if (i < activeIndex) {
        canvas.drawPath(path, activePaint);
        _drawStrokeIndex(canvas, stroke, i + 1, activePaint.color);
      } else if (i == activeIndex) {
        final partialPath = _buildPartialPath(stroke, activeProgress);
        canvas.drawPath(partialPath, activePaint);
        _drawStrokeIndex(canvas, stroke, i + 1, activePaint.color);
      }
    }
  }

  Path _buildPartialPath(List<Offset> stroke, double t) {
    final path = Path();
    if (stroke.isEmpty) return path;

    var remaining = t.clamp(0.0, 1.0);
    final totalLength = _strokeLength(stroke);
    var targetLength = remaining * totalLength;

    for (var i = 0; i < stroke.length; i++) {
      final current = stroke[i];
      if (i == 0) {
        path.moveTo(current.dx, current.dy);
        continue;
      }

      final previous = stroke[i - 1];
      final segment = (current - previous).distance;
      if (targetLength >= segment) {
        path.lineTo(current.dx, current.dy);
        targetLength -= segment;
      } else {
        final direction = (current - previous) / segment;
        final partialPoint = previous + direction * targetLength;
        path.lineTo(partialPoint.dx, partialPoint.dy);
        break;
      }
    }
    return path;
  }

  double _strokeLength(List<Offset> stroke) {
    var length = 0.0;
    for (var i = 1; i < stroke.length; i++) {
      length += (stroke[i] - stroke[i - 1]).distance;
    }
    return length;
  }

  void _drawStrokeIndex(Canvas canvas, List<Offset> stroke, int index, Color color) {
    if (stroke.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: index.toString(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final position = stroke.first - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _StrokeOrderPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.referenceStrokes != referenceStrokes;
}
