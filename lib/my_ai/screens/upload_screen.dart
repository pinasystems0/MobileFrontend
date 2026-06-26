import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pina/services/session_service.dart';
import '../config/widget_configs.dart';
import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/history_sidebar.dart';
import '../widgets/myai_glass_widgets.dart';
import '../widgets/widget_response_formatters.dart';

class UploadScreen extends StatefulWidget {
  final WidgetModel widgetItem;
  final String userEmail;

  const UploadScreen({
    super.key,
    required this.widgetItem,
    required this.userEmail,
  });

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final MyAiApiService _service = myAiService;
  final TextEditingController _promptController = TextEditingController();

  PlatformFile? _selectedFile;
  String _output = '';
  bool _isLoading = false;
  int _historyRefreshToken = 0;
  String? _userId;

  WidgetConfig get _presentation => resolveWidgetConfigForWidget(widget.widgetItem);

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userId = await SessionService.getUserId();
    if (!mounted) return;
    setState(() => _userId = userId);
  }

  Future<void> _pickFile() async {
    final isTranscribe = _presentation.action == 'transcribe';

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: isTranscribe
          ? ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'oga', 'flac', 'mpeg']
          : null,
    );

    if (result == null || result.files.isEmpty) return;
    
    final file = result.files.first;
    
    if (file.size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File too large (max 10MB)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (isTranscribe) {
      final extension = file.extension?.toLowerCase() ?? '';
      if (!['mp3', 'wav', 'm4a', 'aac', 'ogg', 'oga', 'flac', 'mpeg'].contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an audio file (MP3, WAV, M4A, AAC, OGG)'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    if (mounted) {
      setState(() => _selectedFile = file);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ File selected: ${file.name} (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveHistory(String prompt, String content) async {
    await _service.saveHistory(widget.userEmail, {
      'type': _presentation.type,
      'widgetType': widget.widgetItem.widgetName,
      'widgetName': widget.widgetItem.widgetName,
      'widgetKey': widget.widgetItem.widgetKey,
      'prompt': prompt,
      'content': content,
      'modelName': widget.widgetItem.widgetName,
      'inputParams': {
        'apiEndpoint': _presentation.apiEndpoint,
        'inputType': _presentation.inputType,
        'screenType': _presentation.screenType,
        'outputTemplate': _presentation.outputTemplate,
      },
    });
  }

  Future<void> _executeWidget() async {
    if (_isLoading) return;
    
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _output = '';
    });

    final prompt = _presentation.screenType == 'upload'
        ? _selectedFile!.name
        : _promptController.text.trim().isEmpty
            ? _selectedFile!.name
            : _promptController.text.trim();

    try {
      final result = await _service.callWidget(
        widget: widget.widgetItem,
        userEmail: widget.userEmail,
        input: prompt,
        file: _selectedFile,
        userId: _userId,
      );

      final rendered = formatWidgetOutput(
        extractReadableWidgetOutput(result),
        _presentation,
      );

      if (!mounted) return;
      setState(() => _output = rendered);

      await _saveHistory(prompt, rendered);
      if (!mounted) return;
      setState(() => _historyRefreshToken += 1);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', 'Operation failed: '),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyHistory(Map<String, dynamic> history) {
    setState(() {
      _promptController.text = history['prompt']?.toString() ?? '';
      _output = history['content']?.toString() ?? '';
    });
  }

  void _openHistorySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: HistorySidebar(
          userEmail: widget.userEmail,
          widgetType: widget.widgetItem.widgetName,
          refreshToken: _historyRefreshToken,
          onHistorySelected: _applyHistory,
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _presentation.accentColor,
                      const Color(0xFF44D7FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_presentation.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile?.name ?? _presentation.inputLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedFile == null
                          ? 'Supports upload workflow'
                          : '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB selected',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (_selectedFile != null)
                IconButton(
                  onPressed: () {
                    setState(() => _selectedFile = null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('File removed'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.close, color: Colors.red, size: 18),
                  tooltip: 'Remove file',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _presentation.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  minimumSize: const Size(0, 36),
                ),
                child: Text(
                  _selectedFile == null ? 'Choose' : 'Change',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        
        if (_presentation.inputType == 'audio' || _presentation.inputType == 'file') ...[
          const SizedBox(height: 6),
          Text(
            'Attach audio file',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPromptField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _promptController,
        enabled: !_isLoading,
        minLines: 2,
        maxLines: 4,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: 'Optional instructions',
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          hintText: 'Add context, formatting hints, or notes...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildOutputCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _output.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _presentation.outputTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your processed output will appear here...',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _presentation.outputTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _output,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyAiGlassScreen(
      title: widget.widgetItem.widgetName.isNotEmpty
          ? widget.widgetItem.widgetName
          : _presentation.heading,
      subtitle: _presentation.description,
      actions: [
        _UploadHeaderAction(
          icon: Icons.history_rounded,
          onPressed: _openHistorySheet,
        ),
      ],
      child: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _presentation.screenType,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _presentation.category,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _presentation.outputTitle,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildFilePicker(),
                const SizedBox(height: 14),
                
                if (_presentation.screenType != 'upload') ...[
                  _buildPromptField(),
                  const SizedBox(height: 14),
                ],
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _executeWidget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _presentation.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else
                          const Icon(Icons.send_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isLoading 
                              ? 'Processing...' 
                              : 'Run ${widget.widgetItem.widgetName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _buildOutputCard(),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Processing your request...',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UploadHeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _UploadHeaderAction({
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