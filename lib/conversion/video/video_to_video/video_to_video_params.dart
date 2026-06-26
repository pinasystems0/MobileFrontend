class VideoToVideoParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const VideoToVideoParams({
    this.from = "Video",
    this.to = "Video",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Video to Video conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {"name": "Resolution", "key": "resolution", "type": "dropdown", "options": ["1920x1080","1280x720","640x360"], "default": "1280x720"},
{"name": "FPS", "key": "fps", "type": "slider", "min": 15.0, "max": 60.0, "default": 30.0},
    {"name": "Speed", "key": "speed", "type": "slider", "min": 0.5, "max": 2.0, "default": 1.0},
{"name": "Brightness", "key": "brightness", "type": "slider", "min": -1.0, "max": 1.0, "default": 0.0},
    {"name": "Contrast", "key": "contrast", "type": "slider", "min": 0.5, "max": 2.0, "default": 1.0},
{"name": "Blur", "key": "blur", "type": "slider", "min": 0.0, "max": 10.0, "default": 0.0},
{"name": "Fade In (sec)", "key": "fadeIn", "type": "slider", "min": 0.0, "max": 5.0, "default": 0.0},
{"name": "Fade Out (sec)", "key": "fadeOut", "type": "slider", "min": 0.0, "max": 5.0, "default": 0.0},
{"name": "Trim Start (sec)", "key": "trimStart", "type": "slider", "min": 0.0, "max": 60.0, "default": 0.0},
{"name": "Trim End (sec)", "key": "trimEnd", "type": "slider", "min": 0.0, "max": 60.0, "default": 0.0},
    {"name": "Format", "key": "format", "type": "dropdown", "options": ["mp4","webm"], "default": "mp4"}
  ];

  VideoToVideoParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return VideoToVideoParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}

