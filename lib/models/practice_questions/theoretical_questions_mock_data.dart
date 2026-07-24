import 'package:pina/models/practice_questions/theoretical_questions_models.dart';

/// Temporary mock questions for UI-first implementation.
///
/// IMPORTANT:
/// - UI should only depend on this file's exported data.
/// - Later backend integration should replace the content of this data source
///   (or the import) without changing UI code.
class TheoreticalQuestionsMockData {
  const TheoreticalQuestionsMockData._();

  static List<TheoreticalQuestion> getQuestions({
    required String selectedClass,
    required String selectedSubjectId,
    required String selectedUnitId,
    required String selectedChapterId,
    required String selectedQuestionType,
  }) {
    // Deterministic mock list. Filter logic remains purely in the UI.
    // You can later replace this method to call backend.
    return const [
      TheoreticalQuestion(
        questionId: 'tq-1',
        questionText: 'Define the term “Relations”.',
        marks: 1,
        difficulty: TheoreticalQuestionDifficulty.easy,
        answer: 'A relation is a set of ordered pairs that represent a mapping between elements.',
        explanation: 'Relations can be described as relationships between two sets using ordered pairs.',
      ),
      TheoreticalQuestion(
        questionId: 'tq-2',
        questionText: 'What is the difference between a function and a relation?',
        marks: 2,
        difficulty: TheoreticalQuestionDifficulty.easy,
        answer: 'A function assigns exactly one output to each input, while a relation may assign multiple outputs.',
        explanation: 'In a function, each domain element must map to a single codomain element.',
      ),
      TheoreticalQuestion(
        questionId: 'tq-3',
        questionText: 'Explain the concept of domain and range with an example.',
        marks: 3,
        difficulty: TheoreticalQuestionDifficulty.medium,
        answer: 'Domain is the set of input values and range is the set of output values produced by the relation.',
        explanation: 'For any ordered pair (x, y) in a relation, x belongs to domain and y belongs to range.',
      ),
      TheoreticalQuestion(
        questionId: 'tq-4',
        questionText: 'Describe the properties of a well-defined relation.',
        marks: 5,
        difficulty: TheoreticalQuestionDifficulty.hard,
        answer: 'A relation is well-defined when its ordered pairs are clearly specified and valid for the given sets.',
        explanation: 'Well-defined relations ensure every included ordered pair is consistent with the underlying sets.',
      ),
      TheoreticalQuestion(
        questionId: 'tq-5',
        questionText: 'How can you represent a relation using a mapping diagram?',
        marks: 2,
        difficulty: TheoreticalQuestionDifficulty.medium,
        answer: 'Draw arrows from each element in the domain to its related elements in the codomain.',
        explanation: 'A mapping diagram visually shows which domain elements relate to which codomain elements.',
      ),
      TheoreticalQuestion(
        questionId: 'tq-6',
        questionText: 'State and explain the concept of composition of relations.',
        marks: 1,
        difficulty: TheoreticalQuestionDifficulty.easy,
        answer: 'Composition of relations combines two relations so that outputs of the first become inputs of the second.',
        explanation: 'If (a, b) is in R and (b, c) is in S, then (a, c) is in the composition S∘R.',
      ),
      TheoreticalQuestion(
        questionId: 'tq-7',
        questionText: 'Compare equivalence relations and partial order relations.',
        marks: 5,
        difficulty: TheoreticalQuestionDifficulty.hard,
        answer: 'Equivalence relations are reflexive, symmetric, and transitive; partial orders are reflexive, antisymmetric, and transitive.',
        explanation: 'These properties distinguish how elements relate under different relation types.',
      ),
    ];
  }
}

