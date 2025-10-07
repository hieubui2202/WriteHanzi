import '../entities/unit_model.dart';

abstract class UnitRepository {
  Future<List<UnitModel>> fetchUnits();
}
