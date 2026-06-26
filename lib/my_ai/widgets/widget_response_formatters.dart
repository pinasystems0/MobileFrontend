import 'dart:convert';

import '../config/widget_configs.dart';

Map<String, dynamic> extractWidgetData(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return response;
}

String extractReadableWidgetOutput(Map<String, dynamic> response) {
  final payload = extractWidgetData(response);

  if (payload['transcript'] != null) {
    return payload['transcript'].toString();
  }
  if (payload['answer'] != null) {
    return payload['answer'].toString();
  }
  if (payload['text'] != null) {
    return payload['text'].toString();
  }
  if (payload['translation'] != null) {
    return payload['translation'].toString();
  }
  
  // 🔥 FIX 1: Meeting Notes - Only send createdJob data, not full JSON
  if (payload['createdJob'] != null) {
    return jsonEncode(payload['createdJob']);
  }

  if (payload['results'] is List) {
    final results = (payload['results'] as List)
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final title = map['title']?.toString() ?? '';
          final snippet = map['snippet']?.toString() ?? '';
          final url = map['url']?.toString() ?? '';
          
          // 🧠 OPTIONAL: Add emojis for cleaner UX
          return '🔎 $title\n$snippet\n$url';
        })
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);

    if (results.isNotEmpty) {
      return results.join('\n\n');
    }
  }

  // 🔥 FIX 2: Safe JSON encoding with fallback
  try {
    return const JsonEncoder.withIndent('  ').convert(payload);
  } catch (_) {
    return payload.toString();
  }
}

String formatWidgetOutput(String output, WidgetConfig config) {
  if (output.trim().isEmpty) return output;

  switch (config.outputTemplate) {
    case 'legal_deposition':
      return _formatWithSections(
        output,
        introTitle: '⚖️ Matter Overview',
        middleTitle: '📝 Deposition Transcript',
        closingTitle: '✅ Review Checklist',
        closingBullets: const [
          'Verify speaker names, dates, and referenced exhibits.',
          'Confirm any oath, objection, or testimony markers before final use.',
        ],
      );
    case 'medical_notes':
      return _formatWithSections(
        output,
        introTitle: '🏥 Clinical Snapshot',
        middleTitle: '📋 Detailed Notes',
        closingTitle: '🩺 Follow-Up',
        closingBullets: const [
          'Review medications, symptoms, and next actions with a clinician.',
          'Validate dosage, timeline, and patient identifiers before filing.',
        ],
      );
    case 'scheduler_plan':
      return _formatSchedulerPlan(output);
    default:
      return output;
  }
}

String _formatWithSections(
  String text, {
  required String introTitle,
  required String middleTitle,
  required String closingTitle,
  required List<String> closingBullets,
}) {
  final paragraphs = text
      .split(RegExp(r'\n\s*\n'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  final summary = paragraphs.isNotEmpty ? paragraphs.first : text.trim();
  final detailedBody = paragraphs.length > 1
      ? paragraphs.skip(1).join('\n\n')
      : text.trim();

  return [
    introTitle,
    summary,
    '',
    middleTitle,
    detailedBody,
    '',
    closingTitle,
    ...closingBullets.map((item) => '- $item'),
  ].join('\n');
}

String _formatSchedulerPlan(String output) {
  try {
    final data = jsonDecode(output);
    
    // Extract job data (since we now only send createdJob)
    final jobData = data is Map && data.containsKey('createdJob') 
        ? data['createdJob'] 
        : data;

    return '''
📅 Meeting Scheduled

Title: ${jobData['title'] ?? 'Untitled Meeting'}
Status: ${jobData['status'] ?? 'Scheduled'}

📝 Meeting Details:
${jobData['prompt'] ?? 'No additional details provided.'}
''';
  } catch (_) {
    return output;
  }
}