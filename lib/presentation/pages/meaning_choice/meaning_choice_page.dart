import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/character.dart';
import '../../controllers/practice_controller.dart';
import '../../controllers/progress_controller.dart';
import '../splash/routes.dart';

class MeaningChoicePage extends StatelessWidget {
  const MeaningChoicePage({super.key});

  static const route = GetPage(
    name: AppRoutes.meaningChoice,
    page: MeaningChoicePage.new,
  );

  @override
  Widget build(BuildContext context) {
    final practiceController = Get.find<PracticeController>();
    final progressController = Get.find<ProgressController>();
    final character = practiceController.currentCharacter.value;
    if (character == null) {
      Future.microtask(() => Get.offAllNamed(AppRoutes.home));
      return const SizedBox();
    }
    final options = _buildOptions(progressController.characters, character);
    return Scaffold(
      appBar: AppBar(title: Text(character.hanzi)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('meaning_prompt'.tr, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () => practiceController.onMeaningAnswered(option == character.meaning),
                  style: ElevatedButton.styleFrom(alignment: Alignment.centerLeft),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _buildOptions(List<Character> characters, Character target) {
    final pool = characters.where((c) => c.hanzi != target.hanzi).toList();
    pool.shuffle(Random());
    final distractors = pool.take(2).map((c) => c.meaning).where((m) => m != target.meaning).toList();
    const fallback = ['fire', 'mountain', 'earth', 'metal'];
    int i = 0;
    while (distractors.length < 2) {
      final candidate = fallback[i % fallback.length];
      if (candidate != target.meaning && !distractors.contains(candidate)) {
        distractors.add(candidate);
      }
      i++;
    }
    final options = [...distractors, target.meaning];
    options.shuffle(Random());
    return options;
  }
}
