import 'package:myapp/app/data/models/hanzi_character.dart';

class Lesson {
  final String id;
  final String title;
  final List<HanziCharacter> characters;

  Lesson({
    required this.id,
    required this.title,
    required this.characters,
  });
}
