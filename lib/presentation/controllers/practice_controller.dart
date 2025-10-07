import 'dart:math';

import 'package:get/get.dart';

import '../../core/services/audio_service.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/unit_model.dart';
import '../pages/lesson_intro/lesson_intro_page.dart';
import '../pages/meaning_choice/meaning_choice_page.dart';
import '../pages/missing_stroke/missing_stroke_page.dart';
import '../pages/result/result_page.dart';
import '../pages/stroke_demo/stroke_demo_page.dart';
import '../pages/writing/writing_page.dart';
import '../pages/splash/routes.dart';
import 'progress_controller.dart';

enum PracticeStep {
  lessonIntro,
  meaningChoice,
  strokeDemo,
  writing,
  missingStroke,
  result,
}

class PracticeController extends GetxController {
  PracticeController({
    required this.audioService,
    required this.progressController,
  });

  final AudioService audioService;
  final ProgressController progressController;

  final Rxn<UnitModel> currentUnit = Rxn<UnitModel>();
  final Rxn<Character> currentCharacter = Rxn<Character>();
  final RxInt stepIndex = 0.obs;
  final RxInt xpEarned = 0.obs;
  final RxInt mistakes = 0.obs;
  final RxBool meaningCorrect = false.obs;
  final RxBool writingPassed = false.obs;
  final RxBool missingStrokePassed = false.obs;

  PracticeStep get step => PracticeStep.values[stepIndex.value];

  final List<GetPage<dynamic>> pages = const [
    LessonIntroPage.route,
    MeaningChoicePage.route,
    StrokeDemoPage.route,
    WritingPage.route,
    MissingStrokePage.route,
    ResultPage.route,
  ];

  void start(UnitModel unit, Character character) {
    currentUnit.value = unit;
    currentCharacter.value = character;
    stepIndex.value = 0;
    xpEarned.value = 0;
    mistakes.value = 0;
    meaningCorrect.value = false;
    writingPassed.value = false;
    missingStrokePassed.value = false;
    _navigateToCurrentStep(initial: true);
  }

  void _navigateToCurrentStep({bool initial = false}) {
    final route = pages[stepIndex.value].name;
    if (route != null) {
      if (initial) {
        Get.toNamed(route);
      } else {
        Get.offNamed(route);
      }
    }
  }

  void onMeaningAnswered(bool correct) {
    meaningCorrect.value = correct;
    xpEarned.value += correct ? 2 : 0;
    mistakes.value += correct ? 0 : 1;
    nextStep();
  }

  void onWritingEvaluated(bool passed) {
    writingPassed.value = passed;
    if (passed) {
      xpEarned.value += 6;
      nextStep();
    } else {
      mistakes.value += 1;
    }
  }

  void onMissingStrokeEvaluated(bool passed) {
    missingStrokePassed.value = passed;
    if (passed) {
      xpEarned.value += 2;
      nextStep();
    } else {
      mistakes.value += 1;
    }
  }

  Future<void> nextStep() async {
    if (stepIndex.value < PracticeStep.values.length - 2) {
      stepIndex.value += 1;
      _navigateToCurrentStep();
    } else if (stepIndex.value == PracticeStep.values.length - 2) {
      stepIndex.value += 1;
      await _finishAndRecord();
    } else {
      await _finishAndRecord();
    }
  }

  Future<void> _finishAndRecord() async {
    final unit = currentUnit.value;
    final character = currentCharacter.value;
    if (unit == null || character == null) return;
    final passed = meaningCorrect.value && writingPassed.value && missingStrokePassed.value;
    final score = passed ? 1.0 : max(0, 1 - mistakes.value * 0.2);
    await progressController.updateProgress(
      unit: unit,
      character: character,
      score: score,
      completed: passed,
      mistakes: mistakes.value,
      xpEarned: xpEarned.value,
    );
    Get.offAllNamed(AppRoutes.result);
  }

  void replayAudio() {
    final url = currentCharacter.value?.ttsUrl;
    if (url != null) {
      audioService.play(url);
    }
  }
}
