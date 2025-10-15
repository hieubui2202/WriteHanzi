
import 'package:myapp/app/data/models/hanzi_character.dart';

// This is the contract that the data layer must follow.
// The domain layer only depends on this abstract interface, not the concrete implementation.
// This allows us to swap out the data source (e.g., from Firestore to a local DB)
// without changing the domain or presentation layers.
abstract class ICharacterRepository {
  Future<List<HanziCharacter>> getCharacters({int limit = 20});
  // In the future, we might add methods like:
  // Future<HanziCharacter> getCharacterById(String id);
  // Future<void> updateUserProgress(String userId, String characterId);
}
