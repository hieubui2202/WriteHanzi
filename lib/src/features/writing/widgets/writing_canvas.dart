import 'package:flutter/material.dart';

class WritingCanvas extends StatefulWidget {
  const WritingCanvas({super.key});

  @override
  State<WritingCanvas> createState() => _WritingCanvasState();
}

class _WritingCanvasState extends State<WritingCanvas> {
  List<List<Offset?>> _strokes = [];

  void _clearCanvas() {
    setState(() {
      _strokes = [];
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
        setState(() {
           _strokes.last.add(null); // End of a stroke
        });
      },
      child: CustomPaint(
        painter: _CanvasPainter(_strokes),
        child: Container(), // The canvas needs a size
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
        if (stroke[i] != null && stroke[i + 1] != null) {
          canvas.drawLine(stroke[i]!, stroke[i + 1]!, paint);
        } else if (stroke[i] != null && stroke[i + 1] == null) {
          canvas.drawPoints(PointMode.points, [stroke[i]!], paint..strokeWidth = 8.0 );
        } 
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
