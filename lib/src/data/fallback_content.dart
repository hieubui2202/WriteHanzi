import 'package:myapp/src/models/hanzi_character.dart';
import 'package:myapp/src/models/unit.dart';

/// Bundled fallback content that mirrors the admin TSV example provided by the
/// product brief. The app will surface these units/characters whenever the
/// Firestore queries return nothing (for example when the project is still
/// being wired up locally or a guest session has limited permissions).
class FallbackContent {
  FallbackContent._();

  static final HanziCharacter _waterCharacter = HanziCharacter(
    id: 'char_water',
    hanzi: '水',
    pinyin: 'shuǐ',
    meaning: 'water',
    unitId: 'unit_1',
    ttsUrl:
        'https://d1vq87e9lcf771.cloudfront.net/xiuying/fd2cb29ebd4da887ea3908c8b324cc1d',
    strokeData: StrokeData(
      width: 109,
      height: 109,
      paths: const [
        'M 52.77,15.08 C 53.85,16.16,54.44,17.57,54.53,20.60 C 54.93,35.15,54.27,82.76,54.27,87.72 C 54.27,97.50,46.75,87.75,45.25,86.50',
        'M 17.50,45.75 C 19.25,46.37,21.23,46.18,22.75,45.75 C 25.88,44.88,36.09,41.00,38.59,40.00 C 41.09,39.00,43.06,41.24,42.34,43.50 C 39.00,54.00,28.25,69.00,19.00,74.75',
        'M 81.22,27.50 C 81.00,28.75,80.50,29.75,79.70,30.47 C 74.06,35.57,67.25,40.25,57.25,44.25',
        'M 57.00,46.00 C 65.82,56.73,76.23,67.46,85.42,73.42 C 87.58,74.82,89.94,76.42,92.50,77.00',
      ],
    ),
  );

  static final Unit _waterUnit = Unit(
    id: 'unit_1',
    title: 'Section 1 · Unit 1',
    description: 'Làm quen với chữ 水',
    order: 1,
    characters: const ['char_water'],
    xpReward: 10,
    sectionId: 'section_1_unit_1',
    sectionNumber: 1,
    unitNumber: 1,
  );

  /// Pre-baked set of units used when Firestore is unavailable.
  static List<Unit> get units => [_waterUnit];

  /// Returns the bundled characters for the provided [unitId].
  static List<HanziCharacter> charactersForUnit(String unitId) {
    if (unitId == _waterUnit.id) {
      return [_waterCharacter];
    }
    return const [];
  }

  /// Attempts to look up a bundled character by its identifier.
  static HanziCharacter? characterById(String id) {
    if (id == _waterCharacter.id || id == _waterCharacter.hanzi) {
      return _waterCharacter;
    }
    return null;
  }
}
