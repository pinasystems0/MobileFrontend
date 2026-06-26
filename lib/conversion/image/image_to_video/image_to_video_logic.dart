import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/image/image_to_video/image_to_video_params.dart';

class ImageToVideoLogic {
  final AiRequestService _aiRequestService;

  ImageToVideoLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers for image to video conversion
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Animation Style
    if (parameters['animationStyle'] != null) {
      final style = parameters['animationStyle'].toString();
      modifiers.add('$style animation style');
    }
    
    // Camera Motion
    if (parameters['cameraMotion'] != null) {
      final motion = parameters['cameraMotion'].toString();
      if (motion != 'Static') {
        modifiers.add('with $motion camera movement');
      }
    }
    
    // Transition Effect
    if (parameters['transitionEffect'] != null) {
      final transition = parameters['transitionEffect'].toString();
      modifiers.add('Use $transition transitions');
    }
    
    // Duration - include as info
    if (parameters['duration'] != null) {
      final duration = parameters['duration'].toString();
      modifiers.add('Create a $duration video');
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required ImageToVideoParams params,
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

