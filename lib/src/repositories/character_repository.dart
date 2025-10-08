import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/src/models/hanzi_character.dart';

class CharacterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _charactersCollection =
      FirebaseFirestore.instance.collection('characters');

  Stream<List<HanziCharacter>> getCharactersForUnit(String unitId) {
    return _charactersCollection.where('unitId', isEqualTo: unitId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => HanziCharacter.fromJson(doc.data() as Map<String, dynamic>).copyWithId(doc.id))
          .toList();
    });
  }

  // Admin function to add a character
  Future<void> addCharacter(HanziCharacter character) {
    return _charactersCollection.doc(character.hanzi).set(character.toJson());
  }
}
