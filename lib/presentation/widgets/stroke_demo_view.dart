import 'package:flutter/material.dart';

import '../../core/utils/stroke_parser.dart';
import '../../domain/entities/stroke_data.dart';

class StrokeDemoView extends StatefulWidget {
  const StrokeDemoView({super.key, required this.strokeData});

  final StrokeData strokeData;

  @override
  State<StrokeDemoView> createState() => _StrokeDemoViewState();
}

class _StrokeDemoViewState extends State<StrokeDemoView> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final StrokeParser parser;

  @override
  void initState() {
    super.initState();
    parser = const StrokeParser();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        return CustomPaint(
          painter: _StrokeDemoPainter(
            parser: parser,
            data: widget.strokeData,
            progress: progress,
          ),
          size: const Size.square(260),
        );
      },
    );
  }
}

class _StrokeDemoPainter extends CustomPainter {
  _StrokeDemoPainter({required this.parser, required this.data, required this.progress});

  final StrokeParser parser;
  final StrokeData data;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00CFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final outline = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scaleX = size.width / data.width;
    final scaleY = size.height / data.height;

    canvas.translate((size.width - data.width * scaleX) / 2, (size.height - data.height * scaleY) / 2);
    canvas.scale(scaleX, scaleY);

    double cumulative = 0;
    final perStroke = 1 / data.paths.length;
    for (int i = 0; i < data.paths.length; i++) {
      final path = parser.parseSvgPath(data.paths[i]);
      canvas.drawPath(path, outline);
      final start = cumulative;
      final end = cumulative + perStroke;
      final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
      if (t > 0) {
        final metrics = path.computeMetrics().toList();
        for (final metric in metrics) {
          final extract = metric.extractPath(0, metric.length * t);
          canvas.drawPath(extract, paint);
        }
      }
      cumulative += perStroke;
    }
  }

  @override
  bool shouldRepaint(covariant _StrokeDemoPainter oldDelegate) => oldDelegate.progress != progress;
}
