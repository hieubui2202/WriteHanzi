import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../splash/routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static final route = GetPage(
    name: AppRoutes.settings,
    page: SettingsPage.new,
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => SwitchListTile(
                  value: controller.soundEnabled.value,
                  onChanged: controller.toggleSound,
                  title: Text('sound_effects'.tr),
                )),
            const SizedBox(height: 12),
            Text('language'.tr, style: Theme.of(context).textTheme.titleMedium),
            Obx(() => DropdownButton<String>(
                  value: controller.localeCode.value,
                  items: const [
                    DropdownMenuItem(value: 'vi_VN', child: Text('Tiếng Việt')),
                    DropdownMenuItem(value: 'en_US', child: Text('English')),
                    DropdownMenuItem(value: 'zh_CN', child: Text('中文')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changeLocale(value);
                      final localeParts = value.split('_');
                      Get.updateLocale(Locale(localeParts[0], localeParts[1]));
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
