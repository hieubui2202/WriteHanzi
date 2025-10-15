import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';
import 'package:myapp/presentation/widgets/hanzi_canvas.dart';

enum FinishPartialVariant { first, second }

class FinishPartialPage extends StatefulWidget {
  const FinishPartialPage({
    super.key,
    required this.character,
    required this.variant,
  });

  final HanziCharacter character;
  final FinishPartialVariant variant;

  @override
  State<FinishPartialPage> createState() => _FinishPartialPageState();
}

class _FinishPartialPageState extends State<FinishPartialPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();
  final GlobalKey<HanziStrokeCanvasState> canvasKey = GlobalKey<HanziStrokeCanvasState>();
  late final List<int> _expectedIndices;
  late final int _preRendered;
  int _matchedCount = 0;
  bool _autoCompleted = false;

  @override
  void initState() {
    super.initState();
    final total = widget.character.svgList.length;
    final missingCount = widget.character.missingCount.clamp(1, total);
    final baseIndex = total - missingCount;
    final indices = List<int>.generate(missingCount, (i) => baseIndex + i);
    if (widget.variant == FinishPartialVariant.first) {
      _expectedIndices = indices.isEmpty ? <int>[] : [indices.first];
    } else {
      _expectedIndices = indices.length <= 1 ? <int>[] : [indices.last];
    }
    _preRendered = baseIndex;
    if (_expectedIndices.isEmpty) {
      _autoCompleted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final step = widget.variant == FinishPartialVariant.first
            ? PracticeStep.finishPartialA
            : PracticeStep.finishPartialB;
        controller.markStepCompleted(step, passed: true);
        controller.goToNext();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = _autoCompleted || canvasKey.currentState?.isComplete == true || _expectedIndices.isEmpty;
    return Padding(
      padding: practicePadding,
      child: Column(
        children: [
          Expanded(
            child: HanziStrokeCanvas(
              key: canvasKey,
              svgList: widget.character.svgList,
              preRenderedCount: _preRendered,
              expectPaths: _expectedIndices,
              onStrokeMatched: _handleMatch,
              onStrokeRejected: () {
                final step = widget.variant == FinishPartialVariant.first
                    ? PracticeStep.finishPartialA
                    : PracticeStep.finishPartialB;
                controller.markStepCompleted(step, passed: false);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _expectedIndices.isEmpty
                ? 'All set!'
                : '${_matchedCount}/${_expectedIndices.length} missing strokes finished',
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
            onPressed: isComplete
                ? () {
                    final step = widget.variant == FinishPartialVariant.first
                        ? PracticeStep.finishPartialA
                        : PracticeStep.finishPartialB;
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
      _matchedCount = canvasKey.currentState?.matchedCount ?? _matchedCount + 1;
    });
  }
}
