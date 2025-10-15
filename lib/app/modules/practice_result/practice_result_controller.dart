import 'package:get/get.dart';

import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/data/services/practice_progress_service.dart';
import 'package:myapp/app/routes/app_pages.dart';

import '../writing_practice/practice_session_controller.dart';

class PracticeResultController extends GetxController {
  PracticeResultController({PracticeProgressService? progressService})
      : _progressService = progressService ?? PracticeProgressService();

  final PracticeProgressService _progressService;

  late final PracticeSessionController session;
  late final HanziCharacter character;
  late final int mistakes;
  late final int xp;
  late final int score;
  late final Duration duration;
  late final Map<String, bool> completedSteps;

  final RxBool isSaving = false.obs;
  final RxBool saved = false.obs;

  @override
  void onInit() {
    super.onInit();
    session = Get.find<PracticeSessionController>();
    character = session.character!;
    mistakes = session.mistakes.value;
    xp = session.calculateXp();
    score = session.calculateScore();
    completedSteps = session.completedStepsSnapshot;
    session.endSession();
    duration = session.elapsed;
  }

  @override
  void onReady() {
    super.onReady();
    _submitProgress();
  }

  Future<void> _submitProgress() async {
    if (session.submitted) {
      return;
    }
    isSaving.value = true;
    try {
      await _progressService.submitProgress(
        character: character,
        xp: xp,
        score: score,
        mistakes: mistakes,
        completedSteps: completedSteps,
        duration: duration,
      );
      session.markSubmitted();
      saved.value = true;
    } finally {
      isSaving.value = false;
    }
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  void finishPractice() {
    Get.offAllNamed(Routes.home);
    Get.delete<PracticeSessionController>();
  }
}
