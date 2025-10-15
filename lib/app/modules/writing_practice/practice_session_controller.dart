import 'package:get/get.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';

class PracticeSessionController extends GetxController {
  PracticeSessionController();

  final RxInt mistakes = 0.obs;
  final RxMap<String, bool> completedSteps =
      <String, bool>{'trace': false, 'missing': false, 'build': false}.obs;

  DateTime? _startTime;
  DateTime? _endTime;
  HanziCharacter? _character;
  bool _submitted = false;

  HanziCharacter? get character => _character;

  void initialize(HanziCharacter character) {
    _character ??= character;
    _startTime ??= DateTime.now();
  }

  void recordMistake() {
    mistakes.value += 1;
  }

  void markStepCompleted(String step) {
    completedSteps[step] = true;
  }

  void endSession() {
    _endTime ??= DateTime.now();
  }

  Duration get elapsed => (_endTime ?? DateTime.now()).difference(_startTime ?? DateTime.now());

  int calculateXp() {
    final mistakeCount = mistakes.value;
    if (mistakeCount <= 0) return 10;
    if (mistakeCount == 1) return 5;
    return 2;
  }

  int calculateScore() {
    final mistakeCount = mistakes.value;
    if (mistakeCount <= 0) return 100;
    if (mistakeCount == 1) return 85;
    final penalty = (mistakeCount * 12).clamp(0, 70);
    return (100 - penalty).clamp(40, 100);
  }

  Map<String, bool> get completedStepsSnapshot => Map<String, bool>.from(completedSteps);

  bool get submitted => _submitted;

  void markSubmitted() {
    _submitted = true;
  }

  void resetSession() {
    mistakes.value = 0;
    completedSteps.assignAll({'trace': false, 'missing': false, 'build': false});
    _startTime = null;
    _endTime = null;
    _character = null;
    _submitted = false;
  }
}
