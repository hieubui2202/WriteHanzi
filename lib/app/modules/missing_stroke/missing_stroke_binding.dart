import 'package:get/get.dart';

import 'missing_stroke_controller.dart';

class MissingStrokeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissingStrokeController>(
      () => MissingStrokeController(),
    );
  }
}
