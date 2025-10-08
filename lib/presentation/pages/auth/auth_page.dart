import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../splash/routes.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static final route = GetPage(
    name: AppRoutes.auth,
    page: AuthPage.new,
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'welcome'.tr,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 52),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Obx(() {
                return controller.loading.value
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: controller.signInWithGoogle,
                            child: Text('sign_in_google'.tr),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: controller.signInAnonymously,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              side: const BorderSide(color: Color(0xFF00CFFF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            ),
                            child: Text(
                              'sign_in_guest'.tr,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
