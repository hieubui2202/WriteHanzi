import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/src/models/unit.dart';

class UnitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _unitsCollection = FirebaseFirestore.instance.collection('units');

  Stream<List<Unit>> getUnits() {
    return _unitsCollection.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      final units = docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Unit.fromFirestore(doc.id, data);
      }).toList();

      units.sort((a, b) => a.order.compareTo(b.order));
      debugPrint('Loaded ${units.length} units from Firestore');
      return units;
    });
  }

  // Admin function to add a unit
  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toJson());
  }
}
