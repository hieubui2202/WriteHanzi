import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/character.dart';
import '../models/character_model.dart';

class FirestoreCharacterDataSource {
  FirestoreCharacterDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Character>> fetchCharacters() async {
    final snapshot = await _firestore.collection('characters').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['hanzi'] = doc.id;
      return CharacterModel.fromJson(data);
    }).toList();
  }

  Future<List<Character>> fetchCharactersByUnit(String unitId) async {
    final snapshot = await _firestore
        .collection('characters')
        .where('unitId', isEqualTo: unitId)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['hanzi'] = doc.id;
      return CharacterModel.fromJson(data);
    }).toList();
  }
}
