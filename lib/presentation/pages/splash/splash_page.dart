import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/progress_controller.dart';
import 'routes.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static final route = GetPage(
    name: AppRoutes.splash,
    page: SplashPage.new,
  );

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final progressController = Get.find<ProgressController>();
    return Scaffold(
      body: Center(
        child: Obx(() {
          final user = authController.firebaseUser.value;
          if (user != null) {
            if (progressController.loading.value) {
              return const CircularProgressIndicator();
            }
            Future.microtask(() => Get.offAllNamed(AppRoutes.home));
          } else {
            Future.microtask(() => Get.offAllNamed(AppRoutes.auth));
          }
          return const CircularProgressIndicator();
        }),
      ),
    );
  }
}
