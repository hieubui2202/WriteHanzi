
import 'package:myapp/app/data/models/lesson_model.dart';

// Represents a major section of the learning path, containing multiple lessons.
class Section {
  final String id;
  final String title;
  final List<Lesson> lessons;

  Section({required this.id, required this.title, required this.lessons});
}
