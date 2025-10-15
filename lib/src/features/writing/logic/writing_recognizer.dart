import 'dart:ui';

import 'package:myapp/src/models/hanzi_character.dart';

class WritingRecognizer {
  // A simple recognizer based on point count.
  // This remains a placeholder until a full recogniser is implemented.
  static double calculateScore(
    List<List<Offset?>> userStrokes,
    List<String> expectedStrokePaths,
  ) {
    if (expectedStrokePaths.isEmpty) {
      // If we do not have reference data we cannot judge the attempt.
      return userStrokes.isNotEmpty ? 50.0 : 0.0;
    }

    if (userStrokes.length != expectedStrokePaths.length) {
      return 0.0;
    }

    // In a real scenario, the actual stroke geometry should be compared here.
    return 85.0;
  }
}
