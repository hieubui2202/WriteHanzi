
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;

/// Custom painter responsible for showing the reference SVG strokes and the
/// learner's drawing.
class HanziPainter extends CustomPainter {
  HanziPainter({
    required this.lines,
    required this.strokeColor,
    required this.strokeWidth,
    required this.referencePaths,
    required this.referenceBounds,
  });

  final List<List<Offset>> lines;
  final Color strokeColor;
  final double strokeWidth;
  final List<Path> referencePaths;
  final Rect referenceBounds;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawReference(canvas, size);
    _drawUserLines(canvas);
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

  void _drawReference(Canvas canvas, Size size) {
    if (referencePaths.isEmpty) {
      return;
    }

    final paddingRatio = 0.1;
    final availableWidth = size.width * (1 - paddingRatio);
    final availableHeight = size.height * (1 - paddingRatio);

    final scaleX = availableWidth / referenceBounds.width;
    final scaleY = availableHeight / referenceBounds.height;
    final scale = math.min(scaleX, scaleY);

    final scaledWidth = referenceBounds.width * scale;
    final scaledHeight = referenceBounds.height * scale;

    final offsetX = (size.width - scaledWidth) / 2;
    final offsetY = (size.height - scaledHeight) / 2;

    final referencePaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 10;

    final scaleMatrix = Matrix4.diagonal3Values(scale, scale, 1).storage;
    final shiftOffset = Offset(offsetX, offsetY);

    for (final original in referencePaths) {
      final normalized = original.shift(-referenceBounds.topLeft);
      final scaled = normalized.transform(scaleMatrix);
      final translated = scaled.shift(shiftOffset);
      canvas.drawPath(translated, referencePaint);
    }
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

  @override
  bool shouldRepaint(HanziPainter oldDelegate) {
    return oldDelegate.lines != lines ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.referencePaths != referencePaths ||
        oldDelegate.referenceBounds != referenceBounds;
  }
}
