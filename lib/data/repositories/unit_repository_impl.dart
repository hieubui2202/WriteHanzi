import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/unit_model.dart';
import '../../domain/repositories/unit_repository.dart';
import '../cache/progress_cache.dart';
import '../datasources/firestore_unit_data_source.dart';
import '../datasources/local_sample_data_source.dart';
import '../models/unit_model_data.dart';

class UnitRepositoryImpl implements UnitRepository {
  UnitRepositoryImpl({
    required FirebaseFirestore firestore,
    required ProgressCache cache,
    LocalSampleDataSource? localDataSource,
  })  : _remote = FirestoreUnitDataSource(firestore),
        _cache = cache,
        _local = localDataSource ?? const LocalSampleDataSource();

  final FirestoreUnitDataSource _remote;
  final ProgressCache _cache;
  final LocalSampleDataSource _local;

  List<UnitModel> _cachedUnits = const [];

  @override
  Future<List<UnitModel>> fetchUnits() async {
    if (_cachedUnits.isNotEmpty) {
      return _cachedUnits;
    }

    try {
      final units = await _remote.fetchUnits();
      _cachedUnits = units;
      await _cache.cacheUnits(
        units.map((u) {
          final map = UnitModelData(
            id: u.id,
            title: u.title,
            description: u.description,
            order: u.order,
            characters: u.characters,
            xpReward: u.xpReward,
          ).toJson();
          map['id'] = u.id;
          return map;
        }).toList(),
      );
      return units;
    } catch (_) {
      final cached = _cache.readUnits();
      if (cached != null) {
        _cachedUnits = cached
            .map((item) => UnitModelData.fromJson(item, item['id'].toString()))
            .toList();
        return _cachedUnits;
      }
      final fallback = await _local.loadUnits();
      _cachedUnits = fallback;
      return fallback;
    }
  }
}
