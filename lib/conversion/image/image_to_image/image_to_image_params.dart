class ImageToImageParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const ImageToImageParams({
    this.from = "Image",
    this.to = "Image",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Image to Image conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Edit Strength', 'key': 'editStrength', 'type': 'slider', 
     'min': 0.0, 'max': 1.0, 'default': 0.5},
    {'name': 'Art Style', 'key': 'artStyle', 'type': 'dropdown', 
     'options': ['Realistic', 'Anime', 'Cyberpunk'], 'default': 'Realistic'},
    {'name': 'Resolution', 'key': 'resolution', 'type': 'dropdown', 
     'options': ['512', '1024', '2048'], 'default': '1024'},
    {'name': 'Aspect Ratio', 'key': 'aspectRatio', 'type': 'dropdown', 
     'options': ['1:1', '16:9', '9:16'], 'default': '1:1'},
    {'name': 'Lighting', 'key': 'lighting', 'type': 'dropdown', 
     'options': ['Natural', 'Cinematic', 'Neon'], 'default': 'Natural'},
    {'name': 'Upscale', 'key': 'upscale', 'type': 'toggle', 
     'options': ['Off', 'On'], 'default': 'Off'},
    {'name': 'Detail Level', 'key': 'detailLevel', 'type': 'dropdown', 
     'options': ['Low', 'Medium', 'High'], 'default': 'Medium'},
  ];

  ImageToImageParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return ImageToImageParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
