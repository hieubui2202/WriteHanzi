import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../cache/progress_cache.dart';
import '../datasources/firestore_character_data_source.dart';
import '../datasources/local_sample_data_source.dart';
import '../models/character_model.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  CharacterRepositoryImpl({
    required FirebaseFirestore firestore,
    required ProgressCache cache,
    LocalSampleDataSource? localDataSource,
  })  : _remote = FirestoreCharacterDataSource(firestore),
        _cache = cache,
        _local = localDataSource ?? const LocalSampleDataSource();

  final FirestoreCharacterDataSource _remote;
  final ProgressCache _cache;
  final LocalSampleDataSource _local;

  List<Character> _cachedCharacters = const [];

  @override
  Future<List<Character>> fetchCharacters() async {
    if (_cachedCharacters.isNotEmpty) {
      return _cachedCharacters;
    }

    try {
      final characters = await _remote.fetchCharacters();
      _cachedCharacters = characters;
      await _cache.cacheCharacters(
        characters
            .map((c) => CharacterModel(
                  hanzi: c.hanzi,
                  pinyin: c.pinyin,
                  meaning: c.meaning,
                  unitId: c.unitId,
                  ttsUrl: c.ttsUrl,
                  strokeData: c.strokeData,
                ).toJson())
            .toList(),
      );
      return characters;
    } catch (_) {
      final cached = _cache.readCharacters();
      if (cached != null) {
        _cachedCharacters = cached
            .map((item) => CharacterModel.fromJson(item))
            .toList();
        return _cachedCharacters;
      }
      final fallback = await _local.loadCharacters();
      _cachedCharacters = fallback;
      return fallback;
    }
  }

  @override
  Future<List<Character>> fetchCharactersByUnit(String unitId) async {
    final characters = await fetchCharacters();
    return characters.where((c) => c.unitId == unitId).toList();
  }
}
