import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/chat_message.dart';
import 'package:pina/conversion/shared/conversion_theme.dart';
import 'package:pina/conversion/shared/file_handler.dart';
import 'package:pina/conversion/shared/provider_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pina/conversion/shared/audio_url_player.dart';
import 'package:video_player/video_player.dart';

typedef ConversionSubmitter = Future<Map<String, dynamic>> Function({
  required String prompt,
  required String? provider,
  required double temperature,
  required String userId,
  File? file,
  Map<String, dynamic>? parameters,
});

class _ProviderOption {
  final String label;
  final String? provider;

  const _ProviderOption({required this.label, required this.provider});
}

// Video Player Widget
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  
  const VideoPlayerWidget({super.key, required this.url});
  
  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400),
            const SizedBox(height: 8),
            const Text("Failed to load video"),
            const SizedBox(height: 8),
            Text(
              widget.url,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    
    if (!_isInitialized) {
      return Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: () {
                _controller.seekTo(Duration.zero);
                _controller.play();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ConversionChatScreen extends StatefulWidget {
  final String title;
  final String fromType;
  final String toType;
  final String userId;
  final String? userEmail;
  final double initialTemperature;
  final ConversionSubmitter onSubmit;
  final List<Map<String, dynamic>> Function()? getParametersConfig;

  const ConversionChatScreen({
    super.key,
    required this.title,
    required this.fromType,
    required this.toType,
    required this.userId,
    this.userEmail,
    this.initialTemperature = 0.7,
    required this.onSubmit,
    this.getParametersConfig,
  });

  @override
  State<ConversionChatScreen> createState() => _ConversionChatScreenState();
}

class _ConversionChatScreenState extends State<ConversionChatScreen> {
  static const String _autoProviderToken = "__auto_mode__";

  // Text to Something conversions
  bool get _isTextToAudio =>
      widget.fromType.toLowerCase() == "text" && widget.toType.toLowerCase() == "audio";
  
  bool get _isTextToText =>
      widget.fromType.toLowerCase() == "text" && widget.toType.toLowerCase() == "text";
  
  bool get _isTextToImage =>
      widget.fromType.toLowerCase() == "text" && widget.toType.toLowerCase() == "image";
  
  bool get _isTextToVideo =>
      widget.fromType.toLowerCase() == "text" && widget.toType.toLowerCase() == "video";
  
  // Image to Something conversions
  bool get _isImageToText =>
      widget.fromType.toLowerCase() == "image" && widget.toType.toLowerCase() == "text";
  
  // Audio to Something conversions
  bool get _isAudioToText =>
      widget.fromType.toLowerCase() == "audio" && widget.toType.toLowerCase() == "text";

  final ProviderService _providerService = ProviderService();
  List<ProviderInfo> _availableProviders = [];
  bool _isLoadingProviders = false;

  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final SpeechToText _speech = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  final List<ChatMessage> messages = [];

  String? _selectedProvider;
  late double _temperature;
  bool _isLoading = false;
  File? _attachedFile;

  Map<String, dynamic> _selectedParameters = {};

  @override
  void initState() {
    super.initState();
    _temperature = widget.initialTemperature;
    _initSpeech();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoadingProviders = true);

    try {
      final providers = await _providerService.getProviders(
        fromType: widget.fromType.toLowerCase(),
        toType: widget.toType.toLowerCase(),
      );

      if (mounted) {
        setState(() {
          _availableProviders = providers;
          _isLoadingProviders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProviders = false;
        });
      }
    }
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    if (!_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Speech recognition not available on this device"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      debugPrint("REAL ERROR: Speech recognition not available");
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Speech recognition is not available on this device"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    } else {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please enable microphone permission to use voice input"),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint("REAL ERROR: Microphone permission denied");
        return;
      }

      setState(() {
        _isListening = true;
      });
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _promptController.text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      );
    }
  }

  void _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitPrompt({String? promptOverride}) async {
    final prompt = promptOverride ?? _promptController.text.trim();
    if (prompt.isEmpty && _attachedFile == null) return;
    if (_isLoading) return;

    setState(() {
      if (prompt.isNotEmpty) {
        messages.add(
          ChatMessage(role: "user", content: prompt, timestamp: DateTime.now()),
        );
      } else if (_attachedFile != null) {
        String fileLabel = _isImageToText ? "[Image Uploaded]" : 
                           _isAudioToText ? "[Audio Uploaded]" : 
                           "[File Uploaded]";
        messages.add(
          ChatMessage(role: "user", content: fileLabel, timestamp: DateTime.now()),
        );
      }
      _isLoading = true;
      if (promptOverride == null) {
        _promptController.clear();
      }
    });
    _scrollToBottom();

    final response = await widget.onSubmit(
      prompt: prompt,
      provider: _selectedProvider,
      temperature: _temperature,
      userId: widget.userId,
      file: _attachedFile,
      parameters: _selectedParameters,
    );

    if (!mounted) return;

    setState(() {
      String responseContent = _extractContent(response);
      
      messages.add(
        ChatMessage(
          role: "assistant",
          content: responseContent,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
      _attachedFile = null; // Clear attached file after submission
    });
    _scrollToBottom();
  }

  Future<void> _regenerateLastResponse() async {
    if (messages.isEmpty) return;
    
    ChatMessage? lastUserMessage;
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == "user") {
        lastUserMessage = messages[i];
        break;
      }
    }
    
    if (lastUserMessage == null) return;
    
    setState(() {
      if (messages.isNotEmpty && messages.last.role == "assistant") {
        messages.removeLast();
      }
      if (messages.isNotEmpty && messages.last.role == "user") {
        messages.removeLast();
      }
    });
    
    await _submitPrompt(promptOverride: lastUserMessage.content);
  }

  Future<void> _attachFile() async {
    File? selected;

    // For Image → Text, only allow image selection
    if (_isImageToText) {
      selected = await FileHandler.pickImage();
    } 
    // For Audio → Text, only allow audio selection
    else if (_isAudioToText) {
      selected = await FileHandler.pickAudio();
    }
    else {
      // For other conversions, allow based on fromType
      switch (widget.fromType) {
        case "Image":
          selected = await FileHandler.pickImage();
          break;
        case "Audio":
          selected = await FileHandler.pickAudio();
          break;
        default:
          selected = await FileHandler.pickFile();
      }
    }

    if (!mounted || selected == null) return;

    setState(() => _attachedFile = selected);

    final fileName = selected.path.split(RegExp(r"[\\/]")).last;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attached: $fileName")),
    );
  }

  void _showMicInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice input is not implemented yet.")),
    );
  }

  Future<void> _showProviderSelector() async {
    if (_isLoadingProviders) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text("Loading providers..."),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final List<_ProviderOption> providerOptions = [
      _ProviderOption(label: "Auto Mode (Default)", provider: null),
      ..._availableProviders.map((p) => _ProviderOption(
        label: p.displayLabel,
        provider: p.providerKey,
      )),
    ];

    final selectedProviderToken = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: ConversionTheme.primaryGradient,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            "Select AI Provider",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: providerOptions.length,
                        itemBuilder: (context, index) {
                          final option = providerOptions[index];
                          final isSelected = option.provider == _selectedProvider;

                          return ListTile(
                            leading: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? ConversionTheme.primaryPurple
                                  : Colors.grey,
                            ),
                            title: Text(
                              option.label,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? ConversionTheme.primaryPurple
                                    : null,
                              ),
                            ),
                            onTap: () => Navigator.of(context).pop(
                              option.provider ?? _autoProviderToken,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (!mounted || selectedProviderToken == null) return;
    setState(
      () => _selectedProvider = selectedProviderToken == _autoProviderToken
          ? null
          : selectedProviderToken,
    );
  }

  String mapError(String error) {
    debugPrint("REAL API ERROR: $error");
    if (error.toLowerCase().contains('timeout') || error.toLowerCase().contains('slow')) {
      return "Connection seems slow. Please try again in a moment.";
    } else if (error.toLowerCase().contains('network') || error.toLowerCase().contains('socket')) {
      return "No internet connection. Please check your network.";
    } else if (error.toLowerCase().contains('permission') || error.toLowerCase().contains('microphone')) {
      return "Please enable microphone permission.";
    }
    return "Oops! Something went wrong. Please try again.";
  }

  /// Improved content extraction - supports multiple response formats
  String _extractContent(Map<String, dynamic> response) {
    // Check for error first
    if (response["success"] == false && response["error"] is String) {
      return mapError(response["error"] as String);
    }

    // Priority 1: Standard 'content' field
    if (response["content"] is String) {
      return response["content"] as String;
    }
    
    // Priority 2: 'url' field (for image/video URLs)
    if (response["url"] is String) {
      return response["url"] as String;
    }
    
    // Priority 3: 'videoUrl' field
    if (response["videoUrl"] is String) {
      return response["videoUrl"] as String;
    }
    
    // Priority 4: 'imageUrl' field
    if (response["imageUrl"] is String) {
      return response["imageUrl"] as String;
    }
    
    // Priority 5: 'audioUrl' field
    if (response["audioUrl"] is String) {
      return response["audioUrl"] as String;
    }
    
    // Priority 6: 'text' field
    if (response["text"] is String) {
      return response["text"] as String;
    }
    
    // Priority 7: 'response' field
    if (response["response"] is String) {
      return response["response"] as String;
    }

    // Priority 8: Nested in 'message'
    if (response["message"] is Map<String, dynamic>) {
      final message = response["message"] as Map<String, dynamic>;
      if (message["content"] is String) {
        return message["content"] as String;
      }
      if (message["url"] is String) {
        return message["url"] as String;
      }
    }

    // Priority 9: From choices array (OpenAI format)
    if (response["choices"] is List && (response["choices"] as List).isNotEmpty) {
      final first = (response["choices"] as List).first;
      if (first is Map<String, dynamic>) {
        if (first["text"] is String) return first["text"] as String;
        if (first["message"] is Map<String, dynamic>) {
          final msg = first["message"] as Map<String, dynamic>;
          if (msg["content"] is String) return msg["content"] as String;
        }
      }
    }

    // Priority 10: Check if entire response is just a string URL
    if (response.toString().startsWith("http://") || response.toString().startsWith("https://")) {
      return response.toString();
    }

    return "No response content available.";
  }

  /// Check if content is a URL
  bool _isUrl(String content) {
    return content.startsWith("http://") || content.startsWith("https://");
  }

  /// Check if URL is for audio - based on toType
  bool _isAudioUrl(String url) {
    return _isUrl(url) && widget.toType.toLowerCase() == "audio";
  }

  /// Check if URL is for image - based on toType
  bool _isImageUrl(String url) {
    return _isUrl(url) && widget.toType.toLowerCase() == "image";
  }

  /// Check if URL is for video - based on toType
  bool _isVideoUrl(String url) {
    return _isUrl(url) && widget.toType.toLowerCase() == "video";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show text input (hide for Image→Text and Audio→Text)
    final bool showTextInput = !_isImageToText && !_isAudioToText;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ConversionTheme.primaryPurple,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: ConversionTheme.primaryGradient,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ConversionTheme.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ConversionTheme.chatContainerDecoration,
                    child: messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  ConversionTheme.emptyStateIcon,
                                  size: 64,
                                  color: ConversionTheme.primaryPurple.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Start the conversation",
                                  style: ConversionTheme.emptyStateTextStyle.copyWith(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isImageToText
                                      ? "Upload an image to begin"
                                      : _isAudioToText
                                          ? "Upload an audio file to begin"
                                          : "Enter a prompt below to begin",
                                  style: ConversionTheme.emptyStateTextStyle,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: messages.length + (_isLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (_isLoading && index == messages.length) {
                                return _buildTypingBubble();
                              }
                              return _buildChatBubble(messages[index]);
                            },
                          ),
                  ),
                ),
                // Attached file chip
                if (_attachedFile != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        _attachedFile!.path.split(RegExp(r"[\\/]")).last,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: ConversionTheme.primaryPurple,
                      onDeleted: () => setState(() => _attachedFile = null),
                      deleteIcon: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Input row - Hide for Image→Text and Audio→Text
                if (showTextInput)
                  Container(
                    decoration: ConversionTheme.inputContainerDecoration,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promptController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _submitPrompt(),
                            decoration: ConversionTheme.inputDecoration(
                              hintText: "Enter your prompt...",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                // Action buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Attach file button - Show for:
                    // 1. Image → Text (to upload images)
                    // 2. Audio → Text (to upload audio)
                    // 3. Non-text source conversions (Image→X, Audio→X, etc.)
                    if (_isImageToText || _isAudioToText || 
                        (!_isTextToAudio && !_isTextToText && !_isTextToImage && !_isTextToVideo))
                      _buildIconActionButton(
                        icon: Icons.attach_file,
                        tooltip: _isImageToText ? "Upload Image" : 
                                _isAudioToText ? "Upload Audio" : 
                                "Attach file",
                        onPressed: _attachFile,
                      ),
                    // ========== FIXED: Mic button - Show for ALL text-based conversions ==========
                    if (widget.fromType.toLowerCase() == "text")
                      Container(
                        decoration: BoxDecoration(
                          color: _isListening
                              ? Colors.red.withOpacity(0.1)
                              : ConversionTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isListening
                                ? Colors.red
                                : Colors.grey.shade300,
                            width: _isListening ? 2 : 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _startListening,
                          tooltip: _isListening ? "Stop listening" : "Voice input",
                          icon: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: _isListening
                                ? Colors.red
                                : ConversionTheme.primaryPurple,
                          ),
                        ),
                      ),
                    // Parameters selector button
                    _buildParametersButton(),
                    // Provider selector button with gradient
                    _buildProviderButton(),
                  ],
                ),
                const SizedBox(height: 12),
                // Submit button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ConversionTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(
          icon,
          color: ConversionTheme.primaryPurple,
        ),
      ),
    );
  }

  Widget _buildProviderButton() {
    return Container(
      decoration: ConversionTheme.providerButtonDecoration,
      child: IconButton(
        onPressed: _showProviderSelector,
        tooltip: _selectedProvider == null
            ? "Provider: Auto Mode"
            : "Provider: $_selectedProvider",
        icon: const Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildParametersButton() {
    final hasParameters = _selectedParameters.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: hasParameters 
            ? ConversionTheme.primaryPurple.withOpacity(0.15)
            : ConversionTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasParameters 
              ? ConversionTheme.primaryPurple 
              : Colors.grey.shade300,
          width: hasParameters ? 2 : 1,
        ),
      ),
      child: IconButton(
        onPressed: _showParametersSelector,
        tooltip: hasParameters 
            ? "Parameters: ${_selectedParameters.keys.length} selected"
            : "Parameters",
        icon: Icon(
          hasParameters ? Icons.settings : Icons.tune,
          color: hasParameters 
              ? ConversionTheme.primaryPurple 
              : ConversionTheme.primaryPurple,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getParametersConfig() {
    if (widget.getParametersConfig != null) {
      return widget.getParametersConfig!();
    }
    return [];
  }

  Future<void> _showParametersSelector() async {
    final paramsConfig = _getParametersConfig();
    
    if (paramsConfig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No parameters available for this conversion type"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final tempSelected = Map<String, dynamic>.from(_selectedParameters);
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      gradient: ConversionTheme.primaryGradient,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.tune, color: Colors.white),
                        const SizedBox(width: 12),
                        const Text(
                          "Parameters",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: paramsConfig.length,
                      itemBuilder: (context, index) {
                        final param = paramsConfig[index];
                        final key = param['key'] ?? param['name'].toString().toLowerCase();
                        final label = param['name'] as String;
                        final type = param['type'] as String;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ConversionTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (type == 'dropdown')
                                _buildDropdownParam(
                                  param: param,
                                  key: key,
                                  value: tempSelected[key] ?? param['default'],
                                  onChanged: (value) {
                                    setModalState(() {
                                      tempSelected[key] = value;
                                    });
                                  },
                                )
                              else if (type == 'slider')
                                _buildSliderParam(
                                  param: param,
                                  key: key,
                                  value: tempSelected[key] ?? param['default'],
                                  onChanged: (value) {
                                    setModalState(() {
                                      tempSelected[key] = value;
                                    });
                                  },
                                )
                              else if (type == 'number')
                                _buildNumberParam(
                                  param: param,
                                  key: key,
                                  value: tempSelected[key] ?? param['default'],
                                  onChanged: (value) {
                                    setModalState(() {
                                      tempSelected[key] = value;
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempSelected.clear();
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Colors.grey),
                            ),
                            child: const Text("Clear All"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: ConversionTheme.sendButtonDecoration,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedParameters = Map.from(tempSelected);
                                });
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "Apply Parameters",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownParam({
    required Map<String, dynamic> param,
    required String key,
    required dynamic value,
    required Function(dynamic) onChanged,
  }) {
    final options = param['options'] as List;
    return DropdownButtonFormField<dynamic>(
      value: value,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: options.map((option) {
        return DropdownMenuItem<dynamic>(
          value: option,
          child: Text(option.toString()),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
    );
  }

  Widget _buildSliderParam({
    required Map<String, dynamic> param,
    required String key,
    required dynamic value,
    required Function(double) onChanged,
  }) {
    final min = param['min'] as double;
    final max = param['max'] as double;
    final currentValue = value as double? ?? param['default'] as double;
    
    return Column(
      children: [
        Slider(
          value: currentValue.clamp(min, max),
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          activeColor: ConversionTheme.primaryPurple,
          onChanged: onChanged,
        ),
        Text(
          currentValue.toStringAsFixed(1),
          style: TextStyle(
            color: ConversionTheme.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberParam({
    required Map<String, dynamic> param,
    required String key,
    required dynamic value,
    required Function(int) onChanged,
  }) {
    final min = param['min'] as int;
    final max = param['max'] as int;
    final currentValue = value as int? ?? param['default'] as int;
    
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: currentValue > min 
              ? () => onChanged((currentValue - 100).clamp(min, max))
              : null,
          color: ConversionTheme.primaryPurple,
        ),
        Expanded(
          child: Text(
            currentValue.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: currentValue < max 
              ? () => onChanged((currentValue + 100).clamp(min, max))
              : null,
          color: ConversionTheme.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    // Disable submit for Image→Text or Audio→Text if no file attached
    final bool isDisabled = (_isImageToText || _isAudioToText) && _attachedFile == null;
    
    String buttonText = "Submit";
    if (_isImageToText) {
      buttonText = "Analyze Image";
    } else if (_isAudioToText) {
      buttonText = "Transcribe Audio";
    }
    
    return Container(
      width: double.infinity,
      height: 52,
      decoration: ConversionTheme.sendButtonDecoration,
      child: ElevatedButton(
        onPressed: (isDisabled || _isLoading) ? null : _submitPrompt,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.role == "user";
    final String content = message.content.trim();
    
    // Detection based on toType - this works for ANY source (text, image, audio, video)
    final bool isAudio = !isUser && _isAudioUrl(content);
    final bool isImage = !isUser && _isImageUrl(content);
    final bool isVideo = !isUser && _isVideoUrl(content);

    Widget bubbleChild;
    
    if (isAudio) {
      bubbleChild = AudioUrlPlayer(url: content);
    } else if (isImage) {
      bubbleChild = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          content,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade300),
                  const SizedBox(height: 8),
                  const Text("Failed to load image"),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    } else if (isVideo) {
      bubbleChild = VideoPlayerWidget(url: content);
    } else {
      bubbleChild = Text(
        content,
        style: TextStyle(
          color: isUser ? ConversionTheme.userBubbleText : ConversionTheme.primaryText,
          fontSize: 15,
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: (isImage || isVideo) ? 300 : 320,
            ),
            decoration: isUser
                ? ConversionTheme.userBubbleDecoration
                : ConversionTheme.aiBubbleDecoration,
            child: bubbleChild,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: isUser
                ? _buildUserMessageActions(message)
                : _buildAIMessageActions(message),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildUserMessageActions(ChatMessage message) {
    return [
      _buildActionButton(
        icon: Icons.edit,
        tooltip: "Edit",
        onPressed: () async {
          final editedText = await ConversionTheme.showEditDialog(
            context, 
            message.content,
          );
          if (editedText != null && editedText.isNotEmpty) {
            final index = messages.indexOf(message);
            if (index != -1) {
              setState(() {
                messages[index] = ChatMessage(
                  role: "user",
                  content: editedText,
                  timestamp: message.timestamp,
                );
              });
              await _submitPrompt(promptOverride: editedText);
            }
          }
        },
      ),
      const SizedBox(width: 8),
      _buildActionButton(
        icon: Icons.copy,
        tooltip: "Copy",
        onPressed: () {
          ConversionTheme.copyToClipboard(context, message.content);
        },
      ),
      const SizedBox(width: 8),
      _buildActionButton(
        icon: Icons.refresh,
        tooltip: "Resend",
        onPressed: () async {
          await _submitPrompt(promptOverride: message.content);
        },
      ),
    ];
  }

  List<Widget> _buildAIMessageActions(ChatMessage message) {
    return [
      _buildActionButton(
        icon: Icons.copy,
        tooltip: "Copy",
        onPressed: () {
          ConversionTheme.copyToClipboard(context, message.content);
        },
      ),
      const SizedBox(width: 8),
      _buildActionButton(
        icon: Icons.auto_fix_high,
        tooltip: "Regenerate",
        onPressed: _regenerateLastResponse,
      ),
    ];
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: ConversionTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: ConversionTheme.actionIconSize,
            color: ConversionTheme.primaryPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: ConversionTheme.aiBubbleDecoration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ConversionTheme.primaryPurple,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Generating...",
              style: ConversionTheme.loadingTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}