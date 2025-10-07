import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit.dart';

class UnitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _unitsCollection = FirebaseFirestore.instance.collection('units');

  Stream<List<Unit>> getUnits() {
    return _unitsCollection.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Unit.fromJson(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  // Admin function to add a unit
  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toJson());
  }
}
