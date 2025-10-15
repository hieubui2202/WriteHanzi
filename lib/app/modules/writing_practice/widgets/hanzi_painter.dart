
import 'dart:ui';
import 'package:flutter/material.dart';

// This CustomPainter is responsible for drawing the user's strokes on the canvas.
class HanziPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final Color strokeColor;
  final double strokeWidth;

  HanziPainter({
    required this.lines,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Iterate through each line (a list of points) and draw it.
    for (final line in lines) {
      if (line.length > 1) {
        for (int i = 0; i < line.length - 1; i++) {
          canvas.drawLine(line[i], line[i + 1], paint);
        }
      }
    }
  }

  // This painter should repaint whenever the lines, color, or width change.
  @override
  bool shouldRepaint(HanziPainter oldDelegate) {
    return oldDelegate.lines != lines ||
           oldDelegate.strokeColor != strokeColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
