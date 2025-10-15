import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/unit.dart';

class UnitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference<Map<String, dynamic>> _unitsCollection =
      FirebaseFirestore.instance.collection('units');

  Stream<List<Unit>> getUnits() {
    return _unitsCollection.snapshots().map((snapshot) {
      final units = snapshot.docs
          .map((doc) => Unit.fromMap(doc.data(), id: doc.id))
          .toList();
      units.sort((a, b) => a.sortKey.compareTo(b.sortKey));
      return units;
    });
  }

  Stream<Unit?> getUnitById(String id) {
    return _unitsCollection.doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Unit.fromMap(snapshot.data()!, id: snapshot.id);
    });
  }

  // Admin function to add a unit
  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toMap());
  }
}
