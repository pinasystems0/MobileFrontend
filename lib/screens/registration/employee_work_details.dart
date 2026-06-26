import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'registration_done.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class EmployeeWorkDetailsScreen extends StatefulWidget {
  const EmployeeWorkDetailsScreen({super.key});

  @override
  State<EmployeeWorkDetailsScreen> createState() =>
      _EmployeeWorkDetailsScreenState();
}

class _EmployeeWorkDetailsScreenState extends State<EmployeeWorkDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dailyTasksController =
      TextEditingController();
  final TextEditingController helpDescriptionController =
      TextEditingController();
  final TextEditingController otherAiToolController =
      TextEditingController();

  bool usesGenerativeAI = false;
  List<String> selectedAiTools = [];
  bool isLoading = false;

  final List<String> aiToolsList = [
    'ChatGPT',
    'Gemini',
    'Claude',
    'Other',
  ];

  @override
  void dispose() {
    dailyTasksController.dispose();
    helpDescriptionController.dispose();
    otherAiToolController.dispose();
    super.dispose();
  }

  // ================= API CALL =================

  Future<void> submitWorkDetails() async {
    if (!_formKey.currentState!.validate()) return;

    if (usesGenerativeAI && selectedAiTools.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one AI tool'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      if (token == null) {
        throw Exception('Authentication token missing');
      }

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.authUrl}/api/employee/work-details',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'dayToDayTasks': dailyTasksController.text.trim(),
          'useGenerativeAI': usesGenerativeAI,
          'aiTools': selectedAiTools,
          'otherAiTool': selectedAiTools.contains('Other')
              ? otherAiToolController.text.trim()
              : null,
          'howCanWeHelp': helpDescriptionController.text.trim(),
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
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= UI HELPERS =================

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: TemplateTheme.textPrimary,
        ),
      ),
    );
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
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
                "Work Details",
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
                      "Step 2 / 2",
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
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ===== DAILY TASKS =====
                  sectionTitle('Your Day-to-Day Tasks'),

                  sectionCard(
                    child: TextFormField(
                      controller: dailyTasksController,
                      maxLines: 5,
                      maxLength: 1000,
                      decoration: TemplateTheme.inputDecoration(
                        label: "",
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: 'Briefly describe what you do on a daily basis',
                        border: InputBorder.none,
                        counterText: '${dailyTasksController.text.length}/1000',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: TemplateTheme.textPrimary,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ===== AI USAGE =====
                  sectionTitle('Use of Generative AI'),

                  sectionCard(
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TemplateTheme.textPrimary,
                            ),
                          ),
                          value: true,
                          groupValue: usesGenerativeAI,
                          activeColor: TemplateTheme.primary,
                          onChanged: (v) =>
                              setState(() => usesGenerativeAI = true),
                        ),
                        RadioListTile<bool>(
                          title: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TemplateTheme.textPrimary,
                            ),
                          ),
                          value: false,
                          groupValue: usesGenerativeAI,
                          activeColor: TemplateTheme.primary,
                          onChanged: (v) => setState(() {
                            usesGenerativeAI = false;
                            selectedAiTools.clear();
                            otherAiToolController.clear();
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== AI TOOLS =====
                  if (usesGenerativeAI) ...[
                    sectionTitle('AI Tools You Use'),

                    sectionCard(
                      child: Column(
                        children: [
                          ...aiToolsList.map(
                            (tool) => CheckboxListTile(
                              title: Text(
                                tool,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TemplateTheme.textPrimary,
                                ),
                              ),
                              value: selectedAiTools.contains(tool),
                              activeColor: TemplateTheme.primary,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedAiTools.add(tool);
                                  } else {
                                    selectedAiTools.remove(tool);
                                    if (tool == 'Other') {
                                      otherAiToolController.clear();
                                    }
                                  }
                                });
                              },
                            ),
                          ),

                          if (selectedAiTools.contains('Other'))
                            const SizedBox(height: 8),
                          if (selectedAiTools.contains('Other'))
                            TextFormField(
                              controller: otherAiToolController,
                              decoration: TemplateTheme.inputDecoration(
                                label: 'Specify Other AI Tool',
                              ).copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: TemplateTheme.textPrimary,
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ===== HELP =====
                  sectionTitle('How Can We Help You?'),

                  sectionCard(
                    child: TextFormField(
                      controller: helpDescriptionController,
                      maxLines: 5,
                      maxLength: 1000,
                      decoration: TemplateTheme.inputDecoration(
                        label: "",
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: 'Tell us how we can support you better',
                        border: InputBorder.none,
                        counterText: '${helpDescriptionController.text.length}/1000',
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: TemplateTheme.textPrimary,
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== SUBMIT =====
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitWorkDetails,
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
                              'Finish Registration',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
