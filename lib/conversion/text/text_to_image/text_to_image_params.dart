class TextToImageParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const TextToImageParams({
    this.from = "Text",
    this.to = "Image",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Text to Image conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Art Style', 'key': 'artStyle', 'type': 'dropdown', 
     'options': ['Realistic', 'Anime', 'Cyberpunk'], 'default': 'Realistic'},
    {'name': 'Aspect Ratio', 'key': 'aspectRatio', 'type': 'dropdown', 
     'options': ['1:1', '16:9', '9:16'], 'default': '1:1'},
    {'name': 'Resolution', 'key': 'resolution', 'type': 'dropdown', 
     'options': ['512', '1024', '2048'], 'default': '1024'},
    {'name': 'Lighting', 'key': 'lighting', 'type': 'dropdown', 
     'options': ['Natural', 'Neon', 'Cinematic'], 'default': 'Natural'},
    {'name': 'Camera Angle', 'key': 'cameraAngle', 'type': 'dropdown', 
     'options': ['Wide', 'Close-up'], 'default': 'Wide'},
    {'name': 'Detail Level', 'key': 'detailLevel', 'type': 'dropdown', 
     'options': ['Low', 'Medium', 'High'], 'default': 'Medium'},
  ];

  TextToImageParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return TextToImageParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
