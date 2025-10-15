import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'missing_stroke_controller.dart';
import '../writing_practice/widgets/hanzi_canvas.dart';

class MissingStrokePage extends GetView<MissingStrokeController> {
  const MissingStrokePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoàn thiện chữ Hán'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Stack(
                      children: [
                        Positioned.fill(
                          child: HanziCanvas(
                            key: controller.canvasKey,
                            referencePaths: controller.referencePaths,
                            referenceBounds: controller.referenceBounds,
                            strokeColor: const Color(0xFF1F1F1F),
                            strokeWidth: 7,
                            preRenderedCount: controller.preRenderedCount,
                            expectPaths: controller.expectedPaths,
                            onStrokeMatched: controller.onStrokeMatched,
                            onStrokeRejected: controller.onStrokeRejected,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${controller.matchedCount.value}/${controller.expectedPaths.length} nét thiếu',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final display = controller.character.word.isNotEmpty
        ? controller.character.word
        : controller.character.character;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Text(
            "Finish the hanzi for ‘$display’",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Vẽ các nét còn thiếu theo gợi ý.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final canContinue = controller.canContinue.value;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: controller.showHint,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Replay'),
            ),
            OutlinedButton.icon(
              onPressed: controller.clearCanvas,
              icon: const Icon(Icons.refresh),
              label: const Text('Erase'),
            ),
            ElevatedButton(
              onPressed: canContinue ? controller.continueFlow : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    });
  }
}
