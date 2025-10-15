import 'package:get/get.dart';

import 'practice_result_controller.dart';

class PracticeResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeResultController>(
      () => PracticeResultController(),
    );
  }
}
