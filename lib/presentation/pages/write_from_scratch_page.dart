import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';
import 'package:myapp/presentation/widgets/hanzi_canvas.dart';

enum WriteSegment { firstHalf, secondHalf }

class WriteFromScratchPage extends StatefulWidget {
  const WriteFromScratchPage({super.key, required this.character, required this.segment});

  final HanziCharacter character;
  final WriteSegment segment;

  @override
  State<WriteFromScratchPage> createState() => _WriteFromScratchPageState();
}

class _WriteFromScratchPageState extends State<WriteFromScratchPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  final GlobalKey<HanziStrokeCanvasState> canvasKey = GlobalKey<HanziStrokeCanvasState>();
  late final List<int> _expected;
  late final int _preRendered;
  int _matched = 0;
  bool _autoCompleted = false;

  @override
  void initState() {
    super.initState();
    final total = widget.character.svgList.length;
    final pivot = (total / 2).ceil();
    if (widget.segment == WriteSegment.firstHalf) {
      _expected = List<int>.generate(pivot, (index) => index);
      _preRendered = 0;
    } else {
      _expected = List<int>.generate(total - pivot, (index) => pivot + index);
      _preRendered = pivot;
    }
    if (_expected.isEmpty) {
      _autoCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final step = widget.segment == WriteSegment.firstHalf
            ? PracticeStep.writeFromScratch1
            : PracticeStep.writeFromScratch2;
        controller.markStepCompleted(step, passed: true);
        controller.goToNext();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _autoCompleted || canvasKey.currentState?.isComplete == true || _expected.isEmpty;
    return Padding(
      padding: practicePadding,
      child: Column(
        children: [
          Expanded(
            child: HanziStrokeCanvas(
              key: canvasKey,
              svgList: widget.character.svgList,
              preRenderedCount: _preRendered,
              expectPaths: _expected,
              onStrokeMatched: _handleMatch,
              onStrokeRejected: () {
                final step = widget.segment == WriteSegment.firstHalf
                    ? PracticeStep.writeFromScratch1
                    : PracticeStep.writeFromScratch2;
                controller.markStepCompleted(step, passed: false);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _expected.isEmpty
                ? 'All strokes pre-rendered'
                : '${_matched}/${_expected.length} strokes written',
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
                    final step = widget.segment == WriteSegment.firstHalf
                        ? PracticeStep.writeFromScratch1
                        : PracticeStep.writeFromScratch2;
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

  void _handleMatch(int index) {
    setState(() {
      _matched = canvasKey.currentState?.matchedCount ?? _matched + 1;
    });
  }
}
