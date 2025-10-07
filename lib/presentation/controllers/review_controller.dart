import 'package:get/get.dart';

import '../../domain/entities/character.dart';
import 'progress_controller.dart';

class ReviewController extends GetxController {
  ReviewController({required this.progressController});

  final ProgressController progressController;

  final RxList<Character> reviewCharacters = <Character>[].obs;
  final RxInt index = 0.obs;
  final RxBool flipped = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(progressController.userProfile, (_) => load());
    ever(progressController.units, (_) => load());
  }

  void load() {
    final profile = progressController.userProfile.value;
    final units = progressController.units;
    final characters = progressController.characters;
    final mastered = <Character>[];
    for (final unit in units) {
      final unitProgress = profile?.progress[unit.id];
      if (unitProgress is Map<String, dynamic>) {
        for (final entry in unitProgress.entries) {
          if (entry.value is Map<String, dynamic> && (entry.value['completed'] == true)) {
            final character = _findCharacter(characters, entry.key);
            if (character != null) {
              mastered.add(character);
            }
          }
        }
      }
    }
    reviewCharacters.assignAll(mastered);
    index.value = 0;
    flipped.value = false;
  }

  Character? get current =>
      reviewCharacters.isEmpty ? null : reviewCharacters[index.value % reviewCharacters.length];

  void next() {
    if (reviewCharacters.isEmpty) return;
    index.value = (index.value + 1) % reviewCharacters.length;
    flipped.value = false;
  }

  void flip() {
    flipped.value = !flipped.value;
  }

  Character? _findCharacter(List<Character> characters, String hanzi) {
    for (final character in characters) {
      if (character.hanzi == hanzi) {
        return character;
      }
    }
    return null;
  }
}
