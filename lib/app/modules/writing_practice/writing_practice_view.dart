
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
      body: Column(
        children: [
          // Top section with character information
          _buildCharacterHeader(),
          
          // The main drawing canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))]
              ),
              child: GestureDetector(
                onPanStart: (details) => controller.startNewLine(details.localPosition),
                onPanUpdate: (details) => controller.addPointToLine(details.localPosition),
                child: Obx(() => CustomPaint(
                  painter: HanziPainter(
                    lines: controller.lines,
                    strokeColor: controller.selectedColor.value,
                    strokeWidth: controller.strokeWidth.value,
                  ),
                  child: Center(
                    child: Text(
                      controller.character.character,
                      style: TextStyle(fontSize: 200, color: Colors.grey.shade200),
                    ),
                  ),
                  size: Size.infinite,
                )),
              ),
            ),
          ),

          // Bottom control panel
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildCharacterHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(controller.character.pinyin, style: Get.textTheme.headlineSmall),
          const SizedBox(width: 16),
          Text('-', style: Get.textTheme.headlineSmall),
          const SizedBox(width: 16),
          Text(controller.character.meaning, style: Get.textTheme.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Get.theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: const Icon(Icons.undo, color: Colors.orange), onPressed: controller.undoLastStroke, tooltip: 'Hoàn tác'),
              IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: controller.clearCanvas, tooltip: 'Xóa hết'),
              IconButton(icon: const Icon(Icons.check_circle, color: Colors.green, size: 32), onPressed: controller.checkDrawing, tooltip: 'Kiểm tra'),
            ],
          ),
        ],
      ),
    );
  }
}
