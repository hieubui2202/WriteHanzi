
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'writing_practice_controller.dart';
import 'widgets/hanzi_painter.dart';

class WritingPracticeView extends GetView<WritingPracticeController> {
  const WritingPracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Luyện viết: ${controller.character.character}'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCharacterHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: GestureDetector(
                    onPanStart: (details) =>
                        controller.startNewLine(details.localPosition),
                    onPanUpdate: (details) =>
                        controller.addPointToLine(details.localPosition),
                    child: Obx(
                      () {
                        final lines = controller.lines
                            .map((stroke) => List<Offset>.from(stroke))
                            .toList();
                        final strokeColor = controller.selectedColor.value;
                        final strokeWidth = controller.strokeWidth.value;
                        final hasReference = controller.referencePaths.isNotEmpty;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            if (!hasReference)
                              Center(
                                child: Text(
                                  controller.character.character,
                                  style: TextStyle(
                                    fontSize: 160,
                                    color: Colors.grey.shade300,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            CustomPaint(
                              painter: HanziPainter(
                                lines: lines,
                                strokeColor: strokeColor,
                                strokeWidth: strokeWidth,
                                referencePaths: controller.referencePaths,
                                referenceBounds: controller.referenceBounds,
                              ),
                              size: Size.infinite,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildControlPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterHeader(BuildContext context) {
    final theme = Theme.of(context);
    final display = controller.character.word.isNotEmpty
        ? controller.character.word
        : controller.character.character;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            display,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.character.pinyin} • ${controller.character.meaning}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.orange),
                onPressed: controller.undoLastStroke,
                tooltip: 'Hoàn tác',
              ),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                onPressed: controller.clearCanvas,
                tooltip: 'Xóa hết',
              ),
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                onPressed: controller.checkDrawing,
                tooltip: 'Kiểm tra',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
