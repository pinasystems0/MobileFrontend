import 'package:flutter/material.dart';
import 'package:pina/models/practice_questions/practice_questions_models.dart';

// Service layer for Practice Questions.
// Models are sourced from:
// lib/models/practice_questions/practice_questions_models.dart

class PracticeQuestionsService {
  const PracticeQuestionsService._();

  /// Temporary mock syllabus used by the UI until API is connected.
  static List<Subject> getMockSyllabus() => mockSyllabus;

  /// Class-wise mock syllabus used by the UI until API is connected.
  static List<Subject> getMockSyllabusForClass(String standard) =>
      mockSyllabusByClass[standard] ?? mockSyllabus;


  /// Placeholder action until the real chapter/practice screen exists.
  static void openChapterPlaceholder(BuildContext context, String chapterId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Chapter opened (placeholder): $chapterId'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}



