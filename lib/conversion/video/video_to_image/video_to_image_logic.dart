import 'dart:io';

import 'package:pina/conversion/shared/ai_request_service.dart';
import 'package:pina/conversion/video/video_to_image/video_to_image_params.dart';

class VideoToImageLogic {
  final AiRequestService _aiRequestService;

  VideoToImageLogic({AiRequestService? aiRequestService})
      : _aiRequestService = aiRequestService ?? AiRequestService();

  /// Build enhanced prompt with parameter modifiers
  String _buildEnhancedPrompt(String prompt, Map<String, dynamic> parameters) {
    if (parameters.isEmpty) return prompt;
    
    final modifiers = <String>[];
    
    // Frame Selection
    if (parameters['frameSelection'] != null) {
      final frame = parameters['frameSelection'].toString();
      modifiers.add('extract $frame from video');
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
    
    // Art Style
    if (parameters['artStyle'] != null) {
      final style = parameters['artStyle'].toString();
      modifiers.add('in $style style');
    }
    
    // Detail Level
    if (parameters['detailLevel'] != null) {
      final detail = parameters['detailLevel'].toString().toLowerCase();
      modifiers.add('with $detail detail level');
    }
    
    // Color Theme
    if (parameters['colorTheme'] != null) {
      final color = parameters['colorTheme'].toString();
      modifiers.add('using $color color theme');
    }
    
    if (modifiers.isEmpty) return prompt;
    return '$prompt. ${modifiers.join('. ')}.';
  }

  Future<Map<String, dynamic>> submit({
    required String prompt,
    required String userId,
    required VideoToImageParams params,
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
