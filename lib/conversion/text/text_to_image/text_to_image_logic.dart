import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/text/text_to_image/text_to_image_params.dart';

class TextToImageLogic {
  final AiRequestService _aiRequestService;

  TextToImageLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for image generation
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Art Style
    if (parameters['artStyle'] != null) {
      final style = parameters['artStyle'].toString();
      modifiers.add('$style style');
    }
    
    // Lighting
    if (parameters['lighting'] != null) {
      final light = parameters['lighting'].toString();
      modifiers.add('$light lighting');
    }
    
    // Camera Angle
    if (parameters['cameraAngle'] != null) {
      final angle = parameters['cameraAngle'].toString();
      modifiers.add('$angle camera angle');
    }
    
    // Detail Level
    if (parameters['detailLevel'] != null) {
      final detail = parameters['detailLevel'].toString();
      modifiers.add('$detail detail');
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required TextToImageParams params,
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
