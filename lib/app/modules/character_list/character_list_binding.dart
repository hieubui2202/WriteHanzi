import 'package:get/get.dart';
import 'package:myapp/app/modules/character_list/character_list_controller.dart';

class CharacterListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CharacterListController>(() => CharacterListController());
  }
}
