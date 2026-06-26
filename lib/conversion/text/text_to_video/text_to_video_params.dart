class TextToVideoParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const TextToVideoParams({
    this.from = "Text",
    this.to = "Video",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Text to Video conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Video Style', 'key': 'videoStyle', 'type': 'dropdown', 
     'options': ['Cinematic', 'Animation'], 'default': 'Cinematic'},
    {'name': 'Duration', 'key': 'duration', 'type': 'dropdown', 
     'options': ['5s', '10s', '20s'], 'default': '10s'},
    {'name': 'Resolution', 'key': 'resolution', 'type': 'dropdown', 
     'options': ['720p', '1080p'], 'default': '1080p'},
    {'name': 'Aspect Ratio', 'key': 'aspectRatio', 'type': 'dropdown', 
     'options': ['16:9', '9:16'], 'default': '16:9'},
    {'name': 'Camera Motion', 'key': 'cameraMotion', 'type': 'dropdown', 
     'options': ['Static', 'Pan', 'Zoom'], 'default': 'Static'},
    {'name': 'Frame Rate', 'key': 'frameRate', 'type': 'dropdown', 
     'options': ['24fps', '30fps'], 'default': '30fps'},
  ];

  TextToVideoParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return TextToVideoParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
