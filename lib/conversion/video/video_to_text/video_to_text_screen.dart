import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/conversion_chat_screen.dart';
import 'package:pina/conversion/video/video_to_text/video_to_text_logic.dart';
import 'package:pina/conversion/video/video_to_text/video_to_text_params.dart';

class VideoToTextScreen extends StatelessWidget {
  final String userId;
  final String? userEmail;
  final double temperature;

  const VideoToTextScreen({
    super.key,
    this.userId = "0",
    this.userEmail,
    this.temperature = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final logic = VideoToTextLogic();
    final baseParams = VideoToTextParams(temperature: temperature);

    return ConversionChatScreen(
      title: "Video to Text",
      fromType: baseParams.from,
      toType: baseParams.to,
      userId: userId,
      userEmail: userEmail,
      initialTemperature: baseParams.temperature,
      getParametersConfig: () => VideoToTextParams.parametersConfig,
      onSubmit: ({
        required String prompt,
        required String? provider,
        required double temperature,
        required String userId,
        File? file,
        Map<String, dynamic>? parameters,
      }) {
        final params = baseParams.copyWith(
          provider: provider,
          temperature: temperature,
        );

        return logic.submit(
          prompt: prompt,
          userId: userId,
          params: params,
          parameters: parameters ?? {},
          file: file,
        );
      },

    );
  }
}
