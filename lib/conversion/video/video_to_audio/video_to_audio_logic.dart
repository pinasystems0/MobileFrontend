import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/video/video_to_audio/video_to_audio_params.dart';

class VideoToAudioLogic {
  final AiRequestService _aiRequestService;

  VideoToAudioLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Audio Format
    if (parameters['audioFormat'] != null) {
      final format = parameters['audioFormat'].toString();
      modifiers.add('output format: $format');
    }
    
    // Language
    if (parameters['language'] != null) {
      final lang = parameters['language'].toString();
      modifiers.add('in $lang language');
    }
    
    // Noise Reduction
    if (parameters['noiseReduction'] != null) {
      final noise = parameters['noiseReduction'].toString().toLowerCase();
      if (noise == 'on') {
        modifiers.add('apply noise reduction');
      }
    }
    
    // Voice Style
    if (parameters['voiceStyle'] != null) {
      final voice = parameters['voiceStyle'].toString();
      modifiers.add('use $voice voice');
    }
    
    // Speed
    if (parameters['speed'] != null) {
      final speed = parameters['speed'];
      modifiers.add('at ${speed}x speed');
    }
    
    // Volume Normalize
    if (parameters['volumeNormalize'] != null) {
      final volume = parameters['volumeNormalize'].toString().toLowerCase();
      if (volume == 'on') {
        modifiers.add('normalize volume levels');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required VideoToAudioParams params,
    Map<String, dynamic> parameters = const {},
    File? file,
  }) async {
    // Build enhanced prompt with parameters
    final enhancedPrompt = _buildEnhancedPrompt(prompt, parameters);
    
    final response = await _aiRequestService.generateAIResponse(
      prompt: enhancedPrompt,
      from: params.from,
      to: params.to,
      temperature: params.temperature,
      userId: userId,
      provider: params.provider,
      parameters: parameters,
      file: file,
    );
    
    return response;
  }
}
