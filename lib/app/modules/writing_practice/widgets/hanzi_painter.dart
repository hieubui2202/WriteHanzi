
import 'dart:ui';

import 'package:flutter/material.dart';

/// Custom painter responsible for showing the reference SVG strokes and the
/// learner's drawing.
class HanziPainter extends CustomPainter {
  HanziPainter({
    required this.lines,
    required this.strokeColor,
    required this.strokeWidth,
    required this.referencePaths,
    required this.referenceBounds,
    this.preRenderedCount = 0,
    this.matchedCount = 0,
    this.showHint = false,
    this.hintIndex = 0,
    this.pointerStart,
    this.pointerDirection,
  });

  final List<List<Offset>> lines;
  final Color strokeColor;
  final double strokeWidth;
  final List<Path> referencePaths;
  final Rect referenceBounds;
  final int preRenderedCount;
  final int matchedCount;
  final bool showHint;
  final int hintIndex;
  final Offset? pointerStart;
  final Offset? pointerDirection;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawReference(canvas);
    _drawHint(canvas);
    _drawUserLines(canvas);
    _drawPointer(canvas);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final guidePaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..strokeWidth = 1;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, borderPaint);

    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height), guidePaint);
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), guidePaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), guidePaint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), guidePaint);
  }

  void _drawReference(Canvas canvas) {
    if (referencePaths.isEmpty) {
      return;
    }

    final faintPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 8;

    final solidPaint = Paint()
      ..color = Colors.black.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 9;

    final completedLimit = (preRenderedCount + matchedCount).clamp(0, referencePaths.length);

    for (var index = 0; index < referencePaths.length; index++) {
      final paint = index < completedLimit ? solidPaint : faintPaint;
      canvas.drawPath(referencePaths[index], paint);
    }
  }

  void _drawHint(Canvas canvas) {
    if (!showHint) {
      return;
    }
    final targetIndex = (preRenderedCount + hintIndex).clamp(0, referencePaths.length - 1);
    if (referencePaths.isEmpty || targetIndex >= referencePaths.length) {
      return;
    }

    final hintPaint = Paint()
      ..color = Colors.lightBlueAccent.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth + 2;

    canvas.drawPath(referencePaths[targetIndex], hintPaint);
  }

  void _drawUserLines(Canvas canvas) {
    if (lines.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;

    for (final line in lines) {
      if (line.length < 2) {
        continue;
      }
      for (var i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  void _drawPointer(Canvas canvas) {
    if (pointerStart == null || pointerDirection == null) {
      return;
    }

    final circlePaint = Paint()
      ..color = const Color(0xFF1FD77C)
      ..style = PaintingStyle.fill;

    final arrowPaint = Paint()
      ..color = const Color(0xFF1FD77C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pointerStart!, 9, circlePaint);

    final direction = pointerDirection!;
    if (direction.distanceSquared == 0) {
      return;
    }

    final norm = direction.distance;
    final unit = Offset(direction.dx / norm, direction.dy / norm);
    final arrowTip = pointerStart! + unit * 28;
    final perp = Offset(-unit.dy, unit.dx);
    final wing = 7.0;
    final path = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowTip.dx - unit.dx * 12 + perp.dx * wing,
          arrowTip.dy - unit.dy * 12 + perp.dy * wing)
      ..lineTo(arrowTip.dx - unit.dx * 12 - perp.dx * wing,
          arrowTip.dy - unit.dy * 12 - perp.dy * wing)
      ..close();
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(HanziPainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.referencePaths != referencePaths ||
        oldDelegate.referenceBounds != referenceBounds ||
        oldDelegate.preRenderedCount != preRenderedCount ||
        oldDelegate.matchedCount != matchedCount ||
        oldDelegate.showHint != showHint ||
        oldDelegate.hintIndex != hintIndex ||
        oldDelegate.pointerStart != pointerStart ||
        oldDelegate.pointerDirection != pointerDirection;
  }
}
