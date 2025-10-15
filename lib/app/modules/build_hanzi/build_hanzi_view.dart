import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'build_hanzi_controller.dart';
import 'widgets/radical_board.dart';

class BuildHanziPage extends GetView<BuildHanziController> {
  const BuildHanziPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghép chữ Hán'),
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RadicalBoard(
                  layout: controller.layout,
                  slots: controller.slots,
                  choices: controller.choices,
                  onStateChanged: controller.onBoardStateChanged,
                  onMistake: controller.onBoardMistake,
                ),
              ),
            ),
            _buildFooter(context),
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
            "Build the hanzi: $display",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo thả các bộ phận vào vị trí đúng để hoàn thành chữ.',
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

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final ready = controller.canContinue.value;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: ready ? controller.continueFlow : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Continue'),
          ),
        ),
      );
    });
  }
}
