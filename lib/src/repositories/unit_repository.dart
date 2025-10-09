import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/src/data/fallback_content.dart';
import 'package:myapp/src/models/unit.dart';

class UnitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _unitsCollection = FirebaseFirestore.instance.collection('units');

  Stream<List<Unit>> getUnits() async* {
    try {
      await for (final snapshot in _unitsCollection.snapshots()) {
        if (snapshot.docs.isEmpty) {
          debugPrint('No units returned from Firestore, using bundled fallback content.');
          yield FallbackContent.units;
          continue;
        }

        final units = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Unit.fromFirestore(doc.id, data);
        }).toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        yield units;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load units from Firestore: $error\n$stackTrace');
      yield FallbackContent.units;
    }
  }

  // Admin function to add a unit
  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toJson());
  }
}
