
import 'package:cloud_firestore/cloud_firestore.dart';

// Represents the data structure for a single Chinese character lesson,
// matching the structure in the Firestore 'characters' collection.
class HanziCharacter {
  final String id;          // The document ID from Firestore (e.g., '七_七月')
  final String character;   // The single Chinese character (e.g., '七')
  final String word;        // The full word or phrase (e.g., '七月')
  final String pinyin;      // The pinyin pronunciation (e.g., 'qīyuè')
  final String meaning;     // The English meaning (e.g., 'July')
  final String section;     // The section/unit identifier (e.g., 'Section 3, Unit 25')
  final int strokes;        // The number of strokes in the character
  final List<String> svgList; // List of SVG paths for stroke animations
  final String ttsUrl;      // URL for the Text-to-Speech audio

  HanziCharacter({
    required this.id,
    required this.character,
    required this.word,
    required this.pinyin,
    required this.meaning,
    required this.section,
    required this.strokes,
    required this.svgList,
    required this.ttsUrl,
  });

  // Factory constructor to create a HanziCharacter from a Firestore document.
  factory HanziCharacter.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HanziCharacter(
      id: doc.id,
      character: data['character'] ?? '',
      word: data['word'] ?? '',
      pinyin: data['pinyin'] ?? '',
      meaning: data['meaning'] ?? '',
      section: data['section'] ?? '',
      strokes: data['strokes'] ?? 0,
      svgList: List<String>.from(data['svgList'] ?? []),
      ttsUrl: data['ttsUrl'] ?? '',
    );
  }
}
