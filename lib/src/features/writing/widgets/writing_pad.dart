
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';

import 'package:myapp/src/features/writing/providers/drawing_provider.dart';

class WritingPad extends StatelessWidget {
  const WritingPad({
    super.key,
    required this.strokePaths,
    required this.viewBox,
    this.highlightColor = const Color(0xFF00E5FF),
    this.baseStrokeColor = const Color(0xFF1C274C),
    this.userStrokeColor = Colors.white,
  });

  final List<String> strokePaths;
  final Size viewBox;
  final Color highlightColor;
  final Color baseStrokeColor;
  final Color userStrokeColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final provider = Provider.of<DrawingProvider>(context);
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

        provider.syncReference(
          pathData: strokePaths,
          viewBox: viewBox,
          canvasSize: canvasSize,
        );

        return GestureDetector(
          onPanStart: (details) => provider.startLine(details.localPosition),
          onPanUpdate: (details) => provider.updateLine(details.localPosition),
          onPanEnd: (_) => provider.endLine(),
          child: CustomPaint(
            painter: _WritingPainter(
              lines: provider.lines,
              referencePaths: provider.referencePaths,
              strokeProgress: provider.strokeProgress,
              highlightColor: highlightColor,
              baseStrokeColor: baseStrokeColor,
              userStrokeColor: userStrokeColor,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _WritingPainter extends CustomPainter {
  const _WritingPainter({
    required this.lines,
    required this.referencePaths,
    required this.strokeProgress,
    required this.highlightColor,
    required this.baseStrokeColor,
    required this.userStrokeColor,
  });

  final List<List<Offset?>> lines;
  final List<Path> referencePaths;
  final List<double> strokeProgress;
  final Color highlightColor;
  final Color baseStrokeColor;
  final Color userStrokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final backgroundPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, 0.45),
        radius: 1.15,
        colors: [
          Color(0xFF0E1534),
          Color(0xFF0B1126),
          Color(0xFF070A18),
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);

    final guidePaint = Paint()
      ..color = const Color(0xFF243059)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide * 0.01).clamp(1.0, 2.5);

    final borderRRect = RRect.fromRectAndRadius(
      rect.deflate(4),
      Radius.circular(size.shortestSide * 0.08),
    );
    final borderPath = Path()..addRRect(borderRRect);
    canvas.drawPath(
      dashPath(borderPath, dashArray: CircularIntervalList<double>(const [6, 6])),
      guidePaint,
    );

    final crosshair = Path()
      ..moveTo(rect.left, rect.center.dy)
      ..lineTo(rect.right, rect.center.dy)
      ..moveTo(rect.center.dx, rect.top)
      ..lineTo(rect.center.dx, rect.bottom);

    canvas.drawPath(
      dashPath(crosshair, dashArray: CircularIntervalList<double>(const [6, 6])),
      guidePaint,
    );

    final baseStrokeWidth = (size.shortestSide * 0.065).clamp(6.0, 24.0);

    final basePaint = Paint()
      ..color = baseStrokeColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = baseStrokeWidth;

    final glowPaint = Paint()
      ..color = highlightColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = baseStrokeWidth + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = baseStrokeWidth;

    final userPaint = Paint()
      ..color = userStrokeColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = baseStrokeWidth * 0.7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (var i = 0; i < referencePaths.length; i++) {
      final path = referencePaths[i];
      canvas.drawPath(path, basePaint);

      final progress = i < strokeProgress.length ? strokeProgress[i].clamp(0.0, 1.0) : 0.0;
      if (progress <= 0) {
        continue;
      }

      final highlighted = Path();
      var hasSegments = false;
      for (final metric in path.computeMetrics()) {
        final extractLength = metric.length * progress;
        if (extractLength <= 0) {
          continue;
        }
        highlighted.addPath(metric.extractPath(0, extractLength), Offset.zero);
        hasSegments = true;
      }

      if (hasSegments) {
        canvas.drawPath(highlighted, glowPaint);
        canvas.drawPath(highlighted, highlightPaint);
      }
    }

    for (final line in lines) {
      Offset? previous;
      for (final point in line) {
        if (point == null) {
          previous = null;
          continue;
        }
        if (previous != null) {
          canvas.drawLine(previous, point, userPaint);
        }
        previous = point;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WritingPainter oldDelegate) => true;
}
