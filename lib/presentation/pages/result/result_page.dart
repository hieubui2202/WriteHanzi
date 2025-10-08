import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import '../../controllers/progress_controller.dart';
import '../splash/routes.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  static final route = GetPage(
    name: AppRoutes.result,
    page: ResultPage.new,
  );

  @override
  Widget build(BuildContext context) {
    final practiceController = Get.find<PracticeController>();
    final progressController = Get.find<ProgressController>();
    final character = practiceController.currentCharacter.value;
    final unit = practiceController.currentUnit.value;
    final profile = progressController.userProfile.value;
    return Scaffold(
      appBar: AppBar(title: Text('result_title'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(character?.hanzi ?? '', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 120)),
            const SizedBox(height: 16),
            Text('xp_earned'.trParams({'xp': practiceController.xpEarned.value.toString()}),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF78E08F))),
            const SizedBox(height: 8),
            Text('streak'.trParams({'streak': (profile?.streakDays ?? 0).toString()})),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (unit == null) {
                  Get.offAllNamed(AppRoutes.home);
                  return;
                }
                final nextCharacter = progressController.pickNextCharacter(unit.id);
                practiceController.start(unit, nextCharacter);
              },
              child: Text('next_word'.tr),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.home),
              child: Text('back_home'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
