import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/app/data/models/chapter_model.dart';
import 'package:myapp/app/data/models/lesson_model.dart';
import 'package:myapp/app/data/models/hanzi_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all chapters from Firestore
  Future<List<Chapter>> getChapters() async {
    try {
      final snapshot = await _firestore.collection('chapters').orderBy('id').get();
      final chapters = snapshot.docs.map((doc) => Chapter.fromMap(doc.data())).toList();
      return chapters;
    } catch (e) {
      // In a real app, you'd handle this error more gracefully
      print("Error fetching chapters: $e");
      return [];
    }
  }

  // Fetch lessons for a specific chapter from Firestore
  Future<List<Lesson>> getLessonsForChapter(String chapterId) async {
    try {
      final snapshot = await _firestore
          .collection('chapters')
          .doc(chapterId)
          .collection('lessons')
          .orderBy('id')
          .get();

      // This is a bit more complex because we need to handle the characters array.
      // For now, we will assume the characters are stored as a list of maps.
      final lessons = snapshot.docs.map((doc) {
        final data = doc.data();
        final List<dynamic> characterData = data['characters'] ?? [];
        final characters = characterData.map((charMap) => Hanzi(
          id: charMap['id'] ?? '',
          character: charMap['character'] ?? '',
          pinyin: charMap['pinyin'] ?? '',
          meaning: charMap['meaning'] ?? '',
        )).toList();

        return Lesson(
          id: data['id'] ?? '',
          title: data['title'] ?? '',
          characters: characters,
        );
      }).toList();

      return lessons;
    } catch (e) {
      print("Error fetching lessons: $e");
      return [];
    }
  }
}
