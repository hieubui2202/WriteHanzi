import 'package:get/get.dart';

import 'package:myapp/presentation/controllers/practice_flow_controller.dart';

class WriteOneHanziBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeFlowController>(() => PracticeFlowController());
  }
}
