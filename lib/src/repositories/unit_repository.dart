import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/unit.dart';
import 'fallback_content.dart';

class UnitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _unitsCollection = FirebaseFirestore.instance.collection('units');

  Stream<List<Unit>> getUnits() async* {
    try {
      await for (final snapshot in _unitsCollection.orderBy('order').snapshots()) {
        final units = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final id = (data['id'] as String?)?.trim().isNotEmpty == true ? data['id'] as String : doc.id;
          final title = data['title'] as String? ?? data['unitName'] as String? ?? 'Bài học';
          final description = data['description'] as String? ?? '';
          final orderValue = data['order'];
          final order = orderValue is int
              ? orderValue
              : orderValue is num
                  ? orderValue.toInt()
                  : 0;
          final xpValue = data['xpReward'];
          final xpReward = xpValue is int
              ? xpValue
              : xpValue is num
                  ? xpValue.toInt()
                  : 0;
          final rawCharacters = data['characters'] ?? data['characterIds'] ?? const <dynamic>[];
          final characterList = rawCharacters is Iterable
              ? rawCharacters.map((e) => e.toString()).toList()
              : <String>[];

          return Unit(
            id: id,
            title: title,
            description: description,
            order: order,
            characters: characterList,
            xpReward: xpReward,
          );
        }).toList();

        if (units.isEmpty) {
          yield FallbackContent.units;
        } else {
          yield units;
        }
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied' || e.code == 'unauthenticated') {
        yield FallbackContent.units;
        return;
      }
      rethrow;
    } catch (_) {
      yield FallbackContent.units;
    }
  }

  // Admin function to add a unit
  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toJson());
  }
}
