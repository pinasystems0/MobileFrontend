import 'package:flutter/foundation.dart';

/// UI-first model for Theoretical Questions.
@immutable
class TheoreticalQuestion {
  final String questionId;
  final String questionText;
  final int marks;
  final TheoreticalQuestionDifficulty difficulty;

  /// Optional placeholder values for now.
  final String? answer;
  final String? explanation;

  const TheoreticalQuestion({
    required this.questionId,
    required this.questionText,
    required this.marks,
    required this.difficulty,
    this.answer,
    this.explanation,
  });
}

@immutable
enum TheoreticalQuestionDifficulty {
  easy,
  medium,
  hard,
}

extension TheoreticalQuestionDifficultyX on TheoreticalQuestionDifficulty {
  String get label {
    switch (this) {
      case TheoreticalQuestionDifficulty.easy:
        return 'Easy';
      case TheoreticalQuestionDifficulty.medium:
        return 'Medium';
      case TheoreticalQuestionDifficulty.hard:
        return 'Hard';
    }
  }
}

