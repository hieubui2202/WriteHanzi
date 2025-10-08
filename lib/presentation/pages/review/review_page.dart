import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/review_controller.dart';
import '../splash/routes.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  static final route = GetPage(
    name: AppRoutes.review,
    page: ReviewPage.new,
  );

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late final ReviewController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ReviewController>();
    controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('review'.tr)),
      body: Obx(() {
        final current = controller.current;
        if (current == null) {
          return Center(child: Text('no_mastered'.tr));
        }
        return GestureDetector(
          onTap: controller.flip,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: controller.flipped.value
                      ? Column(
                          key: const ValueKey('back'),
                          children: [
                            Text(current.pinyin, style: Theme.of(context).textTheme.headlineLarge),
                            const SizedBox(height: 12),
                            Text(current.meaning, style: Theme.of(context).textTheme.headlineMedium),
                          ],
                        )
                      : Text(
                          current.hanzi,
                          key: const ValueKey('front'),
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 160),
                        ),
                ),
                const SizedBox(height: 12),
                Text('tap_to_flip'.tr),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: controller.next,
                  child: Text('next'.tr),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
