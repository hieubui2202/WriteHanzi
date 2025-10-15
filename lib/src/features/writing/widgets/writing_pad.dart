import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';

import '../providers/drawing_provider.dart';

class WritingPad extends StatefulWidget {
  const WritingPad({super.key});

  @override
  State<WritingPad> createState() => _WritingPadState();
}

class _WritingPadState extends State<WritingPad> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final provider = context.read<DrawingProvider>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.updateCanvasSize(size);
        });

        return Consumer<DrawingProvider>(
          builder: (context, drawingProvider, _) {
            return GestureDetector(
              onPanStart: drawingProvider.ready && !drawingProvider.isComplete
                  ? (details) {
                      drawingProvider.startLine(details.localPosition);
                    }
                  : null,
              onPanUpdate: drawingProvider.ready && !drawingProvider.isComplete
                  ? (details) {
                      drawingProvider.updateLine(details.localPosition);
                    }
                  : null,
              onPanEnd: drawingProvider.ready && !drawingProvider.isComplete
                  ? (details) {
                      final success = drawingProvider.endLine();
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hãy thử lại nét này nhé!'),
                            duration: Duration(milliseconds: 700),
                          ),
                        );
                      }
                    }
                  : null,
              child: CustomPaint(
                painter: _StrokeGuidePainter(
                  guidePaths: drawingProvider.guidePaths,
                  progress: drawingProvider.strokeProgress,
                  activeStrokes: drawingProvider.activeUserStrokes,
                ),
                size: Size.infinite,
              ),
            );
          },
        );
      },
    );
  }
}

class _StrokeGuidePainter extends CustomPainter {
  _StrokeGuidePainter({
    required this.guidePaths,
    required this.progress,
    required this.activeStrokes,
  });

  final List<Path> guidePaths;
  final List<double> progress;
  final List<List<Offset>> activeStrokes;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintGrid(canvas, size);
    _paintGuides(canvas);
    _paintHighlights(canvas);
    _paintActiveInk(canvas);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shader = const RadialGradient(
      center: Alignment(0, 0.4),
      radius: 0.85,
      colors: [
        Color(0xFF121C3F),
        Color(0xFF0F1631),
        Color(0xFF080B1C),
      ],
    ).createShader(rect);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = shader,
    );
  }

  void _paintGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF243059)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(14),
    );

    final borderPath = Path()..addRRect(borderRect);
    canvas.drawPath(
      dashPath(borderPath, dashArray: CircularIntervalList<double>([6, 4])),
      gridPaint,
    );

    final crossPaint = Paint()
      ..color = const Color(0xFF243059)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final horizontal = Path()
      ..moveTo(0, size.height / 2)
      ..lineTo(size.width, size.height / 2);
    final vertical = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, size.height);

    final dashedHorizontal =
        dashPath(horizontal, dashArray: CircularIntervalList<double>([5, 4]));
    final dashedVertical =
        dashPath(vertical, dashArray: CircularIntervalList<double>([5, 4]));

    canvas.drawPath(dashedHorizontal, crossPaint);
    canvas.drawPath(dashedVertical, crossPaint);
  }

  void _paintGuides(Canvas canvas) {
    final guidePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in guidePaths) {
      canvas.drawPath(path, guidePaint);
    }
  }

  void _paintHighlights(Canvas canvas) {
    final glowPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 12);

    for (var i = 0; i < guidePaths.length; i++) {
      final pct = i < progress.length ? progress[i].clamp(0.0, 1.0) : 0.0;
      if (pct <= 0) continue;

      final metrics = guidePaths[i].computeMetrics().toList();
      final totalLength = metrics.fold<double>(0, (sum, metric) => sum + metric.length);
      if (totalLength == 0) continue;

      var remaining = totalLength * pct;
      for (final metric in metrics) {
        if (remaining <= 0) break;
        final segmentLength = math.min(metric.length, remaining);
        final highlightPath = metric.extractPath(0, segmentLength);
        canvas.drawPath(highlightPath, glowPaint);
        remaining -= segmentLength;
      }
    }
  }

  void _paintActiveInk(Canvas canvas) {
    final inkPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in activeStrokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, inkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokeGuidePainter oldDelegate) {
    return oldDelegate.guidePaths != guidePaths ||
        oldDelegate.progress != progress ||
        oldDelegate.activeStrokes != activeStrokes;
  }
}
