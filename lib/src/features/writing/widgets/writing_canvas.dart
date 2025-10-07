import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class WritingCanvas extends StatefulWidget {
  const WritingCanvas({super.key});

  @override
  WritingCanvasState createState() => WritingCanvasState();
}

class WritingCanvasState extends State<WritingCanvas> {
  final List<List<Offset?>> _strokes = [];

  List<List<Offset?>> get strokes =>
      _strokes.map((stroke) => List<Offset?>.from(stroke)).toList();

  void clearCanvas() {
    setState(() {
      _strokes.clear();
    });
  }

  void undoLastStroke() {
    if (_strokes.isEmpty) {
      return;
    }
    setState(() {
      _strokes.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _strokes.add([details.localPosition]);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _strokes.last.add(details.localPosition);
        });
      },
      onPanEnd: (details) {
        if (_strokes.isNotEmpty) {
          setState(() {
            _strokes.last.add(null);
          });
        }
      },
      child: CustomPaint(
        painter: _CanvasPainter(_strokes),
        child: Container(),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<List<Offset?>> strokes;

  _CanvasPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        final current = stroke[i];
        final next = stroke[i + 1];
        if (current != null && next != null) {
          canvas.drawLine(current, next, paint);
        } else if (current != null && next == null) {
          canvas.drawPoints(
            ui.PointMode.points,
            [current],
            paint..strokeWidth = 8.0,
          );
        }
      }
    }
  }

  @override
  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}
