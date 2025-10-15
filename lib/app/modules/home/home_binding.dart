
import 'package:get/get.dart';
import 'package:myapp/app/data/repositories/home_repository.dart';
import 'package:myapp/app/modules/home/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(() => HomeRepository());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
