
import 'package:get/get.dart';
import 'package:myapp/app/data/models/hanzi_character.dart';
import 'package:myapp/app/domain/repository/i_character_repository.dart';
import 'package:myapp/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final ICharacterRepository _repository;
  HomeController(this._repository);

  // Use Rx for reactive state management. The UI will automatically update when these change.
  final RxBool isLoading = true.obs;
  final RxList<HanziCharacter> characters = <HanziCharacter>[].obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCharacters();
  }

  // Logic to fetch characters from the repository.
  Future<void> fetchCharacters() async {
    try {
      isLoading(true);
      error('');
      final characterList = await _repository.getCharacters();
      if (characterList.isEmpty) {
        error('Không tìm thấy ký tự nào.');
      } else {
        characters.assignAll(characterList);
      }
    } catch (e) {
      error('Đã xảy ra lỗi khi tải dữ liệu.');
      // In a real app, log this error to a service like Crashlytics
    } finally {
      isLoading(false);
    }
  }

  // Navigate to the practice screen, passing the selected character as an argument.
  void startPractice(HanziCharacter character) {
    Get.toNamed(Routes.WRITING_PRACTICE, arguments: character);
  }
}
