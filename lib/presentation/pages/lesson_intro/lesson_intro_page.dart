import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import '../../controllers/progress_controller.dart';
import '../splash/routes.dart';

class LessonIntroPage extends StatelessWidget {
  const LessonIntroPage({super.key});

  static const route = GetPage(
    name: AppRoutes.lessonIntro,
    page: LessonIntroPage.new,
  );

  @override
  Widget build(BuildContext context) {
    final practiceController = Get.find<PracticeController>();
    final character = practiceController.currentCharacter.value;
    if (character == null) {
      Future.microtask(() => Get.offAllNamed(AppRoutes.home));
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(title: Text(character.hanzi)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Text(
              character.hanzi,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 128),
            ),
            const SizedBox(height: 16),
            Text(character.pinyin, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(character.meaning, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 36),
              onPressed: practiceController.replayAudio,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: practiceController.nextStep,
              child: Text('start'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
