import 'package:get/get.dart';

import 'build_hanzi_controller.dart';

class BuildHanziBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuildHanziController>(
      () => BuildHanziController(),
    );
  }
}
