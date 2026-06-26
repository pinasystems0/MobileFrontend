import 'package:flutter/widgets.dart';
import 'package:pina/conversion/audio/audio_to_audio/audio_to_audio_screen.dart';
import 'package:pina/conversion/audio/audio_to_image/audio_to_image_screen.dart';
import 'package:pina/conversion/audio/audio_to_text/audio_to_text_screen.dart';
import 'package:pina/conversion/audio/audio_to_video/audio_to_video_screen.dart';
import 'package:pina/conversion/image/image_to_audio/image_to_audio_screen.dart';
import 'package:pina/conversion/image/image_to_image/image_to_image_screen.dart';
import 'package:pina/conversion/image/image_to_text/image_to_text_screen.dart';
import 'package:pina/conversion/image/image_to_video/image_to_video_screen.dart';
import 'package:pina/conversion/text/text_to_audio/text_to_audio_screen.dart';
import 'package:pina/conversion/text/text_to_image/text_to_image_screen.dart';
import 'package:pina/conversion/text/text_to_text/text_to_text_screen.dart';
import 'package:pina/conversion/text/text_to_video/text_to_video_screen.dart';
import 'package:pina/conversion/video/video_to_audio/video_to_audio_screen.dart';
import 'package:pina/conversion/video/video_to_image/video_to_image_screen.dart';
import 'package:pina/conversion/video/video_to_text/video_to_text_screen.dart';
import 'package:pina/conversion/video/video_to_video/video_to_video_screen.dart';

Widget? buildConversionScreen({
  required String optionTitle,
  required String userId,
  String? userEmail,
}) {
  switch (optionTitle) {
    case "Text to Text":
      return TextToTextScreen(userId: userId, userEmail: userEmail);
    case "Text to Image":
      return TextToImageScreen(userId: userId, userEmail: userEmail);
    case "Text to Audio":
      return TextToAudioScreen(userId: userId, userEmail: userEmail);
    case "Text to Video":
      return TextToVideoScreen(userId: userId, userEmail: userEmail);
    case "Image to Text":
      return ImageToTextScreen(userId: userId, userEmail: userEmail);
    case "Image to Image":
      return ImageToImageScreen(userId: userId, userEmail: userEmail);
    case "Image to Audio":
      return ImageToAudioScreen(userId: userId, userEmail: userEmail);
    case "Image to Video":
      return ImageToVideoScreen(userId: userId, userEmail: userEmail);
    case "Audio to Text":
      return AudioToTextScreen(userId: userId, userEmail: userEmail);
    case "Audio to Image":
      return AudioToImageScreen(userId: userId, userEmail: userEmail);
    case "Audio to Audio":
      return AudioToAudioScreen(userId: userId, userEmail: userEmail);
    case "Audio to Video":
      return AudioToVideoScreen(userId: userId, userEmail: userEmail);
    case "Video to Text":
      return VideoToTextScreen(userId: userId, userEmail: userEmail);
    case "Video to Image":
      return VideoToImageScreen(userId: userId, userEmail: userEmail);
    case "Video to Audio":
      return VideoToAudioScreen(userId: userId, userEmail: userEmail);
    case "Video to Video":
      return VideoToVideoScreen(userId: userId, userEmail: userEmail);
    default:
      return null;
  }
}
