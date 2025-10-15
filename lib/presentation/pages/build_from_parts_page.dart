import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';
import 'package:myapp/presentation/widgets/radical_board.dart';

class BuildFromPartsPage extends StatefulWidget {
  const BuildFromPartsPage({super.key, required this.character, required this.gameIndex});

  final HanziCharacter character;
  final int gameIndex;

  @override
  State<BuildFromPartsPage> createState() => _BuildFromPartsPageState();
}

class _BuildFromPartsPageState extends State<BuildFromPartsPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  bool _completed = false;
  bool _autoTriggered = false;

  @override
  Widget build(BuildContext context) {
    final game = controller.gameForIndex(widget.gameIndex);
    if (game.slots.isEmpty && !_autoTriggered) {
      _autoTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final step = widget.gameIndex == 0
            ? PracticeStep.buildFromParts1
            : PracticeStep.buildFromParts2;
        controller.markStepCompleted(step, passed: true);
        controller.goToNext();
      });
    }
    return Padding(
      padding: practicePadding,
      child: Column(
        children: [
          Expanded(
            child: RadicalBoard(
              layout: game.layout,
              slots: game.slots,
              choices: game.choices,
              onStateChanged: (value) {
                setState(() => _completed = value);
              },
              onMistake: () {
                final step = widget.gameIndex == 0
                    ? PracticeStep.buildFromParts1
                    : PracticeStep.buildFromParts2;
                controller.markStepCompleted(step, passed: false);
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: primaryButtonStyle,
            onPressed: _completed
                ? () {
                    final step = widget.gameIndex == 0
                        ? PracticeStep.buildFromParts1
                        : PracticeStep.buildFromParts2;
                    controller.markStepCompleted(step, passed: true);
                    controller.goToNext();
                  }
                : null,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}
