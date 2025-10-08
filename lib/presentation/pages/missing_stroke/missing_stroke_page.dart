import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import '../../controllers/writing_session_controller.dart';
import '../../../domain/entities/stroke_data.dart';
import '../../widgets/missing_stroke_pad.dart';
import '../splash/routes.dart';

class MissingStrokePage extends StatelessWidget {
  const MissingStrokePage({super.key});

  static final route = GetPage(
    name: AppRoutes.missingStroke,
    page: MissingStrokePage.new,
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
    final missingCount = character.strokeData.paths.length > 1 ? 1 : character.strokeData.paths.length;
    return Scaffold(
      appBar: AppBar(title: Text(character.hanzi)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('missing_stroke_prompt'.tr, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(child: MissingStrokePad(strokeData: character.strokeData, missingCount: missingCount)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final targetData = character.strokeData;
                final trimmed = StrokeData(
                  width: targetData.width,
                  height: targetData.height,
                  paths: targetData.paths.skip(targetData.paths.length - missingCount).toList(),
                );
                final result = writingController.evaluateWith(trimmed);
                if (result) {
                  practiceController.onMissingStrokeEvaluated(true);
                } else {
                  practiceController.onMissingStrokeEvaluated(false);
                  Get.snackbar(
                    'try_again_title'.tr,
                    'missing_try_again'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text('check'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
