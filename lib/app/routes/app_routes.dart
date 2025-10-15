
part of 'app_pages.dart';

// Abstract class for route names to avoid using raw strings.
abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const WRITING_PRACTICE = _Paths.WRITING_PRACTICE;
}

abstract class _Paths {
  static const HOME = '/home';
  static const WRITING_PRACTICE = '/writing-practice';
}
