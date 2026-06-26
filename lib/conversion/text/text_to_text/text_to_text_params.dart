class TextToTextParams {
  final String from;
  final String to;
  final double temperature;
  final String? provider;

  const TextToTextParams({
    this.from = "Text",
    this.to = "Text",
    this.temperature = 0.7,
    this.provider,
  });

  /// Parameter configuration for Text to Text conversion
  static List<Map<String, dynamic>> get parametersConfig => [
    {'name': 'Tone', 'key': 'tone', 'type': 'dropdown', 
     'options': ['Formal', 'Casual', 'Professional'], 'default': 'Professional'},
    {'name': 'Writing Style', 'key': 'writingStyle', 'type': 'dropdown', 
     'options': ['Narrative', 'Expository', 'Persuasive', 'Descriptive'], 'default': 'Expository'},
    {'name': 'Response Length', 'key': 'length', 'type': 'dropdown', 
     'options': ['Short', 'Medium', 'Long'], 'default': 'Medium'},
    {'name': 'Language', 'key': 'language', 'type': 'dropdown', 
     'options': ['English', 'Hindi'], 'default': 'English'},
    {'name': 'Case', 'key': 'case', 'type': 'dropdown', 
     'options': ['Normal', 'Uppercase', 'Lowercase'], 'default': 'Normal'},
    {'name': 'Temperature', 'key': 'temperature', 'type': 'slider', 
     'min': 0.0, 'max': 1.0, 'default': 0.7},
    {'name': 'Max Tokens', 'key': 'maxTokens', 'type': 'number', 
     'min': 100, 'max': 4000, 'default': 1000},
  ];

  TextToTextParams copyWith({
    String? from,
    String? to,
    double? temperature,
    String? provider,
  }) {
    return TextToTextParams(
      from: from ?? this.from,
      to: to ?? this.to,
      temperature: temperature ?? this.temperature,
      provider: provider ?? this.provider,
    );
  }
}
