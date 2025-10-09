import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';

class PracticePayload {
  const PracticePayload({required this.unit, required this.character});

  final Unit unit;
  final HanziCharacter character;
}
