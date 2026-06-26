import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pina/screens/constants.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class ImpactAnalysisScreen extends StatefulWidget {
  final String articleUrl;
  final String title;
  final String description;

  const ImpactAnalysisScreen({
    super.key,
    required this.articleUrl,
    required this.description,
    required this.title,
  });

  @override
  State<ImpactAnalysisScreen> createState() => _ImpactAnalysisScreenState();
}

class _ImpactAnalysisScreenState extends State<ImpactAnalysisScreen> {
  String? _analysisText;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFullAnalysis();
  }

  Future<void> _fetchFullAnalysis() async {
    try {
      // Route through backend to keep API keys secure
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/news/ai/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "prompt": "Analyze this news event:\n"
                  "HEADLINE: ${widget.title}\n"
                  "DETAILS: ${widget.description}\n\n"
                  "TASK: Provide a comprehensive, detailed impact analysis on all stakeholders involved.\n"
                  "FORMAT: Plain text, clearly structured paragraphs.\n"
                  "Avoid using markdown symbols like ** or ## if possible, just clear text.",
          
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          String content = data['choices'][0]['message']['content'];

          if (mounted) {
            setState(() {
              _analysisText = content.trim();
              _isLoading = false;
            });
          }
        } else {
          throw Exception("Empty response from AI");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              "Could not generate full analysis. Please check your connection.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateLayout(
       brandTitle: "Arthum AI",
        brandSubtitle: "Latest news, AI summaries, and quick actions in one place.",
        sectionTitle: "Impact Analysis",
        sectionSubtitle: "Deep-dive assessment generated from the article",
        child: Padding(
          padding: EdgeInsets.only(
            left: 4,
            right: 4,
            top: 4,
            bottom: MediaQuery.of(context).padding.bottom + 8,
          ),
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        "Consulting AI Expert...",
                        style: TextStyle(color: TemplateTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _fetchFullAnalysis();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: TemplateTheme.glassPanel(
                      color: Colors.white,
                      opacity: 0.84,
                      radius: 24,
                    ),
                    child: Text(
                      _analysisText!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
        ),
        ),
    );
  }
}
