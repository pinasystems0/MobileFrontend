import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/registration_done.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class ProfessionalAIScreen extends StatefulWidget {
  const ProfessionalAIScreen({super.key});

  @override
  State<ProfessionalAIScreen> createState() => _ProfessionalAIScreenState();
}

class _ProfessionalAIScreenState extends State<ProfessionalAIScreen> {

  bool isLoading = false;

  List<String> selectedTools = [];

  final List<String> aiTools = [
    "ChatGPT",
    "Gemini",
    "Claude",
    "Copilot",
    "Perplexity",
    "Midjourney",
  ];

  // ================= API =================

  Future<void> submitAI() async {

    if (selectedTools.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one AI tool"),
        ),
      );

      return;
    }

    setState(() => isLoading = true);

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      final response = await http.post(

        Uri.parse("${ApiConstants.authUrl}/api/professional/ai-preferences"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },

        body: jsonEncode({
          "aiTools": selectedTools,
        }),

      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const RegistrationDone(),
          ),
          (route) => false,
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.body)),
        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) setState(() => isLoading = false);

    }

  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: TemplateTheme.textPrimary,
              ),
              title: const Text(
                "AI Preferences",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              actions: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      "Step 4 / 4",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegistrationDone(),
                      ),
                      (_) => false,
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 14),

                    const Text(
                      "Which AI tools do you use?",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Expanded(
                      child: ListView(
                        children: aiTools.map((tool) {
                          return CheckboxListTile(
                            title: Text(
                              tool,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: TemplateTheme.textPrimary,
                              ),
                            ),
                            value: selectedTools.contains(tool),
                            activeColor: TemplateTheme.primary,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedTools.add(tool);
                                } else {
                                  selectedTools.remove(tool);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitAI,
                          style: TemplateTheme.primaryButtonStyle(),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Finish Registration",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
