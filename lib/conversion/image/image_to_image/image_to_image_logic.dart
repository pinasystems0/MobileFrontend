import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/image/image_to_image/image_to_image_params.dart';

class ImageToImageLogic {
  final AiRequestService _aiRequestService;

  ImageToImageLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for image to image conversion
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
    
    // Detail Level
    if (parameters['detailLevel'] != null) {
      final detail = parameters['detailLevel'].toString();
      if (detail == 'Low') {
        modifiers.add('simple details');
      } else if (detail == 'High') {
        modifiers.add('highly detailed');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join(', ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required ImageToImageParams params,
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
