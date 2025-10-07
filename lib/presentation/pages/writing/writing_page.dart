import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import '../../controllers/writing_session_controller.dart';
import '../../widgets/writing_canvas.dart';
import '../splash/routes.dart';

class WritingPage extends StatelessWidget {
  const WritingPage({super.key});

  static const route = GetPage(
    name: AppRoutes.writing,
    page: WritingPage.new,
  );

  @override
  Widget build(BuildContext context) {
    final practiceController = Get.find<PracticeController>();
    final writingController = Get.find<WritingSessionController>();
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
            Text('writing_prompt'.tr, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(child: WritingCanvas(strokeData: character.strokeData)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: writingController.undo,
                  child: const Icon(Icons.undo),
                ),
                OutlinedButton(
                  onPressed: writingController.clear,
                  child: const Icon(Icons.delete_outline),
                ),
                ElevatedButton(
                  onPressed: () {
                    final result = writingController.evaluateWith(character.strokeData);
                    if (result) {
                      practiceController.onWritingEvaluated(true);
                    } else {
                      practiceController.onWritingEvaluated(false);
                      Get.snackbar(
                        'try_again_title'.tr,
                        'writing_try_again'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text('check'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
