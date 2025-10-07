import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProgressCache {
  ProgressCache(this._prefs);

  final SharedPreferences _prefs;

  static const _unitsKey = 'cached_units';
  static const _charactersKey = 'cached_characters';
  static const _profileKey = 'cached_profile';

  Future<void> cacheUnits(List<Map<String, dynamic>> units) async {
    await _prefs.setString(_unitsKey, json.encode(units));
  }

  List<Map<String, dynamic>>? readUnits() {
    final raw = _prefs.getString(_unitsKey);
    if (raw == null) return null;
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> cacheCharacters(List<Map<String, dynamic>> characters) async {
    await _prefs.setString(_charactersKey, json.encode(characters));
  }

  List<Map<String, dynamic>>? readCharacters() {
    final raw = _prefs.getString(_charactersKey);
    if (raw == null) return null;
    final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> cacheProfile(Map<String, dynamic> profile) async {
    await _prefs.setString(_profileKey, json.encode(profile));
  }

  Map<String, dynamic>? readProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) return null;
    return json.decode(raw) as Map<String, dynamic>;
  }
}
