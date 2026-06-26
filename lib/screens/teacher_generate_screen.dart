import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/generate_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';






// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📄 teacher_generate_screen.dart
// PINA App — Teacher AI Content Generator
// Same visual system as student generate_screen.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Subject → Chapter mapping (shared with student screen) ──
const Map<String, List<String>> kTeacherSubjectChapters = {
  'Mathematics': [
    'Algebra', 'Trigonometry', 'Calculus', 'Statistics',
    'Probability', 'Coordinate Geometry', 'Matrices & Determinants',
    'Differential Equations', 'Vectors',
  ],
  'Physics': [
    'Mechanics', 'Thermodynamics', 'Waves & Oscillations',
    'Electrostatics', 'Current Electricity', 'Magnetism',
    'Optics', 'Modern Physics', 'Semiconductors',
  ],
  'Chemistry': [
    'Atomic Structure', 'Chemical Bonding', 'Thermochemistry',
    'Equilibrium', 'Organic Chemistry Basics', 'Electrochemistry',
    'Coordination Compounds', 'Polymers',
  ],
  'Biology': [
    'Cell Biology', 'Genetics', 'Evolution',
    'Human Physiology', 'Plant Physiology', 'Ecology',
    'Biotechnology', 'Reproduction',
  ],
  'English': [
    'Prose', 'Poetry', 'Grammar', 'Writing Skills',
    'Literature', 'Comprehension',
  ],
  'History': [
    'Ancient India', 'Medieval India', 'Modern India',
    'World Wars', 'Independence Movement', 'Post-Independence',
  ],
  'Geography': [
    'Physical Geography', 'Human Geography', 'Indian Geography',
    'Climate', 'Resources', 'Disasters',
  ],
  'Computer Science': [
    'Programming Basics', 'Data Structures', 'Algorithms',
    'Databases', 'Networking', 'Operating Systems', 'OOP',
  ],
  'Economics': [
    'Microeconomics', 'Macroeconomics', 'Money & Banking',
    'National Income', 'Public Finance', 'International Trade',
  ],
};

const List<String> kTeacherClasses = [
  'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10',
  'Class 11', 'Class 12', 'Undergraduate',
];

// ADD BOARD LIST ✅
const List<String> kTeacherBoards = [
  'CBSE',
  'ICSE',
  'State Board',
  'IB',
  'Cambridge',
];

const List<String> kDifficultyLevels = ['Easy', 'Medium', 'Hard'];

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🏠 MAIN SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeacherGenerateScreen extends StatefulWidget {
  const TeacherGenerateScreen({super.key});

  @override
  State<TeacherGenerateScreen> createState() => _TeacherGenerateScreenState();
}

class _TeacherGenerateScreenState extends State<TeacherGenerateScreen>
    with SingleTickerProviderStateMixin {

  // ── Parameters ───────────────────────────────────────────────
  String _selectedSubject = 'Physics';
  String _selectedClass   = 'Class 11';
  String _selectedChapter = 'Mechanics';
  String _selectedBoard = 'CBSE'; // ADD STATE VARIABLE ✅
  final TextEditingController _teachingGoalCtrl = TextEditingController();

  // ── Content Type ─────────────────────────────────────────────
  // 0=Lesson Plan  1=Question Paper  2=Worksheet
  // 3=Assessment   4=Revision Notes  5=PPT Outline
  int _contentType = 0;

  // ── Assessment / Question Paper options ──────────────────────
  // Visible only when contentType == 1 (Question Paper) or 3 (Assessment)
  String? _difficultyLevel;
  bool _mcqSelected          = false;
  bool _shortAnswerSelected  = false;
  bool _longAnswerSelected   = false;
  bool _caseStudySelected    = false;
  final TextEditingController _marksCtrl = TextEditingController();

  // ── Additional Instructions ──────────────────────────────────
  final TextEditingController _instructionCtrl = TextEditingController();

  // ── Output ───────────────────────────────────────────────────
  bool _isGenerating    = false;
  String? _generatedOutput;
  final ScrollController _scrollCtrl = ScrollController();

  // ── Notification restore / highlight ─────────────────────────
  bool _highlightOutput = false;
  Timer? _highlightTimer;

  // ── SharedPreferences keys for centralized restore ─────────
  static const String _kPendingOutputIdKey = 'pending_output_id';
  static const String _kPendingRequestTypeKey = 'pending_request_type';
  static const String _kPendingScreenKey = 'pending_screen';

  // ── Pulse animation ──────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;


  // Returns true when the assessment options card should be shown
  bool get _showAssessmentOptions => _contentType == 1 || _contentType == 3;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _restoreFromPendingNotificationIfAny();
  }


  Future<void> _restoreFromPendingNotificationIfAny() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final pendingScreen = prefs.getString(_kPendingScreenKey) ?? '';
      if (pendingScreen != 'teacher_generate') return;

      final outputId = prefs.getString(_kPendingOutputIdKey) ?? '';
      if (outputId.isEmpty) return;

      // optional: read but do not use for restore per requirements
      // final pendingRequestType = prefs.getString(_kPendingRequestTypeKey) ?? '';

      final endpoint = '${ApiConstants.authUrl}/api/generate/output/$outputId';

      final res = await http.get(Uri.parse(endpoint));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        print('❌ OUTPUT RESTORE FAILED: ${res.statusCode}');
        return;
      }

      final decoded = jsonDecode(res.body);
      final restoredOutput = decoded['output']?.toString() ?? decoded['data']?.toString() ?? '';
      if (restoredOutput.isEmpty) {
        print('❌ OUTPUT RESTORE FAILED: empty output');
        return;
      }

      if (!mounted) return;
      setState(() {
        _generatedOutput = restoredOutput;
        _isGenerating = false;
      });

      // Clear payload ONLY AFTER successful restore.
      await prefs.remove(_kPendingOutputIdKey);
      await prefs.remove(_kPendingRequestTypeKey);
      await prefs.remove(_kPendingScreenKey);



      await Future.delayed(const Duration(milliseconds: 350));
      if (_scrollCtrl.hasClients) {
        await _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }

      if (!mounted) return;
      setState(() => _highlightOutput = true);
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _highlightOutput = false);
      });
    } catch (e) {
      print('❌ OUTPUT RESTORE ERROR: $e');
    }
  }




  @override
  void dispose() {
    _pulseCtrl.dispose();
    _teachingGoalCtrl.dispose();
    _instructionCtrl.dispose();
    _marksCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Generate ─────────────────────────────────────────────────
  Future<void> _onGenerate() async {
    print('🚀 GENERATION STARTED');
    HapticFeedback.lightImpact();




    setState(() {
      _isGenerating = true;
      _generatedOutput = null;
    });

    final contentTypeString = switch (_contentType) {
      0 => 'lesson_plan',
      1 => 'question_paper',
      2 => 'worksheet',
      3 => 'assessment',
      4 => 'revision_notes',
      5 => 'ppt_outline',
      _ => 'lesson_plan',
    };

    // FIX teacherContext 🔥 - using REAL selected board
    final teacherContext = {
      'teacherTypes': [],
      'teachingMode': [],
      'languages': [],
      'boards': [_selectedBoard], // ✅ FIXED: using real board
      'location': {},
      'institutions': [],
      'educationLevels': [],
      'classes': [_selectedClass],
      'classesByLevel': {},
      'subjects': [_selectedSubject],
      'selectedClass': _selectedClass,
      'teachingGoal': _teachingGoalCtrl.text.trim(),
    };

    final params = {
      'subject': _selectedSubject,
      'selectedClass': _selectedClass,
      'chapter': _selectedChapter,
      'contentType': contentTypeString,
      'teachingGoal': _teachingGoalCtrl.text.trim(),
      'difficultyLevel': _difficultyLevel,
      'questionTypes': [
        if (_mcqSelected) 'mcq',
        if (_shortAnswerSelected) 'short_answer',
        if (_longAnswerSelected) 'long_answer',
        if (_caseStudySelected) 'case_study',
      ],
      'marksDistribution': _marksCtrl.text.trim(),
      'additionalInstructions': _instructionCtrl.text.trim(),
      'board': _selectedBoard, // ✅ OPTIONAL: backend filtering ke liye
    };

    try {
      final response = await GenerateService.generateTeacherContent(
        teacherContext: teacherContext,
        params: params,
      );

      if (response['success'] == true) {
        final output = response['output'] ?? '';

        setState(() {
          _isGenerating = false;
          _generatedOutput = output;
        });

        print('✅ GENERATION COMPLETED');


      } else {

        setState(() {
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Generation failed',
            ),
            backgroundColor: Colors.redAccent.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Auto-scroll to output
      await Future.delayed(const Duration(milliseconds: 250));
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildContextBadge(),
                  const SizedBox(height: 14),
                  _buildParametersCard(),
                  const SizedBox(height: 14),
                  _buildContentTypeSection(),
                  const SizedBox(height: 14),

                  // Assessment options — only for Question Paper / Assessment
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    child: _showAssessmentOptions
                        ? Column(
                            children: [
                              _buildAssessmentOptionsCard(),
                              const SizedBox(height: 14),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  _buildInstructionsCard(),
                  const SizedBox(height: 20),
                  _buildGenerateButton(),
                  const SizedBox(height: 28),
                  _buildOutputSection(),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 1 — HEADER  (identical layout to student screen)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TemplateTheme.primary,
                TemplateTheme.primary.withOpacity(0.55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: TemplateTheme.primary.withOpacity(0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teacher Generate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: TemplateTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Create lesson plans, worksheets, assessments and classroom content using AI.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: TemplateTheme.textMuted,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 2 — TEACHER CONTEXT BADGE (Updated with real values)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildContextBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TemplateTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TemplateTheme.primary.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.person_rounded, size: 16, color: TemplateTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '👨‍🏫  $_selectedSubject Teacher  ·  $_selectedBoard', // ✅ Updated with real values
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TemplateTheme.textPrimary,
                letterSpacing: 0.1,
              ),
            ),
          ),
          // REMOVE UPDATE BUTTON ❌ - Deleted the entire GestureDetector
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 3 — PARAMETERS CARD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildParametersCard() {
    final chapters =
        kTeacherSubjectChapters[_selectedSubject] ?? ['General Topics'];
    final safeChapter =
        chapters.contains(_selectedChapter) ? _selectedChapter : chapters.first;

    return _TGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TSectionLabel(icon: Icons.tune_rounded, text: 'Parameters'),
          const SizedBox(height: 14),

          // Subject
          _TPinaDropdown<String>(
            label: 'Subject',
            value: _selectedSubject,
            hint: 'Select subject',
            items: kTeacherSubjectChapters.keys.toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _selectedSubject = v;
                _selectedChapter =
                    kTeacherSubjectChapters[v]!.first;
              });
            },
          ),
          const SizedBox(height: 12),

          // ADD BOARD DROPDOWN 🔥
          _TPinaDropdown<String>(
            label: 'Board',
            value: _selectedBoard,
            hint: 'Select board',
            items: kTeacherBoards,
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _selectedBoard = v;
              });
            },
          ),
          const SizedBox(height: 12),

          // Class / Standard
          _TPinaDropdown<String>(
            label: 'Class / Standard',
            value: _selectedClass,
            hint: 'Select class',
            items: kTeacherClasses,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _selectedClass = v);
            },
          ),
          const SizedBox(height: 12),

          // Chapter / Topic
          _TPinaDropdown<String>(
            label: 'Chapter / Topic',
            value: safeChapter,
            hint: 'Select chapter',
            items: chapters,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _selectedChapter = v);
            },
          ),
          const SizedBox(height: 12),

          // Teaching goal text field
          _TFieldLabel(text: 'Teaching Goal'),
          const SizedBox(height: 6),
          _TPinaTextField(
            controller: _teachingGoalCtrl,
            hint: 'Explain difficult concepts in a simple classroom-friendly way',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 4 — CONTENT TYPE  (6 options in Wrap — mobile safe)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildContentTypeSection() {
    const types = <_TContentTypeData>[
      _TContentTypeData('🧑‍🏫', 'Lesson\nPlan',       'Structured teaching flow'),
      _TContentTypeData('📝', 'Question\nPaper',    'Exam-ready questions'),
      _TContentTypeData('📄', 'Worksheet',          'Practice sheets'),
      _TContentTypeData('📊', 'Assessment',         'MCQ + subjective eval'),
      _TContentTypeData('📘', 'Revision\nNotes',    'Quick recap material'),
      _TContentTypeData('🖥', 'PPT\nOutline',       'Slide-wise structure'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TSectionLabel(icon: Icons.category_rounded, text: 'Content Type'),
        const SizedBox(height: 10),

        // LayoutBuilder gives us the real available width
        LayoutBuilder(
          builder: (context, constraints) {
            // 3 cards per row, with spacing of 8 between them
            const spacing    = 8.0;
            const perRow     = 3;
            final cardWidth  =
                (constraints.maxWidth - spacing * (perRow - 1)) / perRow;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(types.length, (i) {
                final isSelected = _contentType == i;
                return SizedBox(
                  width: cardWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _contentType = i),
                      borderRadius: BorderRadius.circular(14),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    TemplateTheme.primary.withOpacity(0.22),
                                    TemplateTheme.primary.withOpacity(0.06),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : null,
                          color: isSelected
                              ? null
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? TemplateTheme.primary.withOpacity(0.75)
                                : Colors.white.withOpacity(0.1),
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: TemplateTheme.primary
                                        .withOpacity(0.22),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(types[i].emoji,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 6),
                            Text(
                              types[i].label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? TemplateTheme.primary
                                    : TemplateTheme.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              types[i].description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.35,
                                color: TemplateTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 5 — ASSESSMENT OPTIONS  (visible only for QP / Assessment)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildAssessmentOptionsCard() {
    return _TGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TSectionLabel(
              icon: Icons.quiz_rounded, text: 'Assessment Options'),
          const SizedBox(height: 14),

          // Difficulty
          _TPinaDropdown<String>(
            label: 'Difficulty Level',
            value: _difficultyLevel,
            hint: 'Select difficulty',
            items: kDifficultyLevels,
            onChanged: (v) => setState(() => _difficultyLevel = v),
          ),
          const SizedBox(height: 14),

          // Question types chips
          _TFieldLabel(text: 'QUESTION TYPES'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TSelectableChip(
                label: 'MCQ',
                icon: Icons.radio_button_checked_rounded,
                selected: _mcqSelected,
                onTap: () =>
                    setState(() => _mcqSelected = !_mcqSelected),
              ),
              _TSelectableChip(
                label: 'Short Answer',
                icon: Icons.short_text_rounded,
                selected: _shortAnswerSelected,
                onTap: () => setState(
                    () => _shortAnswerSelected = !_shortAnswerSelected),
              ),
              _TSelectableChip(
                label: 'Long Answer',
                icon: Icons.article_rounded,
                selected: _longAnswerSelected,
                onTap: () => setState(
                    () => _longAnswerSelected = !_longAnswerSelected),
              ),
              _TSelectableChip(
                label: 'Case Study',
                icon: Icons.cases_rounded,
                selected: _caseStudySelected,
                onTap: () => setState(
                    () => _caseStudySelected = !_caseStudySelected),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Marks distribution
          _TFieldLabel(text: 'Marks Distribution'),
          const SizedBox(height: 6),
          _TPinaTextField(
            controller: _marksCtrl,
            hint: 'e.g. 20 MCQ + 5 subjective questions',
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 6 — ADDITIONAL INSTRUCTIONS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildInstructionsCard() {
    return _TGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TSectionLabel(
              icon: Icons.lightbulb_outline_rounded,
              text: 'Additional Instructions'),
          const SizedBox(height: 10),
          _TPinaTextField(
            controller: _instructionCtrl,
            hint:
                'e.g. Include HOTS questions\nAdd classroom activities\nKeep language simple\nFocus on board pattern',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 7 — GENERATE BUTTON
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Transform.scale(
        scale: _isGenerating ? 1.0 : _pulseAnim.value,
        child: child,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isGenerating ? null : _onGenerate,
          style: TemplateTheme.primaryButtonStyle(),
          child: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('⚡', style: TextStyle(fontSize: 17)),
                    SizedBox(width: 8),
                    Text(
                      'Generate',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // § 8 — OUTPUT SECTION
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildOutputSection() {
    // Shimmer while generating
    if (_isGenerating) {
      return _TGlassCard(child: _TShimmerLoading());
    }

    // Empty state
    if (_generatedOutput == null) {
      return _TGlassCard(
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 36,
              color: TemplateTheme.textMuted.withOpacity(0.35),
            ),
            const SizedBox(height: 10),
            Text(
              'Your generated content will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: TemplateTheme.textMuted.withOpacity(0.55),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    // Output card with copy button
    return _TGlassCard(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          boxShadow: _highlightOutput
              ? [
                  BoxShadow(
                    color: TemplateTheme.primary.withOpacity(0.55),
                    blurRadius: 26,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _TSectionLabel(
                    icon: Icons.article_rounded, text: 'Generated Output'),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: _generatedOutput!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Copied ✓'),
                        backgroundColor: TemplateTheme.primary,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: Container(

                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: TemplateTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            TemplateTheme.primary.withOpacity(0.28)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 13, color: TemplateTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxHeight: 340),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.white.withOpacity(0.07)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _generatedOutput!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: TemplateTheme.textPrimary,
                  height: 1.7,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
     ) );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🧱 SHARED WIDGETS  (prefixed _T to avoid conflicts if both
//    screens are imported in the same build)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ─── Glass Card ──────────────────────────────────────────────
class _TGlassCard extends StatelessWidget {
  final Widget child;
  const _TGlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: TemplateTheme.glassPanel(
        color: Colors.white,
        opacity: 0.18,
        radius: 18,
      ),
      child: child,
    );
  }
}

// ─── Section Label ────────────────────────────────────────────
class _TSectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TSectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: TemplateTheme.primary),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: TemplateTheme.textPrimary,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

// ─── Field Label ─────────────────────────────────────────────
class _TFieldLabel extends StatelessWidget {
  final String text;
  const _TFieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: TemplateTheme.textMuted,
        letterSpacing: 0.7,
      ),
    );
  }
}

// ─── Dropdown ─────────────────────────────────────────────────
class _TPinaDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _TPinaDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TFieldLabel(text: label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 13,
                  color: TemplateTheme.textMuted.withOpacity(0.5),
                ),
              ),
              dropdownColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.85)
                  : Colors.white.withOpacity(0.95),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: TemplateTheme.textMuted,
                size: 20,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: TemplateTheme.textPrimary,
              ),
              items: items
                  .map((item) => DropdownMenuItem<T>(
                        value: item,
                        child: Text(item.toString()),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Text Field ───────────────────────────────────────────────
class _TPinaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _TPinaTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 13,
        color: TemplateTheme.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          color: TemplateTheme.textMuted.withOpacity(0.5),
          height: 1.6,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: TemplateTheme.primary.withOpacity(0.65),
              width: 1.5),
        ),
      ),
    );
  }
}

// ─── Selectable Chip ─────────────────────────────────────────
class _TSelectableChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TSelectableChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(colors: [
                    TemplateTheme.primary.withOpacity(0.28),
                    TemplateTheme.primary.withOpacity(0.1),
                  ])
                : null,
            color: selected ? null : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? TemplateTheme.primary.withOpacity(0.7)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: selected
                      ? TemplateTheme.primary
                      : TemplateTheme.textMuted),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? TemplateTheme.primary
                      : TemplateTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Loading ─────────────────────────────────────────
class _TShimmerLoading extends StatefulWidget {
  @override
  State<_TShimmerLoading> createState() => _TShimmerLoadingState();
}

class _TShimmerLoadingState extends State<_TShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final op = 0.05 + _ctrl.value * 0.09;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 15, color: TemplateTheme.primary),
                const SizedBox(width: 7),
                Text(
                  'Generating...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TemplateTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TemplateTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...[0.92, 0.78, 0.88, 0.62, 0.74].map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FractionallySizedBox(
                  widthFactor: w,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(op),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Content type descriptor ─────────────────────────────────
class _TContentTypeData {
  final String emoji;
  final String label;
  final String description;
  const _TContentTypeData(this.emoji, this.label, this.description);
}