import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';
import 'package:myapp/presentation/widgets/hanzi_canvas.dart';

class TraceFullPage extends StatefulWidget {
  const TraceFullPage({super.key, required this.character});

  final HanziCharacter character;

  @override
  State<TraceFullPage> createState() => _TraceFullPageState();
}

class _TraceFullPageState extends State<TraceFullPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  final GlobalKey<HanziStrokeCanvasState> canvasKey = GlobalKey<HanziStrokeCanvasState>();
  int _matchedCount = 0;

  @override
  Widget build(BuildContext context) {
    final canvasComplete = canvasKey.currentState?.isComplete ?? false;
    return Padding(
      padding: practicePadding,
      child: Column(
        children: [
          Expanded(
            child: HanziStrokeCanvas(
              key: canvasKey,
              svgList: widget.character.svgList,
              onStrokeMatched: _handleStrokeMatched,
              onStrokeRejected: () => controller.markStepCompleted(
                PracticeStep.traceFull,
                passed: false,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_matchedCount}/${widget.character.svgList.length} strokes matched',
            style: bodyStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => canvasKey.currentState?.replay(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: practicePrimary,
                    side: const BorderSide(color: practicePrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Replay'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    canvasKey.currentState?.clear();
                    setState(() {
                      _matchedCount = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: practiceText,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Erase'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: primaryButtonStyle,
            onPressed: canvasComplete
                ? () {
                    controller.markStepCompleted(PracticeStep.traceFull, passed: true);
                    controller.goToNext();
                  }
                : null,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  void _handleStrokeMatched(int index) {
    setState(() {
      _matchedCount = (canvasKey.currentState?.matchedCount ?? (_matchedCount + 1));
    });
  }
}
