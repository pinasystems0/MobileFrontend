import 'package:flutter/material.dart';
import 'package:pina/screens/practice_questions/practice_questions_service.dart';
import 'package:pina/models/practice_questions/practice_questions_models.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

import 'package:pina/screens/practice_questions/theoretical_questions_screen.dart';
import 'package:pina/screens/practice_questions/competency_based_questions_screen.dart';

// Temporary UI-first implementation.

// Backend integration will replace `mockSyllabus` and the UI will call
// PracticeQuestionsService.fetchSyllabus(...) when ready.


class PracticeQuestionsScreen extends StatefulWidget {
  const PracticeQuestionsScreen({super.key});

  @override
  State<PracticeQuestionsScreen> createState() => _PracticeQuestionsScreenState();
}

class _PracticeQuestionsScreenState extends State<PracticeQuestionsScreen> {
  final List<String> _standards = const ['Class 9', 'Class 10', 'Class 11', 'Class 12'];

  String _selectedStandard = 'Class 11';
  String _query = '';

  String? _selectedSubjectId;
  String? _expandedUnitId;
  String? _selectedChapterId;

  // Mock data that mirrors: Subject → Unit → Chapter.
  // Replace later with API response.
  late List<Subject> _syllabus;

  @override
  void initState() {
    super.initState();
    _syllabus = PracticeQuestionsService.getMockSyllabus();
  }


  List<Subject> get _filteredSubjects {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _syllabus;
    return _syllabus
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
  }

  void _onSelectStandard(String standard) {
    setState(() {
      _selectedStandard = standard;
      _query = '';
      _selectedSubjectId = null;
      _expandedUnitId = null;
      _selectedChapterId = null;

      // Temporary: standard switching reads the class-wise mock syllabus.
      _syllabus = PracticeQuestionsService.getMockSyllabusForClass(standard);
    });
  }

  Subject? get _selectedSubject =>
      _syllabus.where((s) => s.id == _selectedSubjectId).cast<Subject?>().firstOrNull;

  @override
  Widget build(BuildContext context) {
    final selectedSubject = _selectedSubject;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateLayout(
        brandTitle: 'Arthum AI',
        brandSubtitle: 'Practice Questions',
        sectionTitle: 'Practice Questions',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),

              // Hero section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: TemplateTheme.glassPanel(
                  color: Colors.white,
                  opacity: 0.78,
                  radius: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                          child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Class-wise practice sets',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: TemplateTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Select class → subject → unit → chapter',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TemplateTheme.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Standard/Class selector
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
                    const Text(
                      'Standard / Class',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _standards.map((s) {
                        final isSel = s == _selectedStandard;
                        return GestureDetector(
                          onTap: () => _onSelectStandard(s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSel ? TemplateTheme.primary.withOpacity(0.14) : Theme.of(context).dividerColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSel
                                    ? TemplateTheme.primary.withOpacity(0.55)
                                    : Theme.of(context).dividerColor.withOpacity(0.10),
                                width: isSel ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              s.split(' ').last,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSel ? TemplateTheme.primary : TemplateTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search + body lists
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: TemplateTheme.glassPanel(
                          color: Colors.white,
                          opacity: 0.78,
                          radius: 24,
                        ),
                        child: TextField(
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Search subjects...',
                            hintStyle: TextStyle(
                              color: TemplateTheme.textMuted.withOpacity(0.6),
                              fontSize: 12,
                            ),
                            prefixIcon: Icon(Icons.search_rounded, color: TemplateTheme.primary),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Subject list
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
                            const Text(
                              'Subjects',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: TemplateTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_filteredSubjects.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'No subjects found.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TemplateTheme.textMuted.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._filteredSubjects.map((subject) {
                                final isSelected = subject.id == _selectedSubjectId;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSubjectId = subject.id;
                                      _expandedUnitId = null;
                                      _selectedChapterId = null;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? TemplateTheme.primary.withOpacity(0.12) : Theme.of(context).dividerColor.withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? TemplateTheme.primary.withOpacity(0.55)
                                            : Theme.of(context).dividerColor.withOpacity(0.10),
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.book_rounded,
                                          size: 18,
                                          color: isSelected ? TemplateTheme.primary : TemplateTheme.textMuted,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            subject.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: TemplateTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle_rounded, color: TemplateTheme.primary, size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Units (expand/collapse)
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
                            const Text(
                              'Units',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: TemplateTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (selectedSubject == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Text(
                                    'Select a subject to see units.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: TemplateTheme.textMuted.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...selectedSubject.units.map((unit) {
                                final isExpanded = unit.id == _expandedUnitId;
                                return _UnitAccordion(
                                  title: unit.name,
                                  count: unit.chapters.length,
                                  expanded: isExpanded,
                                  onTap: () {
                                    setState(() {
                                      _expandedUnitId = isExpanded ? null : unit.id;
                                      _selectedChapterId = null;
                                    });
                                  },
                                  children: isExpanded
                                      ? [
_ChapterList(
                                            chapters: unit.chapters,
                                            selectedChapterId: _selectedChapterId,
                                            onSelect: (chapterId) {
                                              setState(() => _selectedChapterId = chapterId);
                                            },
                                            selectedStandard: _selectedStandard,
                                            selectedSubject: selectedSubject,
                                            selectedUnit: unit,
                                          ),
                                          const SizedBox(height: 8),
                                        ]
                                      : const [],
                                );
                              }).toList(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),




                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitAccordion extends StatelessWidget {
  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onTap;
  final List<Widget> children;

  const _UnitAccordion({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: expanded ? TemplateTheme.primary.withOpacity(0.12) : Theme.of(context).dividerColor.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: expanded
                    ? TemplateTheme.primary.withOpacity(0.55)
                    : Theme.of(context).dividerColor.withOpacity(0.10),
                width: expanded ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.layers_rounded,
                    size: 18,
                    color: expanded ? TemplateTheme.primary : TemplateTheme.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TemplateTheme.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: TemplateTheme.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: TemplateTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: TemplateTheme.primary,
                ),
              ],
            ),
          ),
        ),
        if (expanded) ...children,
        const SizedBox(height: 10),
      ],
    );
  }
}

class _ChapterList extends StatelessWidget {
  final List<Chapter> chapters;
  final String? selectedChapterId;
  final ValueChanged<String> onSelect;

  final String selectedStandard;
  final Subject? selectedSubject;
  final Unit? selectedUnit;

  const _ChapterList({
    required this.chapters,
    required this.selectedChapterId,
    required this.onSelect,
    required this.selectedStandard,
    required this.selectedSubject,
    required this.selectedUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chapters.map((ch) {
        final isSelected = ch.id == selectedChapterId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => onSelect(ch.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? TemplateTheme.primary.withOpacity(0.14) : Theme.of(context).dividerColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? TemplateTheme.primary.withOpacity(0.55)
                        : Theme.of(context).dividerColor.withOpacity(0.10),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.article_rounded,
                      size: 18,
                      color: isSelected ? TemplateTheme.primary : TemplateTheme.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ch.name,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded, color: TemplateTheme.primary, size: 18),
                  ],
                ),
              ),
            ),

            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    _QuestionTypeOptionTile(
                      title: '📘 Theoretical Questions',
                      icon: Icons.menu_book_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
MaterialPageRoute(
                            builder: (_) => TheoreticalQuestionsScreen(
                              selectedClass: selectedStandard,
                              selectedSubject: selectedSubject!,
                              selectedUnit: selectedUnit!,
                              selectedChapter: ch,
                              selectedQuestionType: 'theoretical',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    _QuestionTypeOptionTile(
                      title: '🎯 Competency Based Questions',
                      icon: Icons.gps_fixed_rounded,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CompetencyBasedQuestionsScreen(
                              selectedClass: selectedStandard,
                              selectedSubject: selectedSubject!,
                              selectedUnit: selectedUnit!,
                              selectedChapter: ch,
                              selectedQuestionType: 'competency_based',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _QuestionTypeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuestionTypeOptionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: TemplateTheme.softCard(
            color: Colors.white.withOpacity(0.92),
            radius: 18,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TemplateTheme.primary.withOpacity(0.18),
                      TemplateTheme.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: TemplateTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}



