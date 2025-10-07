import 'package:get/get.dart';

class SettingsController extends GetxController {
  final RxBool soundEnabled = true.obs;
  final RxString localeCode = 'vi_VN'.obs;

  void toggleSound(bool value) {
    soundEnabled.value = value;
  }

  void changeLocale(String code) {
    localeCode.value = code;
  }
}
