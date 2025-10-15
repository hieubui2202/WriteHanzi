
import 'package:get/get.dart';
import 'package:myapp/app/data/repository/character_repository.dart';
import 'package:myapp/app/domain/repository/i_character_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register the repository implementation. We use fenix:true to ensure
    // the repository is not disposed and can be reused by other features.
    Get.lazyPut<ICharacterRepository>(() => CharacterRepository(), fenix: true);

    // Register the HomeController. GetX will automatically create an instance
    // of the repository and inject it into the controller.
    Get.lazyPut<HomeController>(() => HomeController(Get.find()));
  }
}
