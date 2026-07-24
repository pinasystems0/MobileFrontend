import 'package:flutter/material.dart';
import 'package:pina/models/practice_questions/practice_questions_models.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class CompetencyBasedQuestionsScreen extends StatelessWidget {
  final String selectedClass;
  final Subject selectedSubject;
  final Unit selectedUnit;
  final Chapter selectedChapter;
  final String selectedQuestionType;

  const CompetencyBasedQuestionsScreen({
    super.key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedUnit,
    required this.selectedChapter,
    required this.selectedQuestionType,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateLayout(
        brandTitle: 'Arthum AI',
        brandSubtitle: 'Practice Questions',
        sectionTitle: 'Competency Based Questions',
        leading: Container(
          decoration: TemplateTheme.glassPanel(
            color: Colors.white,
            opacity: 0.56,
            radius: 20,
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: TemplateTheme.glassPanel(
                    color: Colors.white,
                    opacity: 0.78,
                    radius: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Class',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedClass,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Selected Subject', value: selectedSubject.name),
                      _InfoRow(label: 'Selected Unit', value: selectedUnit.name),
                      _InfoRow(label: 'Selected Chapter', value: selectedChapter.name),
_InfoRow(label: 'Selected Question Type', value: selectedQuestionType),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Center(
                    child: Text(
                      'Questions will be loaded from the backend.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textMuted.withOpacity(0.95),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: TemplateTheme.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: TemplateTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

