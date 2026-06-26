class VideoToImageParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const VideoToImageParams({
    this.from = "Video",
    this.to = "Image",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Video to Image conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Frame Selection', 'key': 'frameSelection', 'type': 'dropdown', 
     'options': ['First Frame', 'Key Frames', 'Scene Frames'], 'default': 'Key Frames'},
    {'name': 'Resolution', 'key': 'resolution', 'type': 'dropdown', 
     'options': ['512', '1024', '2048'], 'default': '1024'},
    {'name': 'Aspect Ratio', 'key': 'aspectRatio', 'type': 'dropdown', 
     'options': ['1:1', '16:9', '9:16'], 'default': '16:9'},
    {'name': 'Art Style', 'key': 'artStyle', 'type': 'dropdown', 
     'options': ['Realistic', 'Anime', 'Cyberpunk'], 'default': 'Realistic'},
    {'name': 'Detail Level', 'key': 'detailLevel', 'type': 'dropdown', 
     'options': ['Low', 'Medium', 'High'], 'default': 'Medium'},
    {'name': 'Color Theme', 'key': 'colorTheme', 'type': 'dropdown', 
     'options': ['Vibrant', 'Dark', 'Pastel'], 'default': 'Vibrant'},
  ];

  VideoToImageParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return VideoToImageParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
