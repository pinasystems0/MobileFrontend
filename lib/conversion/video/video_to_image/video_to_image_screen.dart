import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pina/conversion/shared/conversion_chat_screen.dart';
import 'package:pina/conversion/video/video_to_image/video_to_image_logic.dart';
import 'package:pina/conversion/video/video_to_image/video_to_image_params.dart';

class VideoToImageScreen extends StatelessWidget {
  final String userId;
  final String? userEmail;
  final double temperature;

  const VideoToImageScreen({
    super.key,
    this.userId = "0",
    this.userEmail,
    this.temperature = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final logic = VideoToImageLogic();
    final baseParams = VideoToImageParams(temperature: temperature);

    return ConversionChatScreen(
      title: "Video to Image",
      fromType: baseParams.from,
      toType: baseParams.to,
      userId: userId,
      userEmail: userEmail,
      initialTemperature: baseParams.temperature,
      getParametersConfig: () => VideoToImageParams.parametersConfig,
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
