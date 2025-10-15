import 'package:myapp/app/data/models/hanzi_model.dart';

class Lesson {
  final String id;
  final String title;
  final List<Hanzi> characters;

  Lesson({
    required this.id,
    required this.title,
    required this.characters,
  });

  // Add this factory constructor
  factory Lesson.fromMap(Map<String, dynamic> map) {
    var characterList = <Hanzi>[];
    if (map['characters'] != null) {
      // Firestore typically returns a List<dynamic> for arrays
      var charactersAsDynamic = map['characters'] as List<dynamic>;
      characterList = charactersAsDynamic.map((charMap) {
        // Ensure each item in the list is treated as a Map
        var charData = charMap as Map<String, dynamic>;
        return Hanzi(
          id: charData['id'] ?? '',
          character: charData['character'] ?? '',
          pinyin: charData['pinyin'] ?? '',
          meaning: charData['meaning'] ?? '',
        );
      }).toList();
    }

    return Lesson(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      characters: characterList,
    );
  }
}
