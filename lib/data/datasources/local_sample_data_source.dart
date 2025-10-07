import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/character.dart';
import '../../domain/entities/unit_model.dart';
import '../models/character_model.dart';
import '../models/unit_model_data.dart';

class LocalSampleDataSource {
  const LocalSampleDataSource();

  Future<List<UnitModel>> loadUnits() async {
    final content = await rootBundle.loadString('assets/data/sample_units.json');
    final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
    return jsonList.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final id = map['id']?.toString() ?? '';
      return UnitModelData.fromJson(map, id);
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Future<List<Character>> loadCharacters() async {
    final content = await rootBundle.loadString('assets/data/sample_characters.json');
    final List<dynamic> jsonList = json.decode(content) as List<dynamic>;
    return jsonList
        .map((item) => CharacterModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
