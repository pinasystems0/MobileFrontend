import 'package:flutter/material.dart';
import 'package:pina/models/practice_questions/theoretical_questions_models.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class TheoreticalQuestionCard extends StatefulWidget {
  final int questionNumber;
  final TheoreticalQuestion question;

  const TheoreticalQuestionCard({
    super.key,
    required this.questionNumber,
    required this.question,
  });

  @override
  State<TheoreticalQuestionCard> createState() => _TheoreticalQuestionCardState();
}

class _TheoreticalQuestionCardState extends State<TheoreticalQuestionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    final diffColor = switch (q.difficulty) {
      TheoreticalQuestionDifficulty.easy => Colors.green,
      TheoreticalQuestionDifficulty.medium => Colors.orange,
      TheoreticalQuestionDifficulty.hard => Colors.red,
    };

    final answerText = q.answer ?? 'Answer will be available soon.';
    final explanationText = q.explanation ?? 'Explanation will be available soon.';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: TemplateTheme.softCard(
        color: Colors.white.withOpacity(0.92),
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Question number + question text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PillBadge(
                text: 'Q${widget.questionNumber}',
                color: TemplateTheme.primary,
                isPrimary: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  q.questionText,
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Meta badges: Marks + Difficulty
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _PillBadge(
                text: '${q.marks} Marks',
                color: TemplateTheme.primary,
                isPrimary: false,
              ),
              _PillBadge(
                text: q.difficulty.label,
                color: diffColor,
                isPrimary: false,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Expand/collapse trigger (animated arrow + animated container height)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(
                      _expanded ? 'Hide Answer' : 'Show Answer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: TemplateTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TemplateTheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: _expanded ? const BoxConstraints() : const BoxConstraints(),
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 18, thickness: 1),
                          _AnswerBlock(label: 'Answer', value: answerText),
                          const SizedBox(height: 10),
                          _AnswerBlock(
                            label: 'Explanation',
                            value: explanationText,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isPrimary;

  const _PillBadge({
    required this.text,
    required this.color,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isPrimary ? color.withOpacity(0.10) : color.withOpacity(0.08);
    final border = isPrimary ? color.withOpacity(0.35) : color.withOpacity(0.20);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _AnswerBlock extends StatelessWidget {
  final String label;
  final String value;

  const _AnswerBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: TemplateTheme.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          softWrap: true,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.4,
            fontWeight: FontWeight.w800,
            color: TemplateTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}


