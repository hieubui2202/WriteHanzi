
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/drawing_provider.dart';

class WritingPad extends StatelessWidget {
  const WritingPad({super.key});

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);

    return GestureDetector(
      onPanStart: (details) {
        drawingProvider.startLine(details.localPosition);
      },
      onPanUpdate: (details) {
        drawingProvider.updateLine(details.localPosition);
      },
       onPanEnd: (details) {
        drawingProvider.endLine();
      },
      child: CustomPaint(
        painter: _WritingPainter(drawingProvider.lines),
        size: Size.infinite,
      ),
    );
  }
}

class _WritingPainter extends CustomPainter {
  final List<List<Offset?>> lines;

  _WritingPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        if (line[i] != null && line[i + 1] != null) {
          canvas.drawLine(line[i]!, line[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WritingPainter oldDelegate) {
    return oldDelegate.lines != lines;
  }
}
