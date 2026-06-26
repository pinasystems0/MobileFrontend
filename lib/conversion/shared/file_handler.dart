import 'dart:io';

import 'package:file_picker/file_picker.dart';

class FileHandler {
  static Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return null;

      return File(path);
    } catch (_) {
      return null;
    }
  }

  static Future<File?> pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        withData: true,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
      );

      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return null;

      return File(path);
    } catch (_) {
      return null;
    }
  }

  static Future<File?> pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        withData: true,
        allowedExtensions: [
          'mp3',
          'wav',
          'm4a',
          'aac',
          'flac',
          'ogg',
          'mp4',
          'mov',
          'mkv',
          'avi',
          'webm',
        ],
      );

      final path = result?.files.single.path;
      if (path == null || path.isEmpty) return null;

      return File(path);
    } catch (_) {
      return null;
    }
  }
}
