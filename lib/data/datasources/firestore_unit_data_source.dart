import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/unit_model.dart';
import '../models/unit_model_data.dart';

class FirestoreUnitDataSource {
  FirestoreUnitDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<UnitModel>> fetchUnits() async {
    final snapshot = await _firestore.collection('units').orderBy('order').get();
    return snapshot.docs
        .map((doc) => UnitModelData.fromJson(doc.data(), doc.id))
        .toList();
  }
}
