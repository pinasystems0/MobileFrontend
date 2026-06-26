import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/audio/audio_to_image/audio_to_image_params.dart';

class AudioToImageLogic {
  final AiRequestService _aiRequestService;

  AudioToImageLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for audio to image conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Art Style
    if (parameters['artStyle'] != null) {
      final style = parameters['artStyle'].toString();
      modifiers.add('$style style');
    }
    
    // Color Theme
    if (parameters['colorTheme'] != null) {
      final theme = parameters['colorTheme'].toString();
      modifiers.add('$theme color theme');
    }
    
    // Detail Level
    if (parameters['detailLevel'] != null) {
      final detail = parameters['detailLevel'].toString();
      modifiers.add('$detail detail');
    }
    
    // Negative Prompt
    if (parameters['negativePrompt'] != null && 
        parameters['negativePrompt'].toString().isNotEmpty) {
      // Negative prompt is handled separately in the API, not added to prompt
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required AudioToImageParams params,
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
