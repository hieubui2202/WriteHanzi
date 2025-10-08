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
    final displayName = profile?.displayName ?? 'guest_user'.tr;
    final trimmedName = displayName.trim();
    final avatarLetter = trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : '?';
    final xpText = 'xp_label'.trParams({'xp': (profile?.xp ?? 0).toString()});
    final streakText = 'streak_label'.trParams({'streak': (profile?.streakDays ?? 0).toString()});
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
                  child: Text(avatarLetter),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: Theme.of(context).textTheme.titleLarge),
                    if (profile?.email != null) Text(profile!.email!),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(xpText, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(streakText),
            const Spacer(),
            ElevatedButton(
              onPressed: authController.signOut,
              child: Text('sign_out'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
