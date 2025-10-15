
import 'package:get/get.dart';

import 'practice_session_controller.dart';
import 'writing_practice_controller.dart';

class WritingPracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeSessionController>(
      () => PracticeSessionController(),
      fenix: true,
    );
    Get.lazyPut<WritingPracticeController>(
      () => WritingPracticeController(),
    );
  }
}
