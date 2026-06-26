import 'package:flutter/material.dart';

import '../models/widget_model.dart';

class WidgetConfig {
  final String key;
  final String title;
  final String category;
  final String type;
  final String screenType;
  final String action;
  final String apiEndpoint;
  final String inputType;
  final IconData icon;
  final Color accentColor;
  final String outputRenderer;
  final String outputTemplate;
  final String inputLabel;
  final String heading;
  final String description;
  final String outputTitle;
  final List<String> aliases;
  final Map<String, dynamic> payload;
  final Map<String, dynamic> studyConfig;
  final Map<String, dynamic> uiConfig;

  const WidgetConfig({
    required this.key,
    required this.title,
    required this.category,
    required this.type,
    required this.screenType,
    required this.action,
    required this.apiEndpoint,
    required this.inputType,
    required this.icon,
    required this.accentColor,
    required this.outputRenderer,
    required this.outputTemplate,
    required this.inputLabel,
    required this.heading,
    required this.description,
    required this.outputTitle,
    this.aliases = const [],
    this.payload = const {},
    this.studyConfig = const {},
    this.uiConfig = const {},
  });

  WidgetConfig copyWith({
    String? key,
    String? title,
    String? category,
    String? type,
    String? screenType,
    String? action,
    String? apiEndpoint,
    String? inputType,
    IconData? icon,
    Color? accentColor,
    String? outputRenderer,
    String? outputTemplate,
    String? inputLabel,
    String? heading,
    String? description,
    String? outputTitle,
    List<String>? aliases,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? studyConfig,
    Map<String, dynamic>? uiConfig,
  }) {
    return WidgetConfig(
      key: key ?? this.key,
      title: title ?? this.title,
      category: category ?? this.category,
      type: type ?? this.type,
      screenType: screenType ?? this.screenType,
      action: action ?? this.action,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      inputType: inputType ?? this.inputType,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      outputRenderer: outputRenderer ?? this.outputRenderer,
      outputTemplate: outputTemplate ?? this.outputTemplate,
      inputLabel: inputLabel ?? this.inputLabel,
      heading: heading ?? this.heading,
      description: description ?? this.description,
      outputTitle: outputTitle ?? this.outputTitle,
      aliases: aliases ?? this.aliases,
      payload: payload ?? this.payload,
      studyConfig: studyConfig ?? this.studyConfig,
      uiConfig: uiConfig ?? this.uiConfig,
    );
  }
}

const List<WidgetConfig> _widgetConfigs = [
  // 🔍 SEARCH
  WidgetConfig(
    key: 'google_search',
    title: 'Google Search',
    category: 'Search',
    type: 'tool',
    screenType: 'chat',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'file',
    icon: Icons.travel_explore_rounded,
    accentColor: Color(0xFF5F7CFF),
    outputRenderer: 'list',
    outputTemplate: 'search_results',
    inputLabel: 'Search query',
    heading: 'Google Search',
    description: 'Search the web and browse ranked results in one shared screen.',
    outputTitle: 'Results',
    aliases: ['google'],
    payload: {'type': 'google'},
  ),
  
  WidgetConfig(
    key: 'bing_search',
    title: 'Bing Search',
    category: 'Search',
    type: 'tool',
    screenType: 'chat',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'file',
    icon: Icons.public_rounded,
    accentColor: Color(0xFF00A6FB),
    outputRenderer: 'list',
    outputTemplate: 'search_results',
    inputLabel: 'Search query',
    heading: 'Bing Search',
    description: 'Run web searches with a dynamic results layout.',
    outputTitle: 'Results',
    aliases: ['bing'],
    payload: {'type': 'bing'},
  ),
  
  WidgetConfig(
    key: 'gpt_search',
    title: 'GPT Search',
    category: 'Search',
    type: 'tool',
    screenType: 'chat',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'file',
    icon: Icons.auto_awesome_rounded,
    accentColor: Color(0xFF4DD0E1),
    outputRenderer: 'text',
    outputTemplate: 'default',
    inputLabel: 'Ask anything',
    heading: 'GPT Search',
    description: 'Use AI to answer open-ended questions and summarize information.',
    outputTitle: 'Answer',
    aliases: ['text generator', 'gpt', 'ai search'],
    payload: {'type': 'gpt'},
  ),
  
  WidgetConfig(
    key: 'translator',
    title: 'Translator',
    category: 'Translate',
    type: 'tool',
    screenType: 'chat',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'text',
    icon: Icons.translate_rounded,
    accentColor: Color(0xFFFF7A59),
    outputRenderer: 'text',
    outputTemplate: 'translation',
    inputLabel: 'Text to translate',
    heading: 'Translator',
    description: 'Use the same chat workflow with translation-focused output.',
    outputTitle: 'Translation',
    payload: {'type': 'gpt', 'mode': 'translate'},
  ),
  ///SPANISH TRANSLATOR
    // 🌍 ENGLISH TO GERMAN TRANSLATOR
  WidgetConfig(
    key: 'englishtogermantranslator',
    title: 'English to German Translator',
    category: 'Translation',
    type: 'tool',
    screenType: 'chat',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'text',
    icon: Icons.translate_rounded,
    accentColor: Color(0xFF3F51B5),
    outputRenderer: 'text',
    outputTemplate: 'translation',
    inputLabel: 'Enter English text',
    heading: 'English to German Translator',
    description:
        'Translate English text into German instantly using AI.',
    outputTitle: 'German Translation',
    aliases: [
      'english german translator',
      'english to german',
      'german translator',
      'translate english to german',
    ],
    payload: {
      'type': 'gpt',
      'mode': 'translate',
      'sourceLanguage': 'English',
      'targetLanguage': 'German',
    },
  ),
  
  // 🎤 AUDIO TRANSCRIPTION
  WidgetConfig(
    key: 'audio_transcription',
    title: 'Audio Transcription',
    category: 'Audio',
    type: 'tool',
    screenType: 'upload',
    action: 'transcribe',
    apiEndpoint: '/myai/transcribe',
    inputType: 'file',
    icon: Icons.graphic_eq_rounded,
    accentColor: Color(0xFFFFB347),
    outputRenderer: 'text',
    outputTemplate: 'transcript',
    inputLabel: 'Pick an audio file',
    heading: 'Audio Transcription',
    description: 'Upload audio and receive a readable transcript.',
    outputTitle: 'Transcript',
    aliases: ['transcription', 'speech to text', 'audio to text'],
  ),
  
  // 📅 MEETING NOTES
  WidgetConfig(
    key: 'meeting_notes',
    title: 'Meeting Notes',
    category: 'Scheduler',
    type: 'tool',
    screenType: 'upload',
    action: 'scheduler',
    apiEndpoint: '/myai/scheduler',
    inputType: 'audio',
    icon: Icons.event_note_rounded,
    accentColor: Color(0xFF8B7CFF),
    outputRenderer: 'json',
    outputTemplate: 'scheduler_plan',
    inputLabel: 'Record or upload meeting audio',
    heading: 'Meeting Notes',
    description: 'Record meeting audio or upload audio file to generate structured notes and action items.',
    outputTitle: 'Meeting Plan',
    aliases: ['meeting scheduler', 'meeting summary', 'action items'],
  ),
  
  // ⚖️ LEGAL AI
  WidgetConfig(
    key: 'legal_ai',
    title: 'Legal AI',
    category: 'AI',
    type: 'tool',
    screenType: 'upload',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'audio',
    icon: Icons.gavel_rounded,
    accentColor: Color(0xFFF59E7A),
    outputRenderer: 'text',
    outputTemplate: 'legal_guidance',
    inputLabel: 'Record or upload legal audio',
    heading: 'Legal AI',
    description: 'Record legal audio or upload audio file for transcription and legal guidance.',
    outputTitle: 'Legal Guidance',
    payload: {'type': 'gpt', 'mode': 'legal'},
  ),
  
  // 🏥 MEDICAL AI (FIXED)
  WidgetConfig(
    key: 'medical_ai',
    title: 'Medical AI',
    category: 'AI',
    type: 'tool',
    screenType: 'upload',
    action: 'search',
    apiEndpoint: '/myai/search',
    inputType: 'audio',
    icon: Icons.health_and_safety_rounded,
    accentColor: Color(0xFF4ED4A8),
    outputRenderer: 'text',
    outputTemplate: 'medical_guidance',
    inputLabel: 'Record or upload medical audio',
    heading: 'Medical AI',
    description: 'Record medical audio or upload audio file for transcription and medical guidance.',
    outputTitle: 'Medical Guidance',
    aliases: ['healthcare', 'health care', 'healthcare medical ai', 'healthcare / medical ai'],
    payload: {'type': 'gpt', 'mode': 'medical'},
  ),
  
  WidgetConfig(
    key: 'deepfake_check',
    title: 'Deepfake Check',
    category: 'Safety',
    type: 'tool',
    screenType: 'upload',
    action: 'safety',
    apiEndpoint: '/deepfake/check',
    inputType: 'file',
    icon: Icons.verified_user_rounded,
    accentColor: Color(0xFFFF88B7),
    outputRenderer: 'json',
    outputTemplate: 'risk_report',
    inputLabel: 'Pick image or video',
    heading: 'Deepfake Check',
    description: 'Upload media to receive a structured authenticity report.',
    outputTitle: 'Analysis',
    aliases: ['safety ai', 'safety deepfake', 'deep fake check'],
  ),
  
  WidgetConfig(
    key: 'plagiarism_check',
    title: 'Plagiarism Check',
    category: 'Safety',
    type: 'tool',
    screenType: 'form',
    action: 'safety',
    apiEndpoint: '/plagiarism/scan',
    inputType: 'text',
    icon: Icons.fact_check_rounded,
    accentColor: Color(0xFFFCA5A5),
    outputRenderer: 'json',
    outputTemplate: 'plagiarism_report',
    inputLabel: 'Paste text to scan',
    heading: 'Plagiarism Check',
    description: 'Scan text and return a structured originality report.',
    outputTitle: 'Scan Report',
    aliases: ['plagiarism', 'ai plagiarism'],
    payload: {'type': 'plagiarism'},
  ),
];

List<WidgetConfig> getWidgetConfigs() => List<WidgetConfig>.unmodifiable(_widgetConfigs);

String _normalizeLookup(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

Map<String, dynamic> _readMap(Map<String, dynamic> source) {
  return source.isEmpty ? const {} : Map<String, dynamic>.from(source);
}

String _firstNonEmpty(List<String> values, String fallback) {
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return fallback;
}

WidgetConfig? getWidgetConfigByName(String name) {
  final normalized = _normalizeLookup(name);
  if (normalized.isEmpty) return null;

  for (final config in _widgetConfigs) {
    if (_normalizeLookup(config.title) == normalized ||
        config.aliases.any((alias) => _normalizeLookup(alias) == normalized)) {
      return config;
    }
  }
  return null;
}

WidgetConfig? getWidgetConfigByKey(String key) {
  final normalized = _normalizeLookup(key);
  if (normalized.isEmpty) return null;

  for (final config in _widgetConfigs) {
    if (_normalizeLookup(config.key) == normalized ||
        _normalizeLookup(config.title) == normalized ||
        config.aliases.any((alias) => _normalizeLookup(alias) == normalized)) {
      return config;
    }
  }
  return null;
}

String _normalizeWidgetType(String value) {
  return value.trim().toLowerCase() == 'study' ? 'study' : 'tool';
}

String _normalizeScreenType(String value, {String fallback = 'chat'}) {
  final normalized = value.trim().toLowerCase();
  const supported = {'chat', 'upload', 'study', 'list', 'form'};
  return supported.contains(normalized) ? normalized : fallback;
}

String? _readExplicitScreenType(String value) {
  final normalized = value.trim().toLowerCase();
  const supported = {'chat', 'upload', 'study', 'list', 'form'};
  return supported.contains(normalized) ? normalized : null;
}

// ✅ STEP 1: FORCE disable fallback
bool _isGenericBackendFallback(WidgetModel widget) {
  return false; // 🔥 FORCE disable fallback
}

String _resolveOutputTemplate(
  WidgetModel widget,
  String action,
  Map<String, dynamic> payload, {
  bool preferBase = false,
}) {
  final explicit = preferBase ? '' : widget.outputTemplate.trim().toLowerCase();
  if (explicit.isNotEmpty) {
    return explicit;
  }

  final payloadMode = (payload['mode'] ?? '').toString().trim().toLowerCase();
  final widgetName = widget.widgetName.trim().toLowerCase();
  final apiEndpoint = widget.apiEndpoint.trim().toLowerCase();

  if (widget.isStudy) return 'study_sections';
  if (action == 'transcribe') {
    if (payloadMode.contains('legal') || widgetName.contains('legal')) {
      return 'legal_deposition';
    }
    if (payloadMode.contains('medical') || widgetName.contains('medical')) {
      return 'medical_notes';
    }
    return 'transcript';
  }
  if (action == 'scheduler') return 'scheduler_plan';
  if (action == 'safety' && apiEndpoint.endsWith('/plagiarism/scan')) {
    return 'plagiarism_report';
  }
  if (action == 'safety') return 'risk_report';
  if (payloadMode == 'translate') return 'translation';
  if (payloadMode == 'legal') return 'legal_guidance';
  if (payloadMode == 'medical') return 'medical_guidance';
  if ((payload['type'] ?? '').toString().trim().toLowerCase() == 'google' ||
      (payload['type'] ?? '').toString().trim().toLowerCase() == 'bing') {
    return 'search_results';
  }
  return 'default';
}

String _resolveHeading(WidgetModel widget, WidgetConfig? base, String outputTemplate) {
  final explicitHeading = widget.heading.trim();
  const genericHeadings = {'ai workspace', 'myai widget', 'search', 'workspace'};
  if (base != null &&
      base.heading.trim().isNotEmpty &&
      (explicitHeading.isEmpty ||
          genericHeadings.contains(explicitHeading.toLowerCase()))) {
    return base.heading;
  }
  if (explicitHeading.isNotEmpty) return explicitHeading;
  switch (outputTemplate) {
    case 'legal_deposition':
      return 'Legal Deposition';
    case 'medical_notes':
      return 'Medical Notes';
    default:
      return _firstNonEmpty(
        [widget.widgetName, widget.visitName, base?.heading ?? ''],
        'MyAI Widget',
      );
  }
}

String _resolveDescription(
  WidgetModel widget,
  WidgetConfig? base,
  String screenType,
  String outputTemplate,
) {
  if (widget.description.trim().isNotEmpty) return widget.description.trim();
  if (base != null && base.description.trim().isNotEmpty) return base.description;
  if (widget.isStudy) {
    return 'Change board, class, subject, and chapter without leaving the screen.';
  }
  switch (outputTemplate) {
    case 'legal_deposition':
      return 'Upload audio and receive a structured deposition-style transcript.';
    case 'medical_notes':
      return 'Upload audio and convert it into structured medical notes.';
    case 'translation':
      return 'Enter text and get a clean translated response.';
    default:
      break;
  }
  switch (screenType) {
    case 'chat':
      return 'Use a shared chat screen with widget-specific prompts and output.';
    case 'upload':
      return 'Upload a file and review the processed output in the same layout.';
    case 'form':
      return 'Enter structured input and view a formatted result.';
    default:
      return 'A reusable MyAI workflow screen.';
  }
}

String _resolveOutputTitle(
  WidgetModel widget,
  WidgetConfig? base,
  String outputTemplate,
) {
  final explicitOutputTitle = widget.outputTitle.trim();
  const genericOutputTitles = {'response', 'answer'};
  if (base != null &&
      base.outputTitle.trim().isNotEmpty &&
      (explicitOutputTitle.isEmpty ||
          genericOutputTitles.contains(explicitOutputTitle.toLowerCase()))) {
    return base.outputTitle;
  }
  if (explicitOutputTitle.isNotEmpty) return explicitOutputTitle;
  if (base != null && base.outputTitle.trim().isNotEmpty) return base.outputTitle;
  switch (outputTemplate) {
    case 'search_results':
      return 'Results';
    case 'translation':
      return 'Translation';
    case 'transcript':
      return 'Transcript';
    case 'legal_deposition':
      return 'Structured Deposition';
    case 'medical_notes':
      return 'Medical Summary';
    case 'scheduler_plan':
      return 'Plan';
    case 'plagiarism_report':
    case 'risk_report':
      return 'Analysis';
    case 'legal_guidance':
      return 'Legal Guidance';
    case 'medical_guidance':
      return 'Medical Guidance';
    case 'study_sections':
      return 'Study Material';
    default:
      return 'Response';
  }
}

IconData _resolveIcon(
  WidgetModel widget,
  WidgetConfig? base,
  String outputTemplate,
  String screenType,
) {
  if (base != null) return base.icon;
  if (widget.isStudy || screenType == 'study') return Icons.school_rounded;
  switch (outputTemplate) {
    case 'search_results':
      return Icons.travel_explore_rounded;
    case 'translation':
      return Icons.translate_rounded;
    case 'legal_deposition':
    case 'legal_guidance':
      return Icons.gavel_rounded;
    case 'medical_notes':
    case 'medical_guidance':
      return Icons.health_and_safety_rounded;
    case 'scheduler_plan':
      return Icons.event_note_rounded;
    case 'plagiarism_report':
      return Icons.fact_check_rounded;
    case 'risk_report':
      return Icons.verified_user_rounded;
    default:
      break;
  }
  if (screenType == 'upload') return Icons.upload_file_rounded;
  return Icons.auto_awesome_rounded;
}

Color _resolveAccent(
  WidgetModel widget,
  WidgetConfig? base,
  String outputTemplate,
  String screenType,
) {
  if (base != null) return base.accentColor;
  if (widget.isStudy || screenType == 'study') return const Color(0xFF60A5FA);
  switch (outputTemplate) {
    case 'translation':
      return const Color(0xFFFF7A59);
    case 'legal_deposition':
    case 'legal_guidance':
      return const Color(0xFFF59E7A);
    case 'medical_notes':
    case 'medical_guidance':
      return const Color(0xFF4ED4A8);
    case 'scheduler_plan':
      return const Color(0xFF8B7CFF);
    case 'plagiarism_report':
      return const Color(0xFFFCA5A5);
    case 'risk_report':
      return const Color(0xFFFF88B7);
    default:
      break;
  }
  if (screenType == 'upload') return const Color(0xFFFFB347);
  return const Color(0xFF5F7CFF);
}

Map<String, dynamic> _resolveStudyConfig(WidgetModel widget, WidgetConfig? base) {
  if (!widget.isStudy && (base?.type ?? 'tool') != 'study') {
    return const {};
  }

  final merged = <String, dynamic>{
    ...?base?.studyConfig,
    ...widget.studyConfig,
  };

  merged.putIfAbsent('flow', () => ['board', 'class', 'subject', 'chapter']);
  merged.putIfAbsent('sections', () => ['summary', 'notes', 'mcq', 'test']);
  return merged;
}

// ✅ STEP 2: SMART TITLE (AUTO)
String _smartTitle(WidgetModel widget, WidgetConfig? base) {
  if (base != null && base.title.isNotEmpty) return base.title;

  final raw = widget.widgetName.isNotEmpty
      ? widget.widgetName
      : widget.visitName;

  return raw
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'\b\w'), (m) => m.group(0)!.toUpperCase());
}

// ✅ STEP 4: INPUT TYPE FIX
String _resolveInputType(WidgetModel widget, WidgetConfig? base, bool useBaseExecution) {
  if (!useBaseExecution &&
    widget.inputType.trim().isNotEmpty &&
    widget.inputType.trim() != 'text') {
  return widget.inputType.trim();
}
  return base?.inputType ?? 'text';
}

// 🔥 MOST IMPORTANT FIX - CORRECTED SCREEN TYPE LOGIC
WidgetConfig resolveWidgetConfigForWidget(WidgetModel widget) {
  final base = getWidgetConfigByKey(widget.widgetKey) ??
      getWidgetConfigByName(widget.widgetName) ??
      getWidgetConfigByName(widget.visitName);
  
  final useBaseExecution = _isGenericBackendFallback(widget);
  final payload = <String, dynamic>{
    ...?base?.payload,
    ...widget.payload,
  };
  
  final type = widget.type.trim().isNotEmpty
      ? _normalizeWidgetType(widget.type)
      : _normalizeWidgetType(base?.type ?? widget.visitCategory);
  
  final action = useBaseExecution || widget.action.trim().isEmpty
      ? (base?.action ?? 'search')
      : widget.action.trim();
  
  // ✅ STEP 4: Input type fix
  final inputType = _resolveInputType(widget, base, useBaseExecution);
  
  final outputRenderer = !useBaseExecution && widget.outputRenderer.trim().isNotEmpty
      ? widget.outputRenderer.trim()
      : (base?.outputRenderer ?? 'text');
  
  // ✅ STEP 3: SMART SCREEN TYPE (AUTO)
  final explicitScreenType = useBaseExecution
      ? null
      : _readExplicitScreenType(widget.screenType);
  
  final screenType = explicitScreenType ??
      (action == 'transcribe' || action == 'scheduler'
          ? 'upload'
          : action == 'search'
              ? 'chat'
              : widget.inputType == 'audio' || widget.inputType == 'file'
                  ? 'upload'
                  : 'chat');
  
  final outputTemplate = _resolveOutputTemplate(
    widget,
    action,
    payload,
    preferBase: useBaseExecution,
  );

  return WidgetConfig(
    key: base?.key ??
        (widget.widgetKey.trim().isEmpty
        ? (_normalizeLookup(widget.widgetName).isEmpty
            ? 'widget'
            : _normalizeLookup(widget.widgetName))
        : widget.widgetKey),
    
    // ✅ STEP 2: Smart title
    title: _smartTitle(widget, base),
    
    category: widget.visitCategory.trim().isEmpty
        ? (base?.category ?? 'Other')
        : widget.visitCategory.trim(),
    type: type,
    screenType: screenType,
    action: action,
    apiEndpoint: !useBaseExecution && widget.apiEndpoint.trim().isNotEmpty
        ? widget.apiEndpoint
        : (base?.apiEndpoint ?? '/myai/search'),
    inputType: inputType,
    icon: _resolveIcon(widget, base, outputTemplate, screenType),
    accentColor: _resolveAccent(widget, base, outputTemplate, screenType),
    outputRenderer: outputRenderer,
    outputTemplate: outputTemplate,
    inputLabel: !useBaseExecution && widget.inputLabel.trim().isNotEmpty
        ? widget.inputLabel
        : (base?.inputLabel ?? 'Ask anything'),
    heading: _resolveHeading(widget, base, outputTemplate),
    description: _resolveDescription(widget, base, screenType, outputTemplate),
    outputTitle: _resolveOutputTitle(widget, base, outputTemplate),
    payload: _readMap(payload),
    studyConfig: _resolveStudyConfig(widget, base),
    uiConfig: {
      ...?base?.uiConfig,
      ...widget.uiConfig,
    },
  );
}