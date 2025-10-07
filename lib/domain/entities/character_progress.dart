import 'package:equatable/equatable.dart';

class CharacterProgress extends Equatable {
  const CharacterProgress({
    required this.completed,
    required this.score,
    required this.mistakes,
    required this.lastReview,
  });

  final bool completed;
  final double score;
  final int mistakes;
  final DateTime? lastReview;

  CharacterProgress copyWith({
    bool? completed,
    double? score,
    int? mistakes,
    DateTime? lastReview,
  }) {
    return CharacterProgress(
      completed: completed ?? this.completed,
      score: score ?? this.score,
      mistakes: mistakes ?? this.mistakes,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  @override
  List<Object?> get props => [completed, score, mistakes, lastReview];
}
