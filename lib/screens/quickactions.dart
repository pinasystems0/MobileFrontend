import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pina/screens/constants.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class QuickActionScreen extends StatefulWidget {
  final String articleUrl;
  final String title;
  final String description;

  const QuickActionScreen({
    super.key,
    required this.articleUrl,
    required this.title,
    required this.description,
  });

  @override
  State<QuickActionScreen> createState() => _QuickActionScreenState();
}

class _QuickActionScreenState extends State<QuickActionScreen> {
  String? _actionText;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFullActions();
  }

  Future<void> _fetchFullActions() async {
    try {
      // Route through backend to keep API keys secure
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/news/ai/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "prompt": "Analyze this news event:\n"
                  "HEADLINE: ${widget.title}\n"
                  "DETAILS: ${widget.description}\n\n"
                  "TASK: Create a comprehensive 'Action Plan' based on this news.\n"
                  "OUTPUT FORMAT:\n"
                  "1. Immediate Actions (Do this now)\n"
                  "2. Long-term Strategy (Plan for later)\n"
                  "3. Key Risks to Watch\n\n"
                  "Use bullet points and clear, professional language.",
          
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && (data['choices'] as List).isNotEmpty) {
          String content = data['choices'][0]['message']['content'];
          if (content.trim().isEmpty || content == "Okay") {
  throw Exception("Invalid AI response");
}
          if (mounted) {
            setState(() {
              _actionText = content.trim();
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
              "Could not generate action plan. Please check your connection.";
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
        sectionTitle: "Action Plan",
        sectionSubtitle: "Practical next steps generated from the article",
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
                      const CircularProgressIndicator(
                        color: TemplateTheme.accent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Consulting Strategist AI...",
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
                          _fetchFullActions();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemplateTheme.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
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
                      _actionText!,
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
