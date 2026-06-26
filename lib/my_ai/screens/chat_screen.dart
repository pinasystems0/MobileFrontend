import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pina/services/session_service.dart';
import '../config/widget_configs.dart';
import '../models/widget_model.dart';
import '../services/myai_api_service.dart';
import '../widgets/history_sidebar.dart';
import '../widgets/myai_glass_widgets.dart';
import '../widgets/widget_response_formatters.dart';

class ChatScreen extends StatefulWidget {
  final WidgetModel widgetItem;
  final String userEmail;

  const ChatScreen({
    super.key,
    required this.widgetItem,
    required this.userEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final MyAiApiService _service = MyAiApiService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<_UnifiedMessage> _messages = <_UnifiedMessage>[];
  bool _isSending = false;
  bool _isRecording = false;
  int _historyRefreshToken = 0;
  String? _userId;
  String? _tempAudioPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late final AudioRecorder _record;

  WidgetConfig get _presentation => resolveWidgetConfigForWidget(widget.widgetItem);
  bool get _supportsMediaAttachments =>
      _presentation.key == 'medical_ai' || _presentation.key == 'legal_ai';
  
  // ✅ FIX 1: Added 'file' input type support for Audio Transcription
  bool get _supportsAudioInput =>
      _presentation.inputType == 'audio' || 
      _presentation.inputType == 'file' ||   // 🔥 ADD THIS for Audio Transcription
      _supportsMediaAttachments;

  // ✅ CLEAN SEND BUTTON LOGIN
  bool get _canSend => !_isSending && !_isRecording &&
      (_inputController.text.trim().isNotEmpty || _tempAudioPath != null);

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      if (mounted) setState(() {});
    });
    _record = AudioRecorder();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecording) {
      _record.stop();
    }
    _record.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final userId = await SessionService.getUserId();
    if (mounted) setState(() => _userId = userId);
  }

  // ✅ FIX 2: Set _tempAudioPath for audio files so send works
  void _handlePickedFile(PlatformFile file) {
    if (file.size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File too large (max 10MB)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String fileType = 'file';
    final extension = file.extension?.toLowerCase() ?? '';
    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      fileType = 'image';
    } else if (['mp3', 'wav', 'm4a'].contains(extension)) {
      fileType = 'audio';
      // 🔥 CRITICAL FIX: Set temp audio path for audio files
      if (file.path != null) {
        _tempAudioPath = file.path;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎵 Audio file ready to send'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } else if (extension == 'pdf') {
      fileType = 'pdf';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File attached: ${file.name} (${(file.size / 1024).round()} KB)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    setState(() {
      _messages.add(_UnifiedMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'user',
        type: fileType,
        text: file.name,
        fileSize: file.size,
        fileExtension: extension,
      ));
    });
    _scrollToBottom();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'mp3', 'wav', 'm4a'],
      );

      if (result != null && mounted) {
        _handlePickedFile(result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && mounted) {
        _handlePickedFile(result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording) return;

    if (!await _record.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required')),
        );
      }
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

    if (_tempAudioPath != null) {
      final file = File(_tempAudioPath!);
      if (await file.exists()) {
        final size = await file.length();
        if (size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Audio too large (max 10MB)')),
            );
          }
          await file.delete();
          _tempAudioPath = null;
        }
      }
    }

    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Audio ready to send')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (!_canSend) return;

    if (_tempAudioPath != null) {
      await _sendAudio(File(_tempAudioPath!));
      if (mounted) setState(() => _tempAudioPath = null);
    } else {
      final text = _inputController.text.trim();
      if (text.isNotEmpty) {
        _sendText(text);
        _inputController.clear();
      }
    }
  }

  // 🔥 FIX 3: Enhanced AI Response Extraction (handles multiple schemas)
  Future<void> _sendText(String text) async {
    if (_isSending) return;
    if (_userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not loaded')),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    final messageId = DateTime.now().millisecondsSinceEpoch;
    final loadingId = (messageId + 1).toString();
    
    setState(() {
      _messages.add(_UnifiedMessage(
        id: messageId.toString(),
        role: 'user',
        type: 'user_text',
        text: text,
      ));
      _messages.add(_UnifiedMessage(
        id: loadingId,
        role: 'ai',
        type: 'loading',
        text: 'Generating response...',
      ));
    });
    _scrollToBottom();

    try {
      final response = await _service.unifiedChat(
        widget: widget.widgetItem,
        userId: _userId!,
        inputText: text,
      );

      print("FULL MYAI RESPONSE => $response");

      if (!mounted) return;

      final data = (response['data'] as Map<String, dynamic>?) ?? {};

      final aiText =
          data['response'] ??
          data['summary'] ??
          data['text'] ??
          data['result'] ??
          response['response'] ??
          response['text'] ??
          'No response';

      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);

        _messages.add(_UnifiedMessage(
          id: (messageId + 2).toString(),
          role: 'ai',
          type: 'ai_text',
          text: aiText.toString(),
        ));
      });
    } catch (error) {
      print("API ERROR: $error");
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        _messages.add(_UnifiedMessage(
          id: (messageId + 2).toString(),
          role: 'ai',
          type: 'error',
          text: 'Something went wrong. Please try again.',
        ));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  Future<void> _sendAudio(File audioFile) async {
    if (_isSending) return;
    if (_userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not loaded')),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    final messageId = DateTime.now().millisecondsSinceEpoch;
    final loadingId = (messageId + 1).toString();
    
    setState(() {
      _messages.add(_UnifiedMessage(
        id: messageId.toString(),
        role: 'user',
        type: 'user_audio',
        text: 'Audio message (${audioFile.lengthSync() ~/ 1024} KB)',
      ));
      _messages.add(_UnifiedMessage(
        id: loadingId,
        role: 'ai',
        type: 'loading',
        text: 'Transcribing audio...',
      ));
    });
    _scrollToBottom();

    try {
      final result = await _service.unifiedChat(
        widget: widget.widgetItem,
        userId: _userId!,
        audioFile: PlatformFile(
          name: audioFile.path.split('/').last,
          path: audioFile.path,
          size: await audioFile.length(),
        ),
      );

      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        final data = result['data'];
        _messages.add(_UnifiedMessage(
          id: (messageId + 2).toString(),
          role: 'ai',
          type: 'transcript',
          text: data['text'] ?? 'No transcript',
          transcriptId: data['transcriptId'],
        ));
        if (data['summary'] != null) {
          _messages.add(_UnifiedMessage(
            id: (messageId + 3).toString(),
            role: 'ai',
            type: 'ai_text',
            text: '🤖 AI Response:\n${data['summary']}',
          ));
        }
      });
    } catch (error) {
      print("API ERROR: $error");
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == loadingId);
        _messages.add(_UnifiedMessage(
          id: (messageId + 2).toString(),
          role: 'ai',
          type: 'error',
          text: 'Something went wrong. Please try again.',
        ));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  void _applyHistory(Map<String, dynamic> history) {
    setState(() {
      _messages.clear();
      _messages.addAll([
        _UnifiedMessage(role: 'user', type: 'user_text', id: 'h1', text: history['prompt'] ?? ''),
        _UnifiedMessage(role: 'ai', type: 'ai_text', id: 'h2', text: history['content'] ?? ''),
      ]);
    });
    _scrollToBottom();
  }

  // 🔥 FIX 4: Smooth Scroll Animation (no more jumping)
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _scrollController.positions.isNotEmpty) {
        _scrollController.animateTo(
  _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Start a conversation...",
        style: TextStyle(
          color: Colors.white60,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildMessage(_UnifiedMessage message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == 'image')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image, color: Colors.purple, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🖼️ Image', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(message.text ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        if (message.fileSize != null)
                          Text('${(message.fileSize! / 1024).round()} KB', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )
            else if (message.type == 'pdf')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📄 PDF Document', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(message.text ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        if (message.fileSize != null)
                          Text('${(message.fileSize! / 1024).round()} KB', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )
            else if (message.type == 'audio')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎵 Audio File', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(message.text ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        if (message.fileSize != null)
                          Text('${(message.fileSize! / 1024).round()} KB', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )
            else if (message.type == 'file')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📎 Attached File', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(message.text ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                        if (message.fileSize != null)
                          Text('${(message.fileSize! / 1024).round()} KB', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )
            else if (message.type == 'user_audio')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.white70, size: 24),
                    const SizedBox(width: 8),
                    Text(message.text ?? 'Audio', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              )
            else if (message.type == 'loading')
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _presentation.accentColor)),
                    const SizedBox(width: 8),
                    Text(message.text ?? '', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              )
            else if (message.type == 'transcript')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📄 Transcript:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    SelectableText(message.text ?? '', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            else if (message.type == 'error')
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.15),
                  border: Border.all(color: Colors.red.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '⚠️ Unable to process request. Try again.',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            else if (message.type == 'ai_text')
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🤖 AI Response:', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(message.text ?? '', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                constraints: const BoxConstraints(maxWidth: 620),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isUser
                        ? [_presentation.accentColor.withOpacity(0.56), const Color(0xFF44D7FF).withOpacity(0.36)]
                        : [Colors.white.withOpacity(0.16), Colors.white.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SelectableText(message.text ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45)),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ FINAL CLEAN COMPOSER - NO DUPLICATE CODE
  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // 🔥 FIX 1: Single block for ALL audio widgets (including 'file' type)
                if (_supportsAudioInput || _supportsMediaAttachments) ...[
                  IconButton(
                    onPressed: _pickFile,
                    icon: Icon(Icons.attach_file, color: _presentation.accentColor),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_supportsMediaAttachments) ...[
                    IconButton(
                      onPressed: _pickImage,
                      icon: Icon(Icons.image_outlined, color: _presentation.accentColor),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (_supportsAudioInput)
                    IconButton(
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: _presentation.accentColor),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  if (_isRecording && _supportsAudioInput)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        '${_recordingDuration.inMinutes}:${(_recordingDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                    ),
                  if (_tempAudioPath != null && !_isRecording && _supportsAudioInput)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Tooltip(message: 'Audio ready', child: const Icon(Icons.check_circle, color: Colors.green)),
                    ),
                  const SizedBox(width: 12),
                ],

                // 🔥 FIX 2: Text input for chat screen widgets (Legal/Medical get text + audio)
                if (_presentation.screenType == 'chat') ...[
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _focusNode,
                      enabled: !_isSending && !_isRecording,
                      minLines: 1,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: _presentation.inputLabel ?? 'Type your message...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Send button (always show)
                Opacity(
                  opacity: _canSend ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: !_canSend,
                    child: GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [_presentation.accentColor, const Color(0xFF44D7FF)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return MyAiGlassScreen(
      // ✅ FIX 3: Force correct title from widget name
      title: widget.widgetItem.widgetName.isNotEmpty 
          ? widget.widgetItem.widgetName 
          : _presentation.heading,
      subtitle: _presentation.description,
      actions: [
        IconButton(onPressed: _openHistorySheet, icon: const Icon(Icons.history, size: 20)),
        IconButton(onPressed: _clearChat, icon: const Icon(Icons.clear_all, size: 20)),
      ],
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildMessage(_messages[index]),
                  ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }
}

class _UnifiedMessage {
  final String id;
  final String role;
  final String type;
  final String? text;
  final String? transcriptId;
  final int? fileSize;
  final String? fileExtension;

  const _UnifiedMessage({
    required this.id,
    required this.role,
    required this.type,
    this.text,
    this.transcriptId,
    this.fileSize,
    this.fileExtension,
  });
}