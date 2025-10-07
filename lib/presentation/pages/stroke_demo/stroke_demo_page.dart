import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/practice_controller.dart';
import '../../widgets/stroke_demo_view.dart';
import '../splash/routes.dart';

class StrokeDemoPage extends StatelessWidget {
  const StrokeDemoPage({super.key});

  static const route = GetPage(
    name: AppRoutes.strokeDemo,
    page: StrokeDemoPage.new,
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
          children: [
            Text('stroke_demo_prompt'.tr, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Center(child: StrokeDemoView(strokeData: character.strokeData)),
            const Spacer(),
            ElevatedButton(
              onPressed: practiceController.nextStep,
              child: Text('next'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
