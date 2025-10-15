import 'package:get/get.dart';
import 'package:myapp/app/modules/home/home_binding.dart';
import 'package:myapp/app/modules/home/home_screen.dart';
import 'package:myapp/app/modules/character_list/character_list_binding.dart';
import 'package:myapp/app/modules/character_list/character_list_screen.dart';
import 'package:myapp/app/modules/writing_practice/writing_practice_binding.dart';
import 'package:myapp/app/modules/writing_practice/writing_practice_view.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: _Paths.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.characterList,
      page: () => const CharacterListScreen(),
      binding: CharacterListBinding(),
    ),
    GetPage(
      name: _Paths.writingPractice,
      page: () => const WritingPracticeView(),
      binding: WritingPracticeBinding(),
    ),
  ];
}
