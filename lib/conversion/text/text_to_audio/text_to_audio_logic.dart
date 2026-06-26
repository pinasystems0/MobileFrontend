import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/text/text_to_audio/text_to_audio_params.dart';

class TextToAudioLogic {
  final AiRequestService _aiRequestService;

  TextToAudioLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for audio generation
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Voice
    if (parameters['voice'] != null) {
      final voice = parameters['voice'].toString();
      modifiers.add('$voice voice');
    }
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('$lang language');
    }
    
    // Pitch
    if (parameters['pitch'] != null) {
      final pitch = parameters['pitch'].toString();
      modifiers.add('$pitch pitch');
    }
    
    // Emotion
    if (parameters['emotion'] != null) {
      final emotion = parameters['emotion'].toString();
      modifiers.add('$emotion emotion');
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required TextToAudioParams params,
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
