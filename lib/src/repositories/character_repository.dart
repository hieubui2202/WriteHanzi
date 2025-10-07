import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hanzi_character.dart';
import 'fallback_content.dart';

class CharacterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _charactersCollection = FirebaseFirestore.instance.collection('characters');

  Stream<List<HanziCharacter>> getCharactersForUnit(String unitId) async* {
    try {
      await for (final snapshot
          in _charactersCollection.where('unitId', isEqualTo: unitId).snapshots()) {
        final characters = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final stroke = data['strokeData'];
          StrokeData strokeData;
          if (stroke is Map<String, dynamic>) {
            strokeData = StrokeData.fromJson(stroke);
          } else {
            final width = data['strokeWidth'];
            final height = data['strokeHeight'];
            final paths = data['strokePaths'] ?? data['paths'] ?? const <dynamic>[];
            strokeData = StrokeData(
              width: width is int
                  ? width
                  : width is num
                      ? width.toInt()
                      : 1024,
              height: height is int
                  ? height
                  : height is num
                      ? height.toInt()
                      : 1024,
              paths: paths is Iterable
                  ? paths.map((e) => e.toString()).toList()
                  : <String>[],
            );
          }

          final id = (data['id'] as String?)?.trim().isNotEmpty == true ? data['id'] as String : doc.id;

          return HanziCharacter(
            id: id,
            hanzi: data['hanzi'] as String? ?? data['character'] as String? ?? id,
            pinyin: data['pinyin'] as String? ?? '',
            meaning: data['meaning'] as String? ?? '',
            unitId: data['unitId'] as String? ?? unitId,
            ttsUrl: data['ttsUrl'] as String?,
            strokeData: strokeData,
          );
        }).toList();

        if (characters.isEmpty) {
          yield FallbackContent.charactersForUnit(unitId);
        } else {
          yield characters;
        }
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'unauthenticated') {
        yield FallbackContent.charactersForUnit(unitId);
        return;
      }
      rethrow;
    } catch (_) {
      yield FallbackContent.charactersForUnit(unitId);
    }
  }

   // Admin function to add a character
  Future<void> addCharacter(HanziCharacter character) {
    return _charactersCollection.doc(character.hanzi).set(character.toJson());
  }
}
