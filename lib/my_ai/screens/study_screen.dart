import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pina/services/session_service.dart';

import '../config/widget_configs.dart';
import '../models/study_content_model.dart';
import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/myai_glass_widgets.dart';
// ✅ FIX 1: ADD MISSING IMPORT
import '../widgets/widget_response_formatters.dart';

class StudyScreen extends StatefulWidget {
  final String userEmail;
  final WidgetModel? widgetItem;
  final StudyChapterSelection initialSelection;

  const StudyScreen({
    super.key,
    required this.userEmail,
    this.widgetItem,
    this.initialSelection = const StudyChapterSelection(),
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final MyAiApiService _service = myAiService;
  
  // ✅ INPUT STATE
  final TextEditingController _inputController = TextEditingController();
  PlatformFile? _selectedFile;
  String? _tempAudioPath;
  bool _isGenerating = false;
  String? _generatedOutput;  // ✅ New: Store generated output

  StudyOutlineModel? _outline;
  StudyChapterSelection _selection = const StudyChapterSelection();
  List<StudyContentModel> _content = <StudyContentModel>[];
  
  // 🎤 RECORDING STATE
  late final AudioRecorder _record;
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  
  // ✅ PERFORMANCE: Cache content map
  late Map<String, StudyContentModel> _contentMap;

  bool _loadingOutline = false;
  bool _loadingContent = false;
  String? _error;

  WidgetConfig? get _presentation {
    if (widget.widgetItem == null) return null;
    return resolveWidgetConfigForWidget(widget.widgetItem!);
  }

  // ✅ FIX 1: FINAL TITLE (NO FALLBACK ISSUES)
  String get _title =>
      widget.widgetItem?.widgetName.isNotEmpty == true
          ? widget.widgetItem!.widgetName
          : _presentation?.heading ?? 'Study';

  String get _subtitle => _presentation?.description ??
      'Change board, class, subject, and chapter without leaving the same screen.';

  List<String> get _sectionOrder {
    final rawSections = _presentation?.studyConfig['sections'];
    if (rawSections is List) {
      return rawSections.map((item) => item.toString()).toList(growable: false);
    }
    return const ['summary', 'notes', 'mcq', 'test'];
  }

  @override
  void initState() {
    super.initState();
    _selection = widget.initialSelection;
    _contentMap = {};
    _record = AudioRecorder();
    _loadOutline();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording) {
      _record.stop();
    }
    _record.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // ✅ Build content map for performance
  void _buildContentMap() {
    _contentMap = {
      for (var item in _content) item.sectionKey: item
    };
  }

  Future<void> _loadOutline() async {
    setState(() {
      _loadingOutline = true;
      _error = null;
    });

    try {
      final response = await _service.getContentFilters(
        widget.userEmail,
        status: 'completed',
      );
      final outline = StudyOutlineModel.fromJson(response);

      if (!mounted) return;

      final resolvedSelection = _resolveSelection(outline, _selection);
      setState(() {
        _outline = outline;
        _selection = resolvedSelection;
        _loadingOutline = false;
      });

      if (resolvedSelection.isComplete) {
        await _loadChapterContent();
      }
    } catch (error) {
      if (!mounted) return;
      print("STUDY ERROR: $error");
      setState(() {
        _loadingOutline = false;
        _error = 'Unable to load content. Please try again.';
      });
    }
  }

  StudyChapterSelection _resolveSelection(
    StudyOutlineModel outline,
    StudyChapterSelection requested,
  ) {
    if (outline.boards.isEmpty) {
      return const StudyChapterSelection();
    }

    final boardNode = outline.boards.firstWhere(
      (board) => board.board == requested.board,
      orElse: () => outline.boards.first,
    );
    final standardNode = boardNode.standards.firstWhere(
      (standard) => standard.standard == requested.standard,
      orElse: () => boardNode.standards.isNotEmpty
          ? boardNode.standards.first
          : const StudyStandardNode(standard: '', subjects: []),
    );
    final subjectNode = standardNode.subjects.firstWhere(
      (subject) => subject.subjectName == requested.subjectName,
      orElse: () => standardNode.subjects.isNotEmpty
          ? standardNode.subjects.first
          : const StudySubjectNode(subjectName: '', chapters: []),
    );
    final chapter = subjectNode.chapters.contains(requested.chapterName)
        ? requested.chapterName
        : (subjectNode.chapters.isNotEmpty ? subjectNode.chapters.first : '');

    return StudyChapterSelection(
      board: boardNode.board,
      standard: standardNode.standard,
      subjectName: subjectNode.subjectName,
      chapterName: chapter,
    );
  }

  StudyBoardNode? get _currentBoard {
    final outline = _outline;
    if (outline == null) return null;
    for (final board in outline.boards) {
      if (board.board == _selection.board) {
        return board;
      }
    }
    return outline.boards.isNotEmpty ? outline.boards.first : null;
  }

  StudyStandardNode? get _currentStandard {
    final board = _currentBoard;
    if (board == null) return null;
    for (final standard in board.standards) {
      if (standard.standard == _selection.standard) {
        return standard;
      }
    }
    return board.standards.isNotEmpty ? board.standards.first : null;
  }

  StudySubjectNode? get _currentSubject {
    final standard = _currentStandard;
    if (standard == null) return null;
    for (final subject in standard.subjects) {
      if (subject.subjectName == _selection.subjectName) {
        return subject;
      }
    }
    return standard.subjects.isNotEmpty ? standard.subjects.first : null;
  }

  Future<void> _loadChapterContent() async {
    if (_loadingContent) return;
    if (!_selection.isComplete) return;

    setState(() {
      _loadingContent = true;
      _error = null;
    });

    try {
      final response = await _service.getContent(
        widget.userEmail,
        status: 'completed',
        limit: 100,
        board: _selection.board,
        standard: _selection.standard,
        subjectName: _selection.subjectName,
        chapterName: _selection.chapterName,
      );

      final content = response
          .whereType<Map>()
          .map((item) => StudyContentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _content = content;
        _loadingContent = false;
      });
      _buildContentMap();
    } catch (error) {
      if (!mounted) return;
      print("STUDY ERROR: $error");
      setState(() {
        _loadingContent = false;
        _error = 'Unable to load content. Please try again.';
      });
    }
  }

  Future<void> _updateSelection(StudyChapterSelection nextSelection) async {
    setState(() {
      _selection = nextSelection;
      _content = <StudyContentModel>[];
      _contentMap = {};
    });

    if (_selection.isComplete) {
      await _loadChapterContent();
    }
  }

  // 🎤 RECORDING FUNCTIONS
  Future<void> _startRecording() async {
    if (_isRecording) return;

    if (!await _record.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }

    final tempDir = await getTemporaryDirectory();
    _tempAudioPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _record.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _tempAudioPath!,
    );

    setState(() => _isRecording = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingDuration += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    await _record.stop();
    _timer?.cancel();

    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Audio ready to generate')),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  // ✅ FILE PICK FUNCTION
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'png', 'mp3', 'wav', 'm4a'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File too large (max 10MB)')),
        );
        return;
      }
      setState(() => _selectedFile = file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ File selected: ${file.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large (max 10MB)')),
        );
        return;
      }
      setState(() => _selectedFile = file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image selected: ${file.name}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // ✅ FIX 2: GENERATE FUNCTION WITH AUDIO PRIORITY
  Future<void> _generateContent() async {
    final input = _inputController.text.trim();

    if (input.isEmpty && _selectedFile == null && _tempAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text, select a file, or record audio')),
      );
      return;
    }

    if (!_selection.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select board, class, subject, and chapter first')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedOutput = null;
    });

    try {
      // ✅ FIX 2: Audio takes priority over file
      PlatformFile? fileToSend;
      
      if (_tempAudioPath != null) {
        // 🔥 PRIORITY 1: Audio recording
        final audioFile = File(_tempAudioPath!);
        if (await audioFile.exists()) {
          fileToSend = PlatformFile(
            name: audioFile.path.split('/').last,
            path: audioFile.path,
            size: await audioFile.length(),
            bytes: await audioFile.readAsBytes(),
          );
          print("📹 Sending audio recording: ${fileToSend!.name}");
        }
      } else if (_selectedFile != null) {
        // 🔥 PRIORITY 2: Selected file (only if no audio)
        fileToSend = _selectedFile;
        print("📎 Sending file: ${fileToSend!.name}");
      }

      // ✅ Safe null check for widgetItem
      if (widget.widgetItem == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Widget configuration not available')),
        );
        return;
      }

      // Call API with study context
      final result = await _service.callWidget(
        widget: widget.widgetItem!,  // Safe because we checked above
        userEmail: widget.userEmail,
        input: input.isNotEmpty ? input : (fileToSend?.name ?? 'Generate study content'),
        file: fileToSend,
        userId: await SessionService.getUserId(),
      );

      // ✅ FIX 3: Use the imported function (now it's available)
      final newContent = extractReadableWidgetOutput(result);
      
      // ✅ Store the generated output to display
      setState(() {
        _generatedOutput = newContent;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Content generation complete!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear input after generation
      _inputController.clear();
      setState(() {
        _selectedFile = null;
        _tempAudioPath = null;
      });

      // Reload content to show new data
      await _loadChapterContent();
      
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // ✅ DROPDOWN - LIGHT VERSION
  Widget _buildSelector({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: options.contains(value) ? value : (options.isNotEmpty ? options.first : null),
        onChanged: options.isEmpty ? null : onChanged,
        dropdownColor: const Color(0xFF312A5A),
        iconEnabledColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 12),
        ),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        items: options
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  String _sectionTitle(String key) {
    switch (key) {
      case 'summary':
        return 'Summary';
      case 'notes':
        return 'Notes';
      case 'mcq':
        return 'MCQ';
      case 'test':
        return 'Test';
      default:
        return key;
    }
  }

  // ✅ SECTION CARDS - LIGHT VERSION
  Widget _buildSectionCard(String key) {
    final item = _contentMap[key];

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _sectionTitle(key),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          item == null
              ? Text(
                  'Not available',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                )
              : _buildSectionContent(item),
        ],
      ),
    );
  }

  Widget _buildSectionContent(StudyContentModel item) {
    if (item.sectionKey == 'mcq') {
      dynamic decoded;
      try {
        decoded = jsonDecode(item.content);
      } catch (e) {
        return SelectableText(
          item.content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        );
      }
      
      if (decoded is Map<String, dynamic> && decoded['questions'] is List) {
        final questions = decoded['questions'] as List;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: questions.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final question = entry.value is Map
                ? Map<String, dynamic>.from(entry.value as Map)
                : const <String, dynamic>{};
            final options = question['options'] is Map
                ? Map<String, dynamic>.from(question['options'] as Map)
                : const <String, dynamic>{};
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index. ${question['question'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...options.entries.map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '${option.key}. ${option.value}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Answer: ${question['answer'] ?? ''}',
                    style: const TextStyle(
                      color: Color(0xFF9BE7FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  if ((question['explanation'] ?? '').toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      question['explanation'].toString(),
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                    ),
                  ],
                ],
              ),
            );
          }).toList(growable: false),
        );
      }
    }

    return SelectableText(
      item.content.isEmpty ? 'No content available.' : item.content,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        height: 1.5,
      ),
    );
  }

  // ✅ INPUT UI (TOP पर)
  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 TEXT INPUT
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: _inputController,
            enabled: !_isGenerating && !_isRecording,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Ask or generate study content...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 🔹 FILE + MIC ROW
        Row(
          children: [
            IconButton(
              onPressed: (_isGenerating || _isRecording) ? null : _pickFile,
              icon: Icon(
                Icons.attach_file,
                color: _presentation?.accentColor ?? Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: (_isGenerating || _isRecording) ? null : _pickImage,
              icon: Icon(
                Icons.image_outlined,
                color: _presentation?.accentColor ?? Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: (_isGenerating) ? null : _toggleRecording,
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _presentation?.accentColor ?? Colors.white,
              ),
              style: IconButton.styleFrom(
                backgroundColor: _isRecording 
                    ? Colors.red.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_isRecording)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'Recording: ${_formatDuration(_recordingDuration)}',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            if (_selectedFile != null && !_isRecording && _tempAudioPath == null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _selectedFile!.name,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _selectedFile = null),
                      child: const Icon(Icons.close, color: Colors.red, size: 14),
                    ),
                  ],
                ),
              ),
            if (_tempAudioPath != null && !_isRecording)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Audio ready',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _tempAudioPath = null),
                      child: const Icon(Icons.close, color: Colors.red, size: 14),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: (_isGenerating || _isRecording) ? null : _generateContent,
              style: ElevatedButton.styleFrom(
                backgroundColor: _presentation?.accentColor ?? const Color(0xFF60A5FA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 18),
                        SizedBox(width: 6),
                        Text('Generate'),
                      ],
                    ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.white24, height: 1),
        const SizedBox(height: 20),
      ],
    );
  }

  // ✅ Display generated output if available
  Widget _buildGeneratedOutput() {
    if (_generatedOutput == null || _generatedOutput!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✨ Generated Content',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            _generatedOutput!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loadingOutline && _outline == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    // Error state
    if (_error != null && _outline == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Unable to load study content',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _error!,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
            const SizedBox(height: 16),
            MyAiGradientButton(
              onPressed: _loadOutline,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_outline == null || _outline!.boards.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputSection(),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined, color: Colors.white54, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'No study content yet',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Generate content first to view it here',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final boardOptions = _outline!.boards.map((item) => item.board).toList(growable: false);
    final standardOptions = _currentBoard?.standards
            .map((item) => item.standard)
            .toList(growable: false) ??
        const [];
    final subjectOptions = _currentStandard?.subjects
            .map((item) => item.subjectName)
            .toList(growable: false) ??
        const [];
    final chapterOptions = _currentSubject?.chapters ?? const [];

    return RefreshIndicator(
      onRefresh: () async {
        await _loadOutline();
        if (_selection.isComplete) {
          await _loadChapterContent();
        }
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // ✅ INPUT SECTION (AT TOP)
          _buildInputSection(),
          
          // ✅ Show generated output if any
          _buildGeneratedOutput(),
          
          // Dropdowns
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Flexible(
                child: _buildSelector(
                  label: 'Board',
                  value: _selection.board,
                  options: boardOptions,
                  onChanged: (value) {
                    final board = _outline!.boards.firstWhere(
                      (item) => item.board == value,
                    );
                    _updateSelection(
                      StudyChapterSelection(
                        board: board.board,
                        standard: board.standards.isNotEmpty ? board.standards.first.standard : '',
                        subjectName: board.standards.isNotEmpty &&
                                board.standards.first.subjects.isNotEmpty
                            ? board.standards.first.subjects.first.subjectName
                            : '',
                        chapterName: board.standards.isNotEmpty &&
                                board.standards.first.subjects.isNotEmpty &&
                                board.standards.first.subjects.first.chapters.isNotEmpty
                            ? board.standards.first.subjects.first.chapters.first
                            : '',
                      ),
                    );
                  },
                ),
              ),
              Flexible(
                child: _buildSelector(
                  label: 'Class',
                  value: _selection.standard,
                  options: standardOptions,
                  onChanged: (value) {
                    final standard = _currentBoard!.standards.firstWhere(
                      (item) => item.standard == value,
                    );
                    _updateSelection(
                      _selection.copyWith(
                        standard: standard.standard,
                        subjectName:
                            standard.subjects.isNotEmpty ? standard.subjects.first.subjectName : '',
                        chapterName: standard.subjects.isNotEmpty &&
                                standard.subjects.first.chapters.isNotEmpty
                            ? standard.subjects.first.chapters.first
                            : '',
                      ),
                    );
                  },
                ),
              ),
              Flexible(
                child: _buildSelector(
                  label: 'Subject',
                  value: _selection.subjectName,
                  options: subjectOptions,
                  onChanged: (value) {
                    final subject = _currentStandard!.subjects.firstWhere(
                      (item) => item.subjectName == value,
                    );
                    _updateSelection(
                      _selection.copyWith(
                        subjectName: subject.subjectName,
                        chapterName: subject.chapters.isNotEmpty ? subject.chapters.first : '',
                      ),
                    );
                  },
                ),
              ),
              Flexible(
                child: _buildSelector(
                  label: 'Chapter',
                  value: _selection.chapterName,
                  options: chapterOptions,
                  onChanged: (value) {
                    _updateSelection(_selection.copyWith(chapterName: value));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Content section
          if (_loadingContent)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_selection.chapterName.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Select a chapter to view content',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            )
          else
            ..._sectionOrder.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSectionCard(section),
              ),
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyAiGlassScreen(
      title: _title,
      subtitle: _subtitle,
      actions: [
        _StudyHeaderAction(
          icon: Icons.refresh_rounded,
          onPressed: _loadOutline,
        ),
      ],
      child: _buildBody(),
    );
  }
}

class _StudyHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StudyHeaderAction({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
