import '../entities/character.dart';

abstract class CharacterRepository {
  Future<List<Character>> fetchCharacters();
  Future<List<Character>> fetchCharactersByUnit(String unitId);
}
