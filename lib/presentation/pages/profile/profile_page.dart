import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/progress_controller.dart';
import '../splash/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static final route = GetPage(
    name: AppRoutes.profile,
    page: ProfilePage.new,
  );

  @override
  Widget build(BuildContext context) {
    final progressController = Get.find<ProgressController>();
    final authController = Get.find<AuthController>();
    final profile = progressController.userProfile.value;
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(profile?.displayName?.substring(0, 1).toUpperCase() ?? '?'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile?.displayName ?? 'Guest', style: Theme.of(context).textTheme.titleLarge),
                    if (profile?.email != null) Text(profile!.email!),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('XP: ${profile?.xp ?? 0}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Streak: ${profile?.streakDays ?? 0}'),
            const Spacer(),
            ElevatedButton(
              onPressed: authController.signOut,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
