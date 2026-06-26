import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/audio/audio_to_audio/audio_to_audio_params.dart';

class AudioToAudioLogic {
  final AiRequestService _aiRequestService;

  AudioToAudioLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for audio to audio conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Voice Style
    if (parameters['voiceStyle'] != null) {
      final voice = parameters['voiceStyle'].toString();
      modifiers.add('use $voice voice');
    }
    
    // Pitch
    if (parameters['pitch'] != null) {
      final pitch = parameters['pitch'].toString();
      modifiers.add('$pitch pitch');
    }
    
    // Emotion
    if (parameters['emotion'] != null) {
      final emotion = parameters['emotion'].toString();
      modifiers.add('with $emotion emotion');
    }
    
    // Description Style
    if (parameters['descriptionStyle'] != null) {
      final style = parameters['descriptionStyle'].toString();
      if (style == 'Story') {
        modifiers.add('as a story');
      } else if (style == 'Technical') {
        modifiers.add('in technical style');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required AudioToAudioParams params,
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
