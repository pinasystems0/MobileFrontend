import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/text/text_to_video/text_to_video_params.dart';

class TextToVideoLogic {
  final AiRequestService _aiRequestService;

  TextToVideoLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for video generation
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
      final dur = parameters['duration'].toString();
      modifiers.add('duration: $dur');
    }
    
    // Camera Motion
    if (parameters['cameraMotion'] != null) {
      final motion = parameters['cameraMotion'].toString();
      modifiers.add('$motion camera motion');
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required TextToVideoParams params,
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
