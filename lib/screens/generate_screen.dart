import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pina/services/generate_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/constants.dart';
import 'package:http/http.dart' as http;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📄 generate_screen.dart  —  PINA App
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


// ──────────────────────────────────────────────────────────────
// ENUMS
// ──────────────────────────────────────────────────────────────
enum ContentType { bridge, study, test }
enum QuestionType { mcq, longAnswer }

// ──────────────────────────────────────────────────────────────
// MODELS
// ──────────────────────────────────────────────────────────────

class StudentContextModel {
  String standard;
  String board;
  String careerGoals;
  Map<String, List<String>> timetable;

  StudentContextModel({
    this.standard = 'Class 11',
    this.board = 'CBSE',
    this.careerGoals = '',
    Map<String, List<String>>? timetable,
  }) : timetable = timetable ?? {};

  String get careerGoalsDisplay => careerGoals.length > 35
      ? '${careerGoals.substring(0, 35)}…'
      : careerGoals;

  Map<String, dynamic> toJson() => {
        'standard': standard,
        'board': board,
        'careerGoals': careerGoals,
        'timetable': timetable,
      };

  factory StudentContextModel.fromJson(Map<String, dynamic> json) =>
      StudentContextModel(
        standard: json['standard'] ?? 'Class 11',
        board: json['board'] ?? 'CBSE',
        careerGoals: json['careerGoals'] ?? '',
        timetable: (json['timetable'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        ),
      );

  bool get isComplete => standard.isNotEmpty && board.isNotEmpty;

  int get timetableSlotCount =>
      timetable.values.fold(0, (sum, s) => sum + s.length);
}

class GenerateParamsModel {
  String subject;
  String chapter;
  ContentType contentType;
  String? testType;
  bool openBook;
  Set<QuestionType> questionTypes;

  GenerateParamsModel({
    this.subject = 'All',
    this.chapter = 'All Chapters',
    this.contentType = ContentType.study,
    this.testType,
    this.openBook = false,
    Set<QuestionType>? questionTypes,
  }) : questionTypes = questionTypes ?? {};

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'chapter': chapter,
        'contentType': contentType.name,
        'testType': testType,
        'openBook': openBook,
        'questionTypes': questionTypes.map((q) => q.name).toList(),
      };
}

class GenerateRequestDTO {
  final StudentContextModel studentContext;
  final GenerateParamsModel params;
  final String prompt;

  const GenerateRequestDTO({
    required this.studentContext,
    required this.params,
    required this.prompt,
  });

  Map<String, dynamic> toJson() => {
        'studentContext': studentContext.toJson(),
        'params': params.toJson(),
        'prompt': prompt,
      };
}

// ──────────────────────────────────────────────────────────────
// CONSTANTS
// ──────────────────────────────────────────────────────────────

const Map<String, List<String>> kSubjectChapters = {
  'All': ['All Chapters'],
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
    'Prose', 'Poetry', 'Grammar', 'Writing Skills', 'Literature', 'Comprehension',
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

const List<String> kTestTypes = [
  'Semester', 'Prelims', 'Board', 'Entrance', 'Scholarship',
  'Campus Placement', 'Driving License Test', 'Bank Related Tests',
  'GRE', 'GMAT', 'IELTS',
];

const List<String> kClasses = [
  'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
  'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10',
  'Class 11', 'Class 12',
];

const List<String> kBoards = ['CBSE', 'ICSE', 'ISC', 'State Board'];

const List<String> kTimetableCategories = [
  'CLASS', 'COACHING', 'TUITION', 'SELF STUDY', 'HOBBY', 'SPORTS',
];

const List<String> kWeekDays = [
  'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
];

const String _kPrefStudentContext = 'student_context_v1';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MAIN SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with SingleTickerProviderStateMixin {

  StudentContextModel _studentContext = StudentContextModel();
  GenerateParamsModel _params = GenerateParamsModel();

  final TextEditingController _instructionCtrl = TextEditingController();
  bool _isGenerating = false;
  String? _generatedOutput;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  bool _prefsLoaded = false;

  // ── Inline Editor State ──────────────────────────────────────
  bool _showProfileEditor = false;
  bool _showCareerEditor = false;
  bool _showTimetableEditor = false;

  // Temp edit state (lives in main state, no bottom sheet needed)
  String _tempClass = 'Class 11';
  String _tempBoard = 'CBSE';
  final TextEditingController _careerCtrl = TextEditingController();
  final TextEditingController _slotCtrl = TextEditingController();
  Map<String, List<String>> _tempTimetable = {};
  String _selectedCategory = kTimetableCategories.first;
  String _selectedDay = kWeekDays.first;

  // ── Lifecycle ────────────────────────────────────────────────

  static const String _kPendingOutputIdKey = 'pending_output_id';
  static const String _kPendingRequestTypeKey = 'pending_request_type';
  static const String _kPendingScreenKey = 'pending_screen';

  static const String _kStudentScreenValue = 'student_generate';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadStudentContext();
    _restoreFromPendingNotificationIfAny();
  }

  Future<void> _restoreFromPendingNotificationIfAny() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingScreen = prefs.getString(_kPendingScreenKey);
      if (pendingScreen != _kStudentScreenValue) return;

      final outputId = prefs.getString(_kPendingOutputIdKey);
      if (outputId == null || outputId.isEmpty) return;

      print('🚀 OPENING STUDENT SCREEN');
      print('🚀 LOADING OUTPUT BY ID');

      // Uses backend GET /api/generate/output/:outputId (via existing API constants)
      final endpoint = '${ApiConstants.authUrl}/api/generate/output/$outputId';

      final res = await http.get(Uri.parse(endpoint));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        print('❌ OUTPUT RESTORE FAILED: ${res.statusCode}');
        return;
      }

      final decoded = jsonDecode(res.body);
      
      // ✅ FIXED: Properly extract nested output text from backend response
      final restoredOutput = decoded['output']?['output']?.toString() ?? '';
      
      if (restoredOutput.isEmpty) {
        print('❌ OUTPUT RESTORE FAILED: empty output');
        return;
      }

      if (!mounted) return;
      setState(() {
        _generatedOutput = restoredOutput;
        _isGenerating = false;
      });

      print('✅ OUTPUT RESTORED');

      // Clear pending payload AFTER successful restore.
      await prefs.remove(_kPendingOutputIdKey);
      await prefs.remove(_kPendingRequestTypeKey);
      await prefs.remove(_kPendingScreenKey);

      // Scroll + highlight output section.
      await Future.delayed(const Duration(milliseconds: 250));
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        );
      }

      print('🚀 SCROLLING TO OUTPUT');
      print('✅ OUTPUT HIGHLIGHTED');
      // For student screen, output highlight is already handled by a box shadow on _generatedOutput card.
      // We reuse it by setting _isGenerating false (no regeneration) and briefly toggling a highlight flag.
      // (Implementing a dedicated flag would require UI changes; leaving behavior consistent with teacher.)
    } catch (e) {
      print('❌ OUTPUT RESTORE ERROR: $e');
    }
  }


  @override
  void dispose() {
    _pulseCtrl.dispose();
    _instructionCtrl.dispose();
    _careerCtrl.dispose();
    _slotCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Sync temp state from model ───────────────────────────────

  void _syncTempFromModel() {
    _tempClass = _studentContext.standard;
    _tempBoard = _studentContext.board;
    _careerCtrl.text = _studentContext.careerGoals;
    _tempTimetable = {
      for (final e in _studentContext.timetable.entries)
        e.key: List<String>.from(e.value),
    };
  }

  // ── SharedPreferences ────────────────────────────────────────

  Future<void> _loadStudentContext() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefStudentContext);
    if (raw != null) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        setState(() {
          _studentContext = StudentContextModel.fromJson(json);
          _prefsLoaded = true;
        });
      } catch (_) {
        setState(() => _prefsLoaded = true);
      }
    } else {
      setState(() => _prefsLoaded = true);
    }
  }

  Future<void> _saveStudentContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPrefStudentContext,
      jsonEncode(_studentContext.toJson()),
    );
  }

  // ── Generate ─────────────────────────────────────────────────

  Future<void> _onGenerate() async {
    if (_params.contentType == ContentType.test && _params.testType == null) {
      _snack('Please select a Test Type.', isError: true);
      return;
    }
    if (_params.contentType == ContentType.test &&
        _params.questionTypes.isEmpty) {
      _snack('Please select at least one Question Type.', isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedOutput = null;
    });

    try {
      final response = await GenerateService.generateStudentContent(
        studentContext: _studentContext.toJson(),
        params: _params.toJson(),
        prompt: _instructionCtrl.text.trim(),
      );

      if (response['success'] == true) {
        final output = response['output'] ?? '';
        setState(() {
          _isGenerating = false;
          _generatedOutput = output;
        });

        print('✅ GENERATION COMPLETED');
        // ✅ Notification service import removed - no longer creating notifications
      } else {
        setState(() {
          _isGenerating = false;
        });
        _snack(
          response['message'] ?? 'Generation failed',
          isError: true,
        );
      }

      await Future.delayed(const Duration(milliseconds: 300));
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      _snack(e.toString(), isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent.shade700 : TemplateTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Inline Editor Helpers ────────────────────────────────────

  bool get _hasChanges =>
      _tempClass != _studentContext.standard ||
      _tempBoard != _studentContext.board ||
      _careerCtrl.text.trim() != _studentContext.careerGoals ||
      !_compareTimetable(_tempTimetable, _studentContext.timetable);

  Future<void> _saveInlineChanges() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _studentContext.standard = _tempClass;
      _studentContext.board = _tempBoard;
      _studentContext.careerGoals = _careerCtrl.text.trim();
      _studentContext.timetable = _tempTimetable;
    });

    await _saveStudentContext();

    if (!mounted) return;

    _snack('Profile updated ✓');

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    setState(() {
      _showProfileEditor = false;
      _showCareerEditor = false;
      _showTimetableEditor = false;
    });
  }

  bool _compareTimetable(
      Map<String, List<String>> a, Map<String, List<String>> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (!_listEquals(a[key]!, b[key]!)) return false;
    }
    return true;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // ──────────────────────────────────────────────────────────────
  // SECTION BUILDERS
  // ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                TemplateTheme.primary.withOpacity(0.85),
                TemplateTheme.primary.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: TemplateTheme.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: TemplateTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Choose your subject, content type, and let AI create it for you.',
                style: TextStyle(
                  fontSize: 12,
                  color: TemplateTheme.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Context Badge + Inline Editor ───────────────────────────

  Widget _buildContextBadge() {
    final slotCount = _studentContext.timetableSlotCount;
    final hasGoals = _studentContext.careerGoals.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Badge row ──
        GestureDetector(
          onTap: () {
            setState(() {
              if (!_showProfileEditor) {
                _syncTempFromModel();
              }
              _showProfileEditor = !_showProfileEditor;
              // collapse sub-editors when closing main editor
              if (!_showProfileEditor) {
                _showCareerEditor = false;
                _showTimetableEditor = false;
              }
            });
          },
          child: Container(
            decoration: TemplateTheme.glassPanel(
                color: Colors.white, opacity: 0.72, radius: 20),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TemplateTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: TemplateTheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student Context',
                        style: TextStyle(
                            fontSize: 11, color: TemplateTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_studentContext.standard} · ${_studentContext.board}'
                        '${hasGoals ? ' · ${_studentContext.careerGoalsDisplay}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      if (slotCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$slotCount timetable slot${slotCount == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: TemplateTheme.primary.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _showProfileEditor ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showProfileEditor
                          ? TemplateTheme.primary.withOpacity(0.2)
                          : TemplateTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showProfileEditor
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.edit_rounded,
                          size: 14,
                          color: TemplateTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showProfileEditor ? 'Close' : 'Update',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: TemplateTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Inline expandable editor ──
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 260),
          sizeCurve: Curves.easeInOut,
          crossFadeState: _showProfileEditor
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: _buildInlineProfileEditor(),
        ),
      ],
    );
  }

  // ── Inline Profile Editor ────────────────────────────────────

  Widget _buildInlineProfileEditor() {
    final fillColor = Theme.of(context)
        .colorScheme
        .surfaceVariant
        .withOpacity(0.35);

    final String timetableKey = '$_selectedCategory-$_selectedDay';
    final List<String> slots = _tempTimetable[timetableKey] ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: TemplateTheme.glassPanel(
          color: Colors.white, opacity: 0.72, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Icon(Icons.school_rounded,
                  color: TemplateTheme.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Class + Board ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SheetLabel(text: 'Class'),
                    const SizedBox(height: 6),
                    _SheetDropdown<String>(
                      value: _tempClass,
                      items: kClasses,
                      fillColor: fillColor,
                      onChanged: (v) {
                        if (v != null) setState(() => _tempClass = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SheetLabel(text: 'Board'),
                    const SizedBox(height: 6),
                    _SheetDropdown<String>(
                      value: _tempBoard,
                      items: kBoards,
                      fillColor: fillColor,
                      onChanged: (v) {
                        if (v != null) setState(() => _tempBoard = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Career Goal Section ──
          _buildCareerGoalSection(fillColor),
          const SizedBox(height: 18),

          // ── Timetable Section ──
          _buildTimetableSection(fillColor, timetableKey, slots),
          const SizedBox(height: 20),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasChanges ? _saveInlineChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: TemplateTheme.primary,
                disabledBackgroundColor:
                    TemplateTheme.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _hasChanges ? 'Save Changes' : 'No Changes',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Career Goal Sub-section ──────────────────────────────────

  Widget _buildCareerGoalSection(Color fillColor) {
    final hasGoal = _careerCtrl.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: label + current value + Add/Edit button
        Row(
          children: [
            const _SheetLabel(text: 'Career Goal'),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  setState(() => _showCareerEditor = !_showCareerEditor),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TemplateTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showCareerEditor
                          ? Icons.remove_rounded
                          : Icons.add_rounded,
                      size: 13,
                      color: TemplateTheme.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _showCareerEditor
                          ? 'Collapse'
                          : (hasGoal ? 'Edit' : 'Add'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Current value preview
        if (hasGoal && !_showCareerEditor) ...[
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: TemplateTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: TemplateTheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_rounded,
                    size: 14, color: TemplateTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _careerCtrl.text.trim(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: TemplateTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Expandable TextField
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          sizeCurve: Curves.easeInOut,
          crossFadeState: _showCareerEditor
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: TextField(
              controller: _careerCtrl,
              maxLines: 2,
              maxLength: 200,
              style: const TextStyle(
                fontSize: 13,
                color: TemplateTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText:
                    'e.g., IIT JEE 2026, NEET, CA Foundation...',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: TemplateTheme.textMuted.withOpacity(0.5),
                ),
                filled: true,
                fillColor: fillColor,
                counterStyle: const TextStyle(
                    fontSize: 10, color: TemplateTheme.textMuted),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .dividerColor
                          .withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .dividerColor
                          .withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: TemplateTheme.primary.withOpacity(0.7),
                      width: 1.5),
                ),
              ),
              onChanged: (_) {
                if (mounted) setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Timetable Sub-section ────────────────────────────────────

  Widget _buildTimetableSection(
      Color fillColor, String timetableKey, List<String> slots) {
    final totalSlots = _tempTimetable.values
        .fold(0, (sum, s) => sum + s.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: label + slot count + Add button
        Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 14, color: TemplateTheme.primary),
            const SizedBox(width: 6),
            const _SheetLabel(text: 'Timetable'),
            if (totalSlots > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: TemplateTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalSlots slot${totalSlots == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: TemplateTheme.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: () => setState(
                  () => _showTimetableEditor = !_showTimetableEditor),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TemplateTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showTimetableEditor
                          ? Icons.remove_rounded
                          : Icons.add_rounded,
                      size: 13,
                      color: TemplateTheme.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _showTimetableEditor ? 'Collapse' : 'Edit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Expandable timetable editor
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 240),
          sizeCurve: Curves.easeInOut,
          crossFadeState: _showTimetableEditor
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kTimetableCategories.map((cat) {
                      final isSel = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? TemplateTheme.primary
                                : Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSel
                                  ? Colors.white
                                  : TemplateTheme.textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),

                // Day tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kWeekDays.map((day) {
                      final isSel = day == _selectedDay;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDay = day),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel
                                ? TemplateTheme.primary.withOpacity(0.2)
                                : Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSel
                                  ? TemplateTheme.primary
                                  : Theme.of(context)
                                      .dividerColor
                                      .withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSel
                                  ? TemplateTheme.primary
                                  : TemplateTheme.textMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Slot chips or empty state
                if (slots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.schedule_outlined,
                              size: 28,
                              color: TemplateTheme.textMuted
                                  .withOpacity(0.4)),
                          const SizedBox(height: 6),
                          Text(
                            'No slots yet — add one below ↓',
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  TemplateTheme.textMuted.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        slots.asMap().entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:
                              TemplateTheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: TemplateTheme.primary
                                  .withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 12,
                                color: TemplateTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() {
                                _tempTimetable[timetableKey]
                                    ?.removeAt(entry.key);
                                if (_tempTimetable[timetableKey]
                                        ?.isEmpty ??
                                    false) {
                                  _tempTimetable.remove(timetableKey);
                                }
                              }),
                              child: Icon(Icons.close_rounded,
                                  size: 14,
                                  color: TemplateTheme.textMuted),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 12),

                // Add slot row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _slotCtrl,
                        style: const TextStyle(
                            fontSize: 12,
                            color: TemplateTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Add slot (Maths 5–6 PM)',
                          hintStyle: TextStyle(
                              fontSize: 12,
                              color: TemplateTheme.textMuted
                                  .withOpacity(0.5)),
                          filled: true,
                          fillColor: fillColor,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: TemplateTheme.primary
                                    .withOpacity(0.6)),
                          ),
                        ),
                        onSubmitted: (val) => _addSlot(
                            val, timetableKey),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () =>
                          _addSlot(_slotCtrl.text, timetableKey),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TemplateTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_rounded,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addSlot(String val, String key) {
    final v = val.trim();
    if (v.isEmpty) return;
    if ((_tempTimetable[key]?.length ?? 0) >= 8) {
      _snack('Maximum 8 slots allowed', isError: true);
      return;
    }
    setState(() {
      _tempTimetable[key] ??= [];
      _tempTimetable[key]!.add(v);
      _slotCtrl.clear();
    });
  }

  Widget _buildParametersCard() {
    final chapters = kSubjectChapters[_params.subject] ?? ['All Chapters'];
    return Container(
      decoration: TemplateTheme.glassPanel(
          color: Colors.white, opacity: 0.72, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.tune_rounded, label: 'Parameters'),
          const SizedBox(height: 16),
          _PinaDropdown<String>(
            label: 'Subject',
            value: _params.subject,
            hint: 'Select subject',
            items: kSubjectChapters.keys.toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _params.subject = v;
                final cl = kSubjectChapters[v];
                _params.chapter = (cl != null && cl.isNotEmpty)
                    ? cl.first
                    : 'All Chapters';
              });
            },
          ),
          const SizedBox(height: 14),
          _PinaDropdown<String>(
            label: 'Chapter',
            value: chapters.contains(_params.chapter)
                ? _params.chapter
                : chapters.first,
            hint: 'Select chapter',
            items: chapters,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _params.chapter = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeSection() {
    const types = [
      _ContentTypeData('📚', 'Study Material',
          'Comprehensive notes and explanations', ContentType.study),
      _ContentTypeData(
          '📝', 'Test', 'Questions and assessments', ContentType.test),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(Icons.category_rounded,
                  size: 18, color: TemplateTheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Content Type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: types.map((t) {
            final isSelected = _params.contentType == t.type;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 56) / 2,
              child: GestureDetector(
                onTap: () =>
                    setState(() => _params.contentType = t.type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              TemplateTheme.primary.withOpacity(0.25),
                              TemplateTheme.primary.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected
                        ? null
                        : Theme.of(context)
                            .dividerColor
                            .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? TemplateTheme.primary
                          : Theme.of(context)
                              .dividerColor
                              .withOpacity(0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  TemplateTheme.primary.withOpacity(0.25),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(
                        t.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? TemplateTheme.primary
                              : TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: TemplateTheme.textMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTestOptionsCard() {
    return Container(
      decoration: TemplateTheme.glassPanel(
          color: Colors.white, opacity: 0.72, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.quiz_rounded, label: 'Test Options'),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PinaDropdown<String>(
                  label: 'Test Type',
                  value: _params.testType,
                  hint: 'Select test type',
                  items: kTestTypes,
                  onChanged: (v) =>
                      setState(() => _params.testType = v),
                ),
              ),
              if (_params.testType == null) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),

          GestureDetector(
            onTap: () =>
                setState(() => _params.openBook = !_params.openBook),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _params.openBook
                    ? TemplateTheme.primary.withOpacity(0.1)
                    : Theme.of(context).dividerColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _params.openBook
                      ? TemplateTheme.primary.withOpacity(0.5)
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _params.openBook
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: _params.openBook
                        ? TemplateTheme.primary
                        : TemplateTheme.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Open Book',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Allow reference material',
                    style: TextStyle(
                        fontSize: 11, color: TemplateTheme.textMuted),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              _PinaLabel(text: 'Question Types'),
              const SizedBox(width: 6),
              if (_params.questionTypes.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Select at least one',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SelectableChip(
                label: 'MCQ',
                icon: Icons.radio_button_checked_rounded,
                selected:
                    _params.questionTypes.contains(QuestionType.mcq),
                onTap: () => setState(() {
                  if (_params.questionTypes.length == 1 &&
                      _params.questionTypes
                          .contains(QuestionType.mcq)) {
                    _snack('At least one question type required',
                        isError: true);
                    return;
                  }
                  if (_params.questionTypes.contains(QuestionType.mcq)) {
                    _params.questionTypes.remove(QuestionType.mcq);
                  } else {
                    _params.questionTypes.add(QuestionType.mcq);
                  }
                }),
              ),
              _SelectableChip(
                label: 'Long Answer',
                icon: Icons.article_rounded,
                selected: _params.questionTypes
                    .contains(QuestionType.longAnswer),
                onTap: () => setState(() {
                  if (_params.questionTypes.length == 1 &&
                      _params.questionTypes
                          .contains(QuestionType.longAnswer)) {
                    _snack('At least one question type required',
                        isError: true);
                    return;
                  }
                  if (_params.questionTypes
                      .contains(QuestionType.longAnswer)) {
                    _params.questionTypes.remove(QuestionType.longAnswer);
                  } else {
                    _params.questionTypes.add(QuestionType.longAnswer);
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInstructions() {
    return Container(
      decoration: TemplateTheme.glassPanel(
          color: Colors.white, opacity: 0.72, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
              icon: Icons.lightbulb_rounded,
              label: 'Additional Instructions'),
          const SizedBox(height: 12),
          _PinaTextField(
            controller: _instructionCtrl,
            hint:
                'Add any extra instructions or context here...\n\ne.g. Focus on derivations · Include diagrams · Explain in Hindi · Make answers concise',
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Transform.scale(
        scale: _isGenerating ? 1.0 : _pulseAnim.value,
        child: child,
      ),
      child: FractionallySizedBox(
        widthFactor: 1.0,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : _onGenerate,
            style: TemplateTheme.primaryButtonStyle(),
            child: _isGenerating
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('⚡', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Generate',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: TemplateTheme.glassPanel(
          color: Colors.white, opacity: 0.72, radius: 20),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  TemplateTheme.primary.withOpacity(0.18),
                  TemplateTheme.primary.withOpacity(0.04),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: TemplateTheme.primary.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome_outlined,
              size: 30,
              color: TemplateTheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your AI content will appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TemplateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select a subject, choose content type,\nand tap Generate ⚡',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: TemplateTheme.textMuted.withOpacity(0.65),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputCard() {
    if (_isGenerating) {
      return Container(
        decoration: TemplateTheme.glassPanel(
            color: Colors.white, opacity: 0.72, radius: 20),
        padding: const EdgeInsets.all(18),
        child: const _ShimmerLoading(),
      );
    }

    if (_generatedOutput == null) return _buildEmptyState();

    return Container(
      decoration: TemplateTheme.glassPanel(
          color: Colors.white, opacity: 0.72, radius: 20),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CardTitle(
                  icon: Icons.article_rounded,
                  label: 'Generated Output'),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: _generatedOutput!));
                  _snack('Copied to clipboard ✓');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: TemplateTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: TemplateTheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 14, color: TemplateTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TemplateTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceVariant
                  .withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color:
                      Theme.of(context).dividerColor.withOpacity(0.07)),
            ),
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: SelectableText(
                _generatedOutput!,
                style: const TextStyle(
                  fontSize: 13,
                  color: TemplateTheme.textPrimary,
                  height: 1.7,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_prefsLoaded) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildContextBadge(),
                  const SizedBox(height: 18),
                  _buildParametersCard(),
                  const SizedBox(height: 18),
                  _buildContentTypeSection(),
                  const SizedBox(height: 18),
                  if (_params.contentType == ContentType.test) ...[
                    _buildTestOptionsCard(),
                    const SizedBox(height: 18),
                  ],
                  _buildAdditionalInstructions(),
                  const SizedBox(height: 24),
                  _buildGenerateButton(),
                  const SizedBox(height: 36),
                  _buildOutputCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// REUSABLE WIDGETS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CardTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TemplateTheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TemplateTheme.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _PinaLabel extends StatelessWidget {
  final String text;
  const _PinaLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: TemplateTheme.textMuted,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: TemplateTheme.textMuted,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _PinaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _PinaTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final dynamicFillColor =
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35);

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
          color: TemplateTheme.textMuted.withOpacity(0.55),
          height: 1.5,
        ),
        filled: true,
        fillColor: dynamicFillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: TemplateTheme.primary.withOpacity(0.7), width: 1.5),
        ),
      ),
    );
  }
}

class _PinaDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _PinaDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dynamicFillColor =
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PinaLabel(text: label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: dynamicFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  fontSize: 13,
                  color: TemplateTheme.textMuted.withOpacity(0.55),
                ),
              ),
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(Icons.expand_more_rounded,
                  color: TemplateTheme.textMuted, size: 20),
              style: const TextStyle(
                  fontSize: 13, color: TemplateTheme.textPrimary),
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

class _SheetDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final Color fillColor;
  final ValueChanged<T?> onChanged;

  const _SheetDropdown({
    required this.value,
    required this.items,
    required this.fillColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
          icon: Icon(Icons.expand_more_rounded,
              color: TemplateTheme.textMuted, size: 18),
          style: const TextStyle(
              fontSize: 13, color: TemplateTheme.textPrimary),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    TemplateTheme.primary.withOpacity(0.3),
                    TemplateTheme.primary.withOpacity(0.1),
                  ],
                )
              : null,
          color: selected
              ? null
              : Theme.of(context).dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? TemplateTheme.primary
                : Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? TemplateTheme.primary
                  : TemplateTheme.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? TemplateTheme.primary
                    : TemplateTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SHIMMER LOADING
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading();

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final opacity = 0.04 + (_anim.value * 0.08);
        final gp = _anim.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + gp * 2, 0),
                  end: Alignment(gp * 2, 0),
                  colors: [
                    TemplateTheme.primary.withOpacity(0.0),
                    TemplateTheme.primary,
                    TemplateTheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 16, color: TemplateTheme.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Generating',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TemplateTheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                _TypingDots(),
              ],
            ),
            const SizedBox(height: 14),
            ...[0.9, 0.75, 0.85, 0.6, 0.7].map(
              (w) => FractionallySizedBox(
                widthFactor: w,
                child: Container(
                  height: 12,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(opacity),
                        Colors.white.withOpacity(opacity * 1.5),
                        Colors.white.withOpacity(opacity),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment(-1.0 + gp * 2, 0),
                      end: Alignment(gp * 2, 0),
                    ),
                    borderRadius: BorderRadius.circular(6),
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

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase =
              (((_ctrl.value * 3) - i) % 1.0).clamp(0.0, 1.0);
          final bounce = phase < 0.5 ? phase * 2 : 2 - phase * 2;
          return Transform.translate(
            offset: Offset(0, -4 * bounce),
            child: Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TemplateTheme.primary
                    .withOpacity(0.5 + bounce * 0.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// DATA HELPER
// ──────────────────────────────────────────────────────────────

class _ContentTypeData {
  final String emoji;
  final String label;
  final String description;
  final ContentType type;
  const _ContentTypeData(
      this.emoji, this.label, this.description, this.type);
}