import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/video/video_to_video/video_to_video_params.dart';

class VideoToVideoLogic {
  final AiRequestService _aiRequestService;

  VideoToVideoLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Video Style
    if (parameters['videoStyle'] != null) {
      final style = parameters['videoStyle'].toString();
      modifiers.add('in $style style');
    }
    
    // Duration
    if (parameters['duration'] != null) {
      final duration = parameters['duration'].toString();
      modifiers.add('with $duration duration');
    }
    
    // Resolution
    if (parameters['resolution'] != null) {
      final res = parameters['resolution'].toString();
      modifiers.add('at $res resolution');
    }
    
    // Aspect Ratio
    if (parameters['aspectRatio'] != null) {
      final ratio = parameters['aspectRatio'].toString();
      modifiers.add('with $ratio aspect ratio');
    }
    
    // Frame Rate
    if (parameters['frameRate'] != null) {
      final fps = parameters['frameRate'].toString();
      modifiers.add('at $fps frame rate');
    }
    
    // Transition Effect
    if (parameters['transitionEffect'] != null) {
      final effect = parameters['transitionEffect'].toString();
      modifiers.add('using $effect transition effect');
    }
    
    // Subtitle
    if (parameters['subtitle'] != null) {
      final subtitle = parameters['subtitle'].toString().toLowerCase();
      if (subtitle == 'on') {
        modifiers.add('add subtitles');
      }
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required VideoToVideoParams params,
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
