import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/presentation/controllers/practice_flow_controller.dart';
import 'package:myapp/presentation/pages/practice_style.dart';
import 'package:myapp/presentation/pages/select_meaning_page.dart';
import 'package:myapp/presentation/pages/select_pronunciation_page.dart';
import 'package:myapp/presentation/pages/trace_full_page.dart';
import 'package:myapp/presentation/pages/finish_partial_page.dart';
import 'package:myapp/presentation/pages/trace_segment_page.dart';
import 'package:myapp/presentation/pages/write_from_scratch_page.dart';
import 'package:myapp/presentation/pages/build_from_parts_page.dart';
import 'package:myapp/presentation/pages/result_page.dart';
import 'package:myapp/presentation/pages/type_hanzi_page.dart';

class WriteOneHanziPage extends StatefulWidget {
  const WriteOneHanziPage({super.key});

  @override
  State<WriteOneHanziPage> createState() => _WriteOneHanziPageState();
}

class _WriteOneHanziPageState extends State<WriteOneHanziPage> {
  late final PracticeFlowController controller = Get.find<PracticeFlowController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final parameters = Get.parameters;
    final charId = parameters['charId'] ?? (args is String ? args : null);
    if (charId != null) {
      controller.load(charId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: practiceBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: practicePrimary),
            );
          }
          final char = controller.character.value;
          if (char == null) {
            return Center(
              child: Text(
                'Không tìm thấy dữ liệu chữ này.',
                style: bodyStyle(fontSize: 18),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, char),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(controller.currentStep),
                    child: _buildStepWidget(controller.currentStep, char),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HanziCharacter char) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.playAudio,
                icon: const Icon(Icons.volume_up, color: practicePrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      char.word.isNotEmpty ? char.word : char.character,
                      style: titleStyle(context),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: controller.progress,
                      minHeight: 8,
                      color: practicePrimary,
                      backgroundColor: Colors.white12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Get.back<void>(),
                icon: const Icon(Icons.close, color: practiceText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            controller.currentStep == PracticeStep.selectPronunciation
                ? 'Select the correct pronunciation'
                : controller.currentStep == PracticeStep.selectMeaning
                    ? 'Select the correct meaning'
                    : controller.currentStep == PracticeStep.traceFull
                        ? "Trace the hanzi for '${char.meaning}'"
                        : controller.currentStep == PracticeStep.finishPartialA
                            ? "Finish the hanzi for '${char.meaning}'"
                    : controller.currentStep == PracticeStep.traceSegment
                        ? "Trace the hanzi for '${char.meaning}'"
                        : controller.currentStep == PracticeStep.finishPartialB
                            ? "Finish the hanzi for '${char.meaning}'"
                            : controller.currentStep == PracticeStep.writeFromScratch1
                                ? "Write the hanzi for '${char.meaning}'"
                                : controller.currentStep == PracticeStep.writeFromScratch2
                                    ? "Write the hanzi for '${char.meaning}'"
                                    : controller.currentStep == PracticeStep.typeOnKeyboard
                                        ? "Type the hanzi for '${char.meaning}'"
                                        : controller.currentStep == PracticeStep.buildFromParts1
                                            ? 'Build the hanzi from parts'
                                            : controller.currentStep == PracticeStep.buildFromParts2
                                                ? 'Assemble the hanzi'
                                                : 'Great job!',
            style: bodyStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStepWidget(PracticeStep step, HanziCharacter char) {
    switch (step) {
      case PracticeStep.selectPronunciation:
        return SelectPronunciationPage(character: char);
      case PracticeStep.selectMeaning:
        return SelectMeaningPage(character: char);
      case PracticeStep.traceFull:
        return TraceFullPage(character: char);
      case PracticeStep.finishPartialA:
        return FinishPartialPage(character: char, variant: FinishPartialVariant.first);
      case PracticeStep.traceSegment:
        return TraceSegmentPage(character: char);
      case PracticeStep.finishPartialB:
        return FinishPartialPage(character: char, variant: FinishPartialVariant.second);
      case PracticeStep.writeFromScratch1:
        return WriteFromScratchPage(character: char, segment: WriteSegment.firstHalf);
      case PracticeStep.writeFromScratch2:
        return WriteFromScratchPage(character: char, segment: WriteSegment.secondHalf);
      case PracticeStep.typeOnKeyboard:
        return TypeHanziPage(character: char);
      case PracticeStep.buildFromParts1:
        return BuildFromPartsPage(character: char, gameIndex: 0);
      case PracticeStep.buildFromParts2:
        return BuildFromPartsPage(character: char, gameIndex: 1);
      case PracticeStep.result:
        return const ResultPage();
    }
  }
}
