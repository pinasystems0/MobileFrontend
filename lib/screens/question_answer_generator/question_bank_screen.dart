import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../screens/constants.dart';
import '../../ui_template/utils/template_theme.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  bool _isLoading = false;

  // Profile
  String _selectedClass = '';
  String _selectedBoard = '';

  // Selection dependent
  String _selectedCourseCode = '';
  String _selectedSubjectName = '';

  int? _selectedUnitNo;

  // Options
  String _selectedQuestionType = 'MCQ';
  String _selectedDifficulty = 'Easy';
  int _selectedCount = 10;

  // Data
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _units = [];

  // PDF state - Generated PDF from backend
  bool _pdfReady = false;
  String? _pdfFileName;
  String? _pdfPath;

  final _formKey = GlobalKey<FormState>();

  static const List<String> _questionTypes = ['MCQ', 'Question Answer', 'Short Answer'];
  static const List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  static const List<int> _counts = [5, 10, 15, 20, 25, 30, 40, 50];

  List<String> _classOptions = [];

  // Boards are dynamic from backend
  List<String> _boardOptions = [];

  bool _boardsLoading = false;
  bool _subjectsLoading = false;
  bool _unitsLoading = false;

  // Prompt composer
  final TextEditingController _promptController = TextEditingController();

  // Attachments (optional) - multipart (no base64)
  File? _imageFile;
  File? _pdfFile;
  String _imageFileName = '';
  String _selectedPdfFileName = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() => _isLoading = true);
    try {
      await _loadProfile();
      await _loadClasses();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    debugPrint('PROFILE_REQUEST');
    final uri = Uri.parse('${ApiConstants.authUrl}/api/question-bank/profile');
    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('PROFILE_REQUEST failed: ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    debugPrint('PROFILE_RESPONSE: $decoded');

    final classValue = (decoded is Map ? decoded['class'] : null)?.toString() ?? '';
    final boardValue = (decoded is Map ? decoded['board'] : null)?.toString() ?? '';

    if (!mounted) return;
    setState(() {
      _selectedClass = classValue;
      _selectedBoard = boardValue;
    });
  }

  Future<void> _loadClasses() async {
    debugPrint('CLASSES_REQUEST');
    final uri = Uri.parse('${ApiConstants.authUrl}/api/question-bank/classes');
    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('CLASSES_REQUEST failed: ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    debugPrint('CLASSES_RESPONSE: $decoded');

    final classes = (decoded is Map ? decoded['classes'] : null) as List<dynamic>?;
    final classStrings = classes?.map((e) => e.toString()).where((e) => e.isNotEmpty).toList() ?? [];

    setState(() {
      _classOptions = classStrings;
      if (classStrings.isEmpty) {
        _selectedClass = '';
      } else {
        _selectedClass = classStrings.contains(_selectedClass) ? _selectedClass : classStrings.first;
      }
    });

    await _loadBoards();
  }

  Future<void> _loadBoards() async {
    debugPrint('BOARDS_REQUEST');

    final previousBoard = _selectedBoard;

    setState(() {
      _boardsLoading = true;
      _boardOptions = [];
    });

    try {
      final uri = Uri.parse(
        '${ApiConstants.authUrl}/api/question-bank/boards?class=${Uri.encodeQueryComponent(_selectedClass)}',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 20));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('BOARDS_REQUEST failed: ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);
      debugPrint('BOARDS_RESPONSE: $decoded');

      final boards = (decoded is Map ? decoded['boards'] : null) as List<dynamic>?;
      final boardStrings = boards?.map((e) => e.toString()).where((e) => e.isNotEmpty).toList() ?? [];

      final keepExisting = previousBoard.isNotEmpty && boardStrings.contains(previousBoard);
      setState(() {
        _boardOptions = boardStrings;
        _selectedBoard = keepExisting ? previousBoard : (boardStrings.isNotEmpty ? boardStrings.first : '');
      });
    } finally {
      if (mounted) setState(() => _boardsLoading = false);
    }

    if (_selectedBoard.isNotEmpty) {
      await _loadSubjects();
    }
  }

  Future<void> _loadSubjects() async {
    if (_selectedClass.isEmpty || _selectedBoard.isEmpty) {
      setState(() => _subjects = []);
      return;
    }

    debugPrint('SUBJECTS_REQUEST');
    final previousCourseCode = _selectedCourseCode;

    setState(() {
      _subjectsLoading = true;
      _subjects = [];
      _units = [];
      _selectedUnitNo = null;
      _resetGeneratedOutputState();
    });

    try {
      final subjectsUrl =
          '${ApiConstants.authUrl}/api/question-bank/subjects?class=${Uri.encodeQueryComponent(_selectedClass)}&board=${Uri.encodeQueryComponent(_selectedBoard)}';

      debugPrint('SUBJECTS_URL = $subjectsUrl');

      final uri = Uri.parse(subjectsUrl);
      final res = await http.get(uri).timeout(const Duration(seconds: 30));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('SUBJECTS_REQUEST failed: ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);
      debugPrint('SUBJECTS_RESPONSE: $decoded');

      final list = (decoded is Map ? decoded['subjects'] : null) as List<dynamic>?;
      final items = (list ?? []).where((e) => e is Map).cast<Map<String, dynamic>>().toList();

      if (items.isEmpty) {
        if (mounted) _showSnack('No subjects found');
        return;
      }

      final existing = items.where((s) => s['courseCode']?.toString() == previousCourseCode);
      final pick = existing.isNotEmpty ? existing.first : items.first;

      setState(() {
        _subjects = items;
        _selectedCourseCode = pick['courseCode']?.toString() ?? '';
        _selectedSubjectName = pick['subjectName']?.toString() ?? '';
      });

      await _loadUnits();
    } finally {
      if (mounted) setState(() => _subjectsLoading = false);
    }
  }

  Future<void> _loadUnits() async {
    if (_selectedCourseCode.isEmpty) {
      setState(() => _units = []);
      return;
    }

    debugPrint('UNITS_REQUEST');
    final previousUnit = _selectedUnitNo;

    setState(() {
      _unitsLoading = true;
      _units = [];
      _selectedUnitNo = null;
      _resetGeneratedOutputState();
    });

    try {
      final unitsUrl =
          '${ApiConstants.authUrl}/api/question-bank/units?class=${Uri.encodeQueryComponent(_selectedClass)}&board=${Uri.encodeQueryComponent(_selectedBoard)}&courseCode=${Uri.encodeQueryComponent(_selectedCourseCode)}';

      debugPrint('UNITS_URL = $unitsUrl');

      final uri = Uri.parse(unitsUrl);
      final res = await http.get(uri).timeout(const Duration(seconds: 30));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('UNITS_REQUEST failed: ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);
      debugPrint('UNITS_RESPONSE: $decoded');

      final list = (decoded is Map ? decoded['units'] : null) as List<dynamic>?;
      final items = (list ?? []).where((e) => e is Map).cast<Map<String, dynamic>>().toList();

      if (items.isEmpty) {
        debugPrint('NO_UNITS_FOUND - SUBJECT_FALLBACK_WILL_BE_USED');

        setState(() {
          _units = [];
          _selectedUnitNo = null;
        });

        return;
      }

      final keep = previousUnit == null
          ? null
          : items.where((u) {
              final unitNo = (u['unitNo'] is int) ? u['unitNo'] as int : int.tryParse(u['unitNo']?.toString() ?? '');
              return unitNo == previousUnit;
            }).toList();

      final chosen = keep != null && keep.isNotEmpty ? keep.first : items.first;

      setState(() {
        _units = items;
        _selectedUnitNo = (chosen['unitNo'] is int)
            ? chosen['unitNo'] as int
            : int.tryParse(chosen['unitNo']?.toString() ?? '');
      });
    } finally {
      if (mounted) setState(() => _unitsLoading = false);
    }
  }

  String? _allowedFileMime(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return null;
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.image_outlined,
                      label: 'Upload Image',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildAttachmentOption(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Upload PDF',
                      onTap: () {
                        Navigator.pop(context);
                        _pickPdf();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: TemplateTheme.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TemplateTheme.primary.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: TemplateTheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TemplateTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final name = picked.name;

    if (picked.path == null) {
      _showSnack('Unable to read selected file');
      return;
    }

    final mime = _allowedFileMime(name);
    if (mime == null) {
      _showSnack('Unsupported image type');
      return;
    }

    setState(() {
      _imageFile = File(picked.path!);
      _imageFileName = name;
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    final name = picked.name;

    if (picked.path == null) {
      _showSnack('Unable to read selected file');
      return;
    }

    final mime = _allowedFileMime(name);
    if (mime == null) {
      _showSnack('Unsupported PDF type');
      return;
    }

    setState(() {
      _pdfFile = File(picked.path!);
      _selectedPdfFileName = name;
    });
  }

  void _removeAttachment(String type) {
    setState(() {
      if (type == 'image') {
        _imageFile = null;
        _imageFileName = '';
      } else if (type == 'pdf') {
        _pdfFile = null;
        _selectedPdfFileName = '';
      }
    });
  }

  void _resetGeneratedOutputState() {
    _pdfReady = false;
    _pdfFileName = null;
    _pdfPath = null;
  }

  String? _nonEmptyString(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Map<String, String?> _extractPdfDetails(dynamic decoded) {
    if (decoded is! Map) {
      return const {'fileName': null, 'filePath': null};
    }

    final rootFileName = _nonEmptyString(decoded['pdfFileName']);
    final rootFilePath = _nonEmptyString(decoded['pdfPath']);
    if (rootFileName != null || rootFilePath != null) {
      return {
        'fileName': rootFileName,
        'filePath': rootFilePath,
      };
    }

    final data = decoded['data'];
    if (data is Map) {
      return {
        'fileName': _nonEmptyString(data['pdfFileName']),
        'filePath': _nonEmptyString(data['pdfPath']),
      };
    }

    return const {'fileName': null, 'filePath': null};
  }

  String _readErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final message = decoded['message']?.toString().trim();
        final error = decoded['error']?.toString().trim();

        if (message != null && message.isNotEmpty) return message;
        if (error != null && error.isNotEmpty) return error;
      }
    } catch (_) {
      // Fall back to a generic message.
    }

    return 'Request failed (${response.statusCode})';
  }

  void _showQuestionSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Question Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedQuestionType,
                  isExpanded: true,
                  decoration: TemplateTheme.inputDecoration(label: 'Question Type', hint: 'Select question type'),
                  items: _questionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: _isLoading ? null : (value) => setState(() => _selectedQuestionType = value ?? _selectedQuestionType),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDifficulty,
                  isExpanded: true,
                  decoration: TemplateTheme.inputDecoration(label: 'Difficulty', hint: 'Select difficulty'),
                  items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: _isLoading ? null : (value) => setState(() => _selectedDifficulty = value ?? _selectedDifficulty),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _selectedCount,
                  isExpanded: true,
                  decoration: TemplateTheme.inputDecoration(label: 'Question Count', hint: 'Select count'),
                  items: _counts.map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
                  onChanged: _isLoading ? null : (value) => setState(() => _selectedCount = value ?? _selectedCount),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showSnack('Settings updated');
                    },
                    style: TemplateTheme.primaryButtonStyle(),
                    child: const Text('Apply Settings', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateQuestions() async {
    if (_selectedClass.isEmpty || _selectedBoard.isEmpty) {
      _showSnack('Select class and board');
      return;
    }

    debugPrint('SELECTED SUBJECT = $_selectedSubjectName');
    debugPrint('SELECTED COURSE CODE = $_selectedCourseCode');

    if (_selectedCourseCode.isEmpty && _selectedSubjectName.isNotEmpty) {
      final selected = _subjects.firstWhere(
        (s) => s['subjectName']?.toString() == _selectedSubjectName,
        orElse: () => <String, dynamic>{},
      );

      final recovered = selected['courseCode']?.toString() ?? '';
      if (recovered.isNotEmpty) {
        _selectedCourseCode = recovered;
        debugPrint('AUTO_RECOVERED COURSE CODE = $_selectedCourseCode');
      }
    }

    if (_selectedCourseCode.isEmpty || _selectedSubjectName.isEmpty) {
      _showSnack('No subjects selected');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _resetGeneratedOutputState();
    });
    
    try {
      final uri = Uri.parse('${ApiConstants.authUrl}/api/question-bank/generate');

      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'class': _selectedClass,
        'board': _selectedBoard,
        'courseCode': _selectedCourseCode,
        'questionType': _selectedQuestionType,
        'difficulty': _selectedDifficulty,
        'count': _selectedCount.toString(),
        'additionalPrompt': _promptController.text.trim(),
      });

      if (_selectedUnitNo != null) {
        request.fields['unitNo'] = _selectedUnitNo.toString();
      }

      if (_imageFile != null) {
        final mime = lookupMimeType(_imageFileName) ?? _allowedFileMime(_imageFileName);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            filename: _imageFileName,
            contentType: mime != null ? MediaType.parse(mime) : null,
          ),
        );
      }

      if (_pdfFile != null) {
        final mime = lookupMimeType(_selectedPdfFileName) ?? _allowedFileMime(_selectedPdfFileName);
        request.files.add(
          await http.MultipartFile.fromPath(
            'pdf',
            _pdfFile!.path,
            filename: _selectedPdfFileName,
            contentType: mime != null ? MediaType.parse(mime) : null,
          ),
        );
      }

      final streamed = await request.send().timeout(const Duration(seconds: 90));
      final res = await http.Response.fromStream(streamed);

      debugPrint('GENERATE_RESPONSE: status=${res.statusCode} body=${res.body}');

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(_readErrorMessage(res));
      }

      final decoded = jsonDecode(res.body);
      final pdfDetails = _extractPdfDetails(decoded);
      final pdfName = pdfDetails['fileName'];
      final pdfPath = pdfDetails['filePath'];

      if (pdfName == null || pdfPath == null) {
        throw Exception('PDF details were not returned by the backend.');
      }

      setState(() {
        _pdfFileName = pdfName;
        _pdfPath = pdfPath;
        _pdfReady = true;
      });

      if (mounted) {
        _showSnack('Question bank ready. Download the PDF.');
      }
/*
      if (mounted) {
        _showSnack('✅ $_lastGeneratedCount Questions Generated Successfully');
      }
*/
    } catch (e) {
      _showSnack('Generation failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadPdf() async {
    // Check if PDF is ready
    if (_pdfFileName == null || _pdfFileName!.isEmpty) {
      _showSnack('PDF not ready. Generate questions first.');
      return;
    }

    debugPrint('DOWNLOAD_PDF: $_pdfFileName');

    try {
      setState(() => _isLoading = true);

      // Build download URL
      final downloadUrl = '${ApiConstants.authUrl}/api/question-bank/download-pdf/${_pdfFileName}';
      debugPrint('DOWNLOAD_URL: $downloadUrl');

      final uri = Uri.parse(downloadUrl);
      final res = await http.get(uri).timeout(const Duration(seconds: 30));

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception(_readErrorMessage(res));
      }

      // Save to local storage
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${_pdfFileName ?? 'question_bank.pdf'}');
      await file.writeAsBytes(res.bodyBytes);

      // Open the PDF
      await OpenFile.open(file.path);

      if (mounted) {
        _showSnack('PDF downloaded: ${_pdfFileName ?? 'question_bank.pdf'}');
      }
/*
      if (mounted) {
        _showSnack('✅ PDF downloaded: ${_pdfFileName ?? 'question_bank.pdf'}');
      }
*/
    } catch (e) {
      _showSnack('Download failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Top content - scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 12),
                        _buildQuestionSettingsCard(),
                        if (_pdfReady) ...[
                          const SizedBox(height: 12),
                          _buildDownloadButton(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom fixed input
              _buildPromptComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromptComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attachment chips
            if (_imageFile != null || _pdfFile != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_imageFile != null)
                    _buildAttachmentChip(
                      label: _imageFileName,
                      icon: Icons.image_outlined,
                      onRemove: () => _removeAttachment('image'),
                    ),
                  if (_pdfFile != null)
                    _buildAttachmentChip(
                      label: _selectedPdfFileName,
                      icon: Icons.picture_as_pdf_outlined,
                      onRemove: () => _removeAttachment('pdf'),
                    ),
                ],
              ),
            if (_imageFile != null || _pdfFile != null) const SizedBox(height: 8),
            // Text input with buttons
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : _showAttachmentSheet,
                    icon: const Icon(Icons.attach_file, size: 22),
                    color: TemplateTheme.textMuted,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 6,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Type instructions...',
                        hintStyle: TextStyle(
                          color: TemplateTheme.textMuted,
                        ),
                        border: InputBorder.none,
                        isCollapsed: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      ),
                      onSubmitted: (_) => _generateQuestions(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: TemplateTheme.primary,
                      child: IconButton(
                        onPressed: _isLoading ? null : _generateQuestions,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TemplateTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TemplateTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: TemplateTheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TemplateTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: const Icon(Icons.close, size: 16, color: TemplateTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [TemplateTheme.primary.withOpacity(0.95), TemplateTheme.primary.withOpacity(0.45)],
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
              child: const Icon(Icons.quiz_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Bank',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: TemplateTheme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Generate syllabus-based questions and download as PDF.',
                    style: TextStyle(
                      fontSize: 12,
                      color: TemplateTheme.textMuted,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: TemplateTheme.glassPanel(
        color: Colors.white,
        opacity: 0.92,
        radius: 24,
        borderColor: Colors.white.withOpacity(0.72),
      ),
      child: child,
    );
  }

  Widget _buildQuestionSettingsCard() {
    return _buildGlassCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Question Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: TemplateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _classOptions.contains(_selectedClass) ? _selectedClass : null,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Class', hint: 'Select class'),
            items: _classOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (value) async {
              if (value == null) return;
              setState(() {
                _selectedClass = value;
                _selectedBoard = '';
                _selectedCourseCode = '';
                _selectedSubjectName = '';
                _subjects = [];
                _units = [];
                _selectedUnitNo = null;
                _resetGeneratedOutputState();
              });
              await _loadBoards();
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _boardOptions.contains(_selectedBoard) ? _selectedBoard : null,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Board', hint: 'Select board'),
            items: _boardsLoading ? const [] : _boardOptions.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: _boardsLoading
                ? null
                : (value) async {
                    if (value == null) return;
                    setState(() {
                      _selectedBoard = value;
                      _selectedCourseCode = '';
                      _selectedSubjectName = '';
                      _subjects = [];
                      _units = [];
                      _selectedUnitNo = null;
                      _resetGeneratedOutputState();
                    });
                    await _loadSubjects();
                  },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _subjects.any((s) => s['courseCode']?.toString() == _selectedCourseCode) ? _selectedCourseCode : null,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Subject', hint: 'Select subject'),
            items: _subjects
                .map((s) => DropdownMenuItem<String>(
                      value: s['courseCode']?.toString(),
                      child: Text(s['subjectName']?.toString() ?? ''),
                    ))
                .toList(),
            onChanged: _subjectsLoading
                ? null
                : (value) {
                    if (value == null) return;
                    final subject = _subjects.firstWhere((s) => s['courseCode']?.toString() == value);
                    setState(() {
                      _selectedCourseCode = subject['courseCode']?.toString() ?? '';
                      _selectedSubjectName = subject['subjectName']?.toString() ?? '';
                      _units = [];
                      _selectedUnitNo = null;
                      _resetGeneratedOutputState();
                    });
                    _loadUnits();
                  },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _units.any((u) => (u['unitNo'] is int) ? u['unitNo'] == _selectedUnitNo : int.tryParse(u['unitNo']?.toString() ?? '') == _selectedUnitNo)
                ? _selectedUnitNo
                : null,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Unit', hint: 'Select unit'),
            items: _units
                .map((u) => DropdownMenuItem<int>(
                      value: (u['unitNo'] is int)
                          ? u['unitNo'] as int
                          : int.tryParse(u['unitNo']?.toString() ?? ''),
                      child: Text('Unit ${u['unitNo']} - ${u['title']?.toString() ?? ''}'),
                    ))
                .where((e) => e.value != null)
                .cast<DropdownMenuItem<int>>()
                .toList(),
            onChanged: _unitsLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedUnitNo = value;
                      _resetGeneratedOutputState();
                    });
                  },
          ),
          if (_units.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'If a unit is unavailable, generation will use all subject topics.',
              style: TextStyle(
                fontSize: 12,
                color: TemplateTheme.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedQuestionType,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Question Type', hint: 'Select question type'),
            items: _questionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedQuestionType = value ?? _selectedQuestionType;
                      _resetGeneratedOutputState();
                    });
                  },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedDifficulty,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Difficulty', hint: 'Select difficulty'),
            items: _difficulties.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedDifficulty = value ?? _selectedDifficulty;
                      _resetGeneratedOutputState();
                    });
                  },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedCount,
            isExpanded: true,
            decoration: TemplateTheme.inputDecoration(label: 'Count', hint: 'Select count'),
            items: _counts.map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedCount = value ?? _selectedCount;
                      _resetGeneratedOutputState();
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _downloadPdf,
        icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
        label: Text(
          _pdfFileName == null ? 'Download PDF' : 'Download PDF (${_pdfFileName!})',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: TemplateTheme.secondaryButtonStyle(),
      ),
    );
  }
}
