part of 'app_pages.dart';

abstract class Routes {
  static const home = _Paths.home;
  static const characterList = _Paths.characterList;
  static const writingPractice = _Paths.writingPractice;
}

abstract class _Paths {
  static const home = '/home';
  static const characterList = '/character-list';
  static const writingPractice = '/writing-practice';
}
