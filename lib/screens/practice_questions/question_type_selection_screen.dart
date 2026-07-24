import 'package:flutter/material.dart';
import 'package:pina/models/practice_questions/practice_questions_models.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

import 'theoretical_questions_screen.dart';
import 'competency_based_questions_screen.dart';

// NOTE: This file intentionally uses only Flutter/Template widgets
// to keep the existing design language consistent across the app.


class QuestionTypeSelectionScreen extends StatelessWidget {
  final String selectedClass;
  final Subject selectedSubject;
  final Unit selectedUnit;
  final Chapter selectedChapter;

  const QuestionTypeSelectionScreen({
    super.key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedUnit,
    required this.selectedChapter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateLayout(
        brandTitle: 'Arthum AI',
        brandSubtitle: 'Practice Questions',
        sectionTitle: 'Question Type',
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
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
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
                        selectedClass,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: TemplateTheme.textMuted.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        selectedSubject.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            icon: Icons.layers_rounded,
                            label: selectedUnit.name,
                          ),
                          _MetaChip(
                            icon: Icons.article_rounded,
                            label: selectedChapter.name,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Select question type',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: TemplateTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _QuestionTypeCard(
                          title: '📘 Theoretical Questions',
                          subtitle: 'Concepts, explanations, and understanding',
                          icon: Icons.menu_book_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TheoreticalQuestionsScreen(
                                  selectedClass: selectedClass,
                                  selectedSubject: selectedSubject,
                                  selectedUnit: selectedUnit,
                                  selectedChapter: selectedChapter,
                                  selectedQuestionType: 'theoretical',
                                ),
                              ),
                            );
                          },
                        ),


                        const SizedBox(height: 12),

                        _QuestionTypeCard(
                          title: '🎯 Competency Based Questions',
                          subtitle: 'Practice for skills and competency',
icon: Icons.gps_fixed_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
builder: (_) => CompetencyBasedQuestionsScreen(
                                  selectedClass: selectedClass,
                                  selectedSubject: selectedSubject,
                                  selectedUnit: selectedUnit,
                                  selectedChapter: selectedChapter,
                                  selectedQuestionType: 'competency_based',
                                ),

                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),
                      ],
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TemplateTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: TemplateTheme.primary.withOpacity(0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: TemplateTheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: TemplateTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuestionTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: TemplateTheme.softCard(
            color: Colors.white.withOpacity(0.92),
            radius: 24,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TemplateTheme.primary.withOpacity(0.22),
                      TemplateTheme.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: TemplateTheme.primary.withOpacity(0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: TemplateTheme.textMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: TemplateTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

