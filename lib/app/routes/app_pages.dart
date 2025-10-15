
import 'package:get/get.dart';
import 'package:myapp/app/modules/home/home_binding.dart';
import 'package:myapp/app/modules/home/home_view.dart';
import 'package:myapp/app/modules/writing_practice/writing_practice_binding.dart';
import 'package:myapp/app/modules/writing_practice/writing_practice_view.dart';

part 'app_routes.dart';

// This class holds the configuration for all the pages/routes in the app.
class AppPages {
  AppPages._();

  // The initial route to be loaded when the app starts.
  static const INITIAL = Routes.HOME;

  // The list of all pages with their routes, views, and bindings.
  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.WRITING_PRACTICE,
      page: () => const WritingPracticeView(),
      binding: WritingPracticeBinding(),
      // Using a custom transition for a smoother feel
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
