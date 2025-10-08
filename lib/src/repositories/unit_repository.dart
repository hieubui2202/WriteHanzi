import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit.dart';

class UnitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _unitsCollection = FirebaseFirestore.instance.collection('units');

  Stream<List<Unit>> getUnits() {
    return _unitsCollection.orderBy('order').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Unit.fromJson({...data, 'id': doc.id});
      }).toList();
    });
  }

  // Admin function to add a unit
  Future<void> addUnit(Unit unit) {
    return _unitsCollection.doc(unit.id).set(unit.toJson());
  }
}
