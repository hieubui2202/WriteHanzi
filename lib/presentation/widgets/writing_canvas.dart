import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/stroke_data.dart';
import '../controllers/writing_session_controller.dart';

class WritingCanvas extends StatefulWidget {
  const WritingCanvas({super.key, required this.strokeData});

  final StrokeData strokeData;

  @override
  State<WritingCanvas> createState() => _WritingCanvasState();
}

class _WritingCanvasState extends State<WritingCanvas> {
  late final WritingSessionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WritingSessionController>();
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        final canvasSize = Size.square(size);
        return GestureDetector(
          onPanStart: (details) => controller.startStroke(_toStrokeSpace(details.localPosition, canvasSize)),
          onPanUpdate: (details) => controller.addPoint(_toStrokeSpace(details.localPosition, canvasSize)),
          onPanEnd: (_) => controller.endStroke(),
          child: Center(
            child: SizedBox(
              width: canvasSize.width,
              height: canvasSize.height,
              child: CustomPaint(
                painter: _WritingPainter(
                  strokes: controller.strokes,
                  strokeData: widget.strokeData,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _toStrokeSpace(Offset position, Size size) {
    final scaleX = widget.strokeData.width / size.width;
    final scaleY = widget.strokeData.height / size.height;
    return Offset(position.dx * scaleX, position.dy * scaleY);
  }
}

class _WritingPainter extends CustomPainter {
  _WritingPainter({required this.strokes, required this.strokeData});

  final List<List<Offset>> strokes;
  final StrokeData strokeData;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      bg,
    );

    final gridPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final pathPaint = Paint()
      ..color = const Color(0xFF00CFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final cellSize = size.width / 4;
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(Offset(i * cellSize, 0), Offset(i * cellSize, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * cellSize), Offset(size.width, i * cellSize), gridPaint);
    }

    final scaleX = size.width / strokeData.width;
    final scaleY = size.height / strokeData.height;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()
        ..moveTo(stroke.first.dx * scaleX, stroke.first.dy * scaleY);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx * scaleX, point.dy * scaleY);
      }
      canvas.drawPath(path, pathPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WritingPainter oldDelegate) => oldDelegate.strokes != strokes;
}
