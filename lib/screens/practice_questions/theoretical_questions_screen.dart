import 'package:flutter/material.dart';
import 'package:pina/models/practice_questions/practice_questions_models.dart';
import 'package:pina/models/practice_questions/theoretical_questions_mock_data.dart';
import 'package:pina/models/practice_questions/theoretical_questions_models.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/widgets/practice_questions/theoretical_question_card.dart';

class TheoreticalQuestionsScreen extends StatefulWidget {
  final String selectedClass;
  final Subject selectedSubject;
  final Unit selectedUnit;
  final Chapter selectedChapter;
  final String selectedQuestionType;

  const TheoreticalQuestionsScreen({
    super.key,
    required this.selectedClass,
    required this.selectedSubject,
    required this.selectedUnit,
    required this.selectedChapter,
    required this.selectedQuestionType,
  });

  @override
  State<TheoreticalQuestionsScreen> createState() => _TheoreticalQuestionsScreenState();
}

class _TheoreticalQuestionsScreenState extends State<TheoreticalQuestionsScreen> {
  final _searchController = TextEditingController();

  String _query = '';
  TheoreticalQuestionDifficulty? _selectedDifficulty;
  int? _selectedMarks;

  late final List<TheoreticalQuestion> _allQuestions;

  @override
  void initState() {
    super.initState();

    _allQuestions = TheoreticalQuestionsMockData.getQuestions(
      selectedClass: widget.selectedClass,
      selectedSubjectId: widget.selectedSubject.id,
      selectedUnitId: widget.selectedUnit.id,
      selectedChapterId: widget.selectedChapter.id,
      selectedQuestionType: widget.selectedQuestionType,
    );
  }

  List<TheoreticalQuestion> get _filteredQuestions {
    final q = _query.trim().toLowerCase();

    return _allQuestions.where((item) {
      final matchesQuery = q.isEmpty || item.questionText.toLowerCase().contains(q);
      final matchesDifficulty =
          _selectedDifficulty == null || item.difficulty == _selectedDifficulty;
      final matchesMarks = _selectedMarks == null || item.marks == _selectedMarks;

      return matchesQuery && matchesDifficulty && matchesMarks;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateLayout(
        brandTitle: 'Arthum AI',
        brandSubtitle: 'Practice Questions',
        sectionTitle: 'Theoretical Questions',
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
                        'Selected',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.selectedClass,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Class', value: widget.selectedClass),
                      _InfoRow(label: 'Subject', value: widget.selectedSubject.name),
                      _InfoRow(label: 'Unit', value: widget.selectedUnit.name),
                      _InfoRow(label: 'Chapter', value: widget.selectedChapter.name),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Search + filters
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
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'Search questions...',
                          hintStyle: TextStyle(
                            color: TemplateTheme.textMuted.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: TemplateTheme.primary),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _FilterChip<TheoreticalQuestionDifficulty>(
                            label: 'Easy',
                            value: TheoreticalQuestionDifficulty.easy,
                            selected: _selectedDifficulty == TheoreticalQuestionDifficulty.easy,
                            onSelected: (v) => setState(() => _selectedDifficulty = v),
                          ),
                          _FilterChip<TheoreticalQuestionDifficulty>(
                            label: 'Medium',
                            value: TheoreticalQuestionDifficulty.medium,
                            selected: _selectedDifficulty == TheoreticalQuestionDifficulty.medium,
                            onSelected: (v) => setState(() => _selectedDifficulty = v),
                          ),
                          _FilterChip<TheoreticalQuestionDifficulty>(
                            label: 'Hard',
                            value: TheoreticalQuestionDifficulty.hard,
                            selected: _selectedDifficulty == TheoreticalQuestionDifficulty.hard,
                            onSelected: (v) => setState(() => _selectedDifficulty = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final m in const [1, 2, 3, 5])
                            _FilterChip<int>(
                              label: '$m',
                              value: m,
                              selected: _selectedMarks == m,
                              onSelected: (v) => setState(() => _selectedMarks = v),
                            ),
                        ],
                      ),

                      if (_selectedDifficulty != null || _selectedMarks != null || _query.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() {
                              _query = '';
                              _searchController.clear();
                              _selectedDifficulty = null;
                              _selectedMarks = null;
                            }),
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: TemplateTheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: _filteredQuestions.isEmpty
                      ? Center(
                          child: Text(
                            'No questions match your search/filters.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: TemplateTheme.textMuted.withOpacity(0.75),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 22),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, i) {
                            final item = _filteredQuestions[i];
                            return TheoreticalQuestionCard(
                              questionNumber: i + 1,
                              question: item,
                            );
                          },
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

class _FilterChip<T> extends StatelessWidget {
  final String label;
  final T value;
  final bool selected;
  final ValueChanged<T> onSelected;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? TemplateTheme.primary.withOpacity(0.14) : Theme.of(context).dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? TemplateTheme.primary.withOpacity(0.55) : Theme.of(context).dividerColor.withOpacity(0.10),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: selected ? TemplateTheme.primary : TemplateTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}


