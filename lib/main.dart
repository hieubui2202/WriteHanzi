import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bindings/app_bindings.dart';
import 'core/localization/app_translations.dart';
import 'core/theme/app_theme.dart';
import 'data/cache/progress_cache.dart';
import 'firebase_options.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/pages/auth/auth_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/lesson_intro/lesson_intro_page.dart';
import 'presentation/pages/meaning_choice/meaning_choice_page.dart';
import 'presentation/pages/missing_stroke/missing_stroke_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/result/result_page.dart';
import 'presentation/pages/review/review_page.dart';
import 'presentation/pages/settings/settings_page.dart';
import 'presentation/pages/splash/routes.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/stroke_demo/stroke_demo_page.dart';
import 'presentation/pages/writing/writing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  final prefs = await SharedPreferences.getInstance();
  Get.put<ProgressCache>(ProgressCache(prefs), permanent: true);
  Get.put(SettingsController(), permanent: true);
  runApp(const WriteHanziApp());
}

class WriteHanziApp extends StatelessWidget {
  const WriteHanziApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    return Obx(() {
      final localeParts = settings.localeCode.value.split('_');
      final locale = Locale(localeParts[0], localeParts.length > 1 ? localeParts[1] : null);
      return GetMaterialApp(
        title: 'WriteHanzi',
        theme: AppTheme.buildTheme(),
        translations: AppTranslations(),
        locale: locale,
        fallbackLocale: const Locale('vi', 'VN'),
        initialBinding: AppBindings(),
        initialRoute: AppRoutes.splash,
        getPages: [
          SplashPage.route,
          AuthPage.route,
          HomePage.route,
          LessonIntroPage.route,
          MeaningChoicePage.route,
          StrokeDemoPage.route,
          WritingPage.route,
          MissingStrokePage.route,
          ResultPage.route,
          ReviewPage.route,
          ProfilePage.route,
          SettingsPage.route,
        ],
      );
    });
  }
}
