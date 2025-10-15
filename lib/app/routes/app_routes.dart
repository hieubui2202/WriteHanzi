part of 'app_pages.dart';

abstract class Routes {
  static const home = _Paths.home;
  static const characterList = _Paths.characterList;
  static const writingPractice = _Paths.writingPractice;
  static const missingStroke = _Paths.missingStroke;
  static const buildHanzi = _Paths.buildHanzi;
  static const practiceResult = _Paths.practiceResult;
}

abstract class _Paths {
  static const home = '/home';
  static const characterList = '/character-list';
  static const writingPractice = '/writing-practice';
  static const missingStroke = '/missing-stroke';
  static const buildHanzi = '/build-hanzi';
  static const practiceResult = '/practice-result';
}
