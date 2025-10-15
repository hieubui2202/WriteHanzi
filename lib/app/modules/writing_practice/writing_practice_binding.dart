
import 'package:get/get.dart';
import 'writing_practice_controller.dart';

class WritingPracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WritingPracticeController>(
      () => WritingPracticeController(),
    );
  }
}
