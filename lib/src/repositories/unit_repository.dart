import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/unit.dart';

class UnitRepository {
  UnitRepository()
      : _unitsCollection = FirebaseFirestore.instance.collection('units');

  final CollectionReference<Map<String, dynamic>> _unitsCollection;

  Stream<List<Unit>> getUnits() {
    return _unitsCollection.snapshots().map((snapshot) {
      final units = snapshot.docs
          .map((doc) => Unit.fromFirestore(doc.data(), doc.id))
          .toList();
      units.sort((a, b) => a.order.compareTo(b.order));
      return units;
    });
  }

  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toJson());
  }
}
