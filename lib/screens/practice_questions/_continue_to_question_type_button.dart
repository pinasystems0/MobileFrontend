import 'package:flutter/material.dart';

import 'package:pina/models/practice_questions/practice_questions_models.dart';
import 'package:pina/screens/practice_questions/question_type_selection_screen.dart';

import 'package:pina/ui_template/utils/template_theme.dart';

class ContinueToQuestionTypeButton extends StatelessWidget {
  final String selectedStandard;
  final Subject? selectedSubject;
  final String? expandedUnitId;
  final String? selectedChapterId;

  const ContinueToQuestionTypeButton({
    super.key,
    required this.selectedStandard,
    required this.selectedSubject,
    required this.expandedUnitId,
    required this.selectedChapterId,
  });

  @override
  Widget build(BuildContext context) {
    final canContinue = selectedChapterId != null && selectedSubject != null && expandedUnitId != null;

    final unit = selectedSubject?.units.where((u) => u.id == expandedUnitId).cast<Unit?>().firstWhere((e) => e != null, orElse: () => null);

    final chapter = selectedChapterId == null
        ? null
        : unit?.chapters.where((c) => c.id == selectedChapterId).cast<Chapter?>().firstWhere((e) => e != null, orElse: () => null);

    final effectiveUnit = unit;
    final effectiveChapter = chapter;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: TemplateTheme.glassPanel(
        color: Colors.white,
        opacity: 0.78,
        radius: 24,
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: TemplateTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Continue',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: TemplateTheme.textPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: canContinue && effectiveUnit != null && effectiveChapter != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionTypeSelectionScreen(
                          selectedClass: selectedStandard,
                          selectedSubject: selectedSubject!,
                          selectedUnit: effectiveUnit!,
                          selectedChapter: effectiveChapter!,
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

