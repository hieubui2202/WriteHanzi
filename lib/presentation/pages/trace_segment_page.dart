import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';
import 'package:myapp/presentation/widgets/hanzi_canvas.dart';

class TraceSegmentPage extends StatefulWidget {
  const TraceSegmentPage({super.key, required this.character});

  final HanziCharacter character;

  @override
  State<TraceSegmentPage> createState() => _TraceSegmentPageState();
}

class _TraceSegmentPageState extends State<TraceSegmentPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  final GlobalKey<HanziStrokeCanvasState> canvasKey = GlobalKey<HanziStrokeCanvasState>();
  late final int _targetIndex;
  int _matched = 0;

  @override
  void initState() {
    super.initState();
    final total = widget.character.svgList.length;
    if (total <= 0) {
      _targetIndex = 0;
    } else {
      _targetIndex = (total / 2).floor().clamp(0, total - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = canvasKey.currentState?.isComplete ?? false;
    return Padding(
      padding: practicePadding,
      child: Column(
        children: [
          Expanded(
            child: HanziStrokeCanvas(
              key: canvasKey,
              svgList: widget.character.svgList,
              preRenderedCount: _targetIndex,
              expectPaths: [_targetIndex],
              onStrokeMatched: _handleMatch,
              onStrokeRejected: () => controller.markStepCompleted(
                PracticeStep.traceSegment,
                passed: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_matched}/1 segment traced',
            style: bodyStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          hintCaption(text: 'Tap the canvas for the next cue. Double-tap to watch the motion.'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => canvasKey.currentState?.showHint(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: practicePrimary,
                    side: const BorderSide(color: practicePrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Hint'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => canvasKey.currentState?.replay(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: practicePrimary,
                    side: const BorderSide(color: practicePrimary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Walkthrough'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    canvasKey.currentState?.clear();
                    setState(() => _matched = 0);
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
            onPressed: isComplete
                ? () {
                    controller.markStepCompleted(PracticeStep.traceSegment, passed: true);
                    controller.goToNext();
                  }
                : null,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }

  void _handleMatch(int index) {
    setState(() {
      _matched = canvasKey.currentState?.matchedCount ?? 1;
    });
  }
}
