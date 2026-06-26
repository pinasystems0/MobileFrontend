import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/audio/audio_to_video/audio_to_video_params.dart';

class AudioToVideoLogic {
  final AiRequestService _aiRequestService;

  AudioToVideoLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for audio to video conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Video Style
    if (parameters['videoStyle'] != null) {
      final style = parameters['videoStyle'].toString();
      modifiers.add('$style style');
    }
    
    // Duration
    if (parameters['duration'] != null) {
      final duration = parameters['duration'].toString();
      modifiers.add('with $duration duration');
    }
    
    // Frame Rate
    if (parameters['frameRate'] != null) {
      final fps = parameters['frameRate'].toString();
      modifiers.add('at $fps frame rate');
    }
    
    // Subtitle
    if (parameters['subtitle'] != null) {
      final subtitle = parameters['subtitle'].toString();
      if (subtitle == 'On') {
        modifiers.add('include subtitles');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required AudioToVideoParams params,
    Map<String, dynamic> parameters = const {},
    File? file,
  }) {
    // Build enhanced prompt with parameters
    final enhancedPrompt = _buildEnhancedPrompt(prompt, parameters);
    
    return _aiRequestService.generateAIResponse(
      prompt: enhancedPrompt,
      from: params.from,
      to: params.to,
      temperature: params.temperature,
      userId: userId,
      provider: params.provider,
      parameters: parameters,
      file: file,
    );
  }
}
