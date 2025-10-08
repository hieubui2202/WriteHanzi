import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/stroke_parser.dart';
import '../../domain/entities/stroke_data.dart';
import '../controllers/writing_session_controller.dart';

class MissingStrokePad extends StatefulWidget {
  const MissingStrokePad({super.key, required this.strokeData, this.missingCount = 1});

  final StrokeData strokeData;
  final int missingCount;

  @override
  State<MissingStrokePad> createState() => _MissingStrokePadState();
}

class _MissingStrokePadState extends State<MissingStrokePad> {
  late final WritingSessionController controller;
  late final List<Path> hintPaths;
  late final StrokeData targetData;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WritingSessionController>();
    controller.start();
    final parser = const StrokeParser();
    final hintCount = (widget.strokeData.paths.length - widget.missingCount).clamp(0, widget.strokeData.paths.length);
    hintPaths = widget.strokeData.paths.take(hintCount).map(parser.parseSvgPath).toList();
    final targetPaths = widget.strokeData.paths.skip(hintCount).toList();
    targetData = StrokeData(width: widget.strokeData.width, height: widget.strokeData.height, paths: targetPaths);
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
              child: Obx(() {
                final strokes = controller.strokes
                    .map((stroke) => List<Offset>.from(stroke))
                    .toList(growable: false);
                return CustomPaint(
                  painter: _MissingStrokePainter(
                    strokes: strokes,
                    hintPaths: hintPaths,
                    strokeData: targetData,
                  ),
                );
              }),
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

class _MissingStrokePainter extends CustomPainter {
  _MissingStrokePainter({
    required this.strokes,
    required this.hintPaths,
    required this.strokeData,
  });

  final List<List<Offset>> strokes;
  final List<Path> hintPaths;
  final StrokeData strokeData;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)), bg);

    final hintPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final strokePaint = Paint()
      ..color = const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final scaleX = size.width / strokeData.width;
    final scaleY = size.height / strokeData.height;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    for (final path in hintPaths) {
      canvas.drawPath(path, hintPaint);
    }
    canvas.restore();

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()
        ..moveTo(stroke.first.dx * scaleX, stroke.first.dy * scaleY);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx * scaleX, point.dy * scaleY);
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MissingStrokePainter oldDelegate) => oldDelegate.strokes != strokes;
}
