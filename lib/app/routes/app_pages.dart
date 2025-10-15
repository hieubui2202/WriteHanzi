import 'package:get/get.dart';
import 'package:myapp/app/modules/build_hanzi/build_hanzi_binding.dart';
import 'package:myapp/app/modules/build_hanzi/build_hanzi_view.dart';
import 'package:myapp/app/modules/character_list/character_list_binding.dart';
import 'package:myapp/app/modules/character_list/character_list_screen.dart';
import 'package:myapp/app/modules/home/home_binding.dart';
import 'package:myapp/app/modules/home/home_screen.dart';
import 'package:myapp/app/modules/missing_stroke/missing_stroke_binding.dart';
import 'package:myapp/app/modules/missing_stroke/missing_stroke_view.dart';
import 'package:myapp/app/modules/practice_result/practice_result_binding.dart';
import 'package:myapp/app/modules/practice_result/practice_result_view.dart';
import 'package:myapp/presentation/controllers/write_one_hanzi_binding.dart';
import 'package:myapp/presentation/pages/write_one_hanzi_page.dart';

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
      page: () => const WriteOneHanziPage(),
      binding: WriteOneHanziBinding(),
    ),
    GetPage(
      name: _Paths.missingStroke,
      page: () => const MissingStrokePage(),
      binding: MissingStrokeBinding(),
    ),
    GetPage(
      name: _Paths.buildHanzi,
      page: () => const BuildHanziPage(),
      binding: BuildHanziBinding(),
    ),
    GetPage(
      name: _Paths.practiceResult,
      page: () => const PracticeResultPage(),
      binding: PracticeResultBinding(),
    ),
  ];
}
