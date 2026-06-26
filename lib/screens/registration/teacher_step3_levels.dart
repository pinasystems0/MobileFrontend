import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/teacher_step4_subjects.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class TeacherStep3Levels extends StatefulWidget {
  const TeacherStep3Levels({super.key});

  @override
  State<TeacherStep3Levels> createState() => _TeacherStep3LevelsState();
}

class _TeacherStep3LevelsState extends State<TeacherStep3Levels> {
  bool isLoading = false;

  /* ================= Education Levels ================= */
  final Map<String, bool> levels = {
    "KG": false,
    "Primary": false,
    "Secondary": false,
    "Higher Secondary": false,
    "Under Graduation": false,
    "Post Graduation": false,
    "Others": false,
  };

  final TextEditingController otherLevelController = TextEditingController();

  /* ================= Classes Mapping ================= */
  final Map<String, List<String>> classOptions = {
    "KG": ["Nursery", "Jr KG", "Sr KG"],
    "Primary": ["Std 1", "Std 2", "Std 3", "Std 4", "Std 5"],
    "Secondary": ["Std 6", "Std 7", "Std 8", "Std 9", "Std 10"],
    "Higher Secondary": ["Std 11", "Std 12"],
    "Under Graduation": ["FY", "SY", "TY"],
    "Post Graduation": ["PG Year 1", "PG Year 2"],
  };

  final Map<String, List<String>> selectedClasses = {};

  /* ================= Helpers ================= */
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validate() {
    if (!levels.containsValue(true)) {
      _snack("Select at least one education level");
      return false;
    }

    for (final entry in levels.entries) {
      if (entry.value && classOptions.containsKey(entry.key)) {
        if (selectedClasses[entry.key] == null ||
            selectedClasses[entry.key]!.isEmpty) {
          _snack("Select classes for ${entry.key}");
          return false;
        }
      }
    }

    if (levels["Others"] == true &&
        otherLevelController.text.trim().isEmpty) {
      _snack("Please specify other education level");
      return false;
    }

    return true;
  }

  /* ================= Save & Next ================= */
  Future<void> _saveAndNext() async {
    if (!_validate()) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();
      final email = prefs.getString("userEmail"); 

      print('🔍 Debug Info:');
      print('  Email from SharedPrefs: $email');
      print('  Token exists: ${token != null}');

      if (token == null || email == null) {
        _snack("Session expired. Please login again.");
        return;
      }

      // 🔑 Backend expects FLAT classes array
      final List<String> allClasses = [];
      selectedClasses.values.forEach(allClasses.addAll);

      final payload = {
        "email": email, 
        "educationLevels": levels.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        "classes": allClasses,
        "otherLevelDetail": levels["Others"] == true 
            ? otherLevelController.text.trim() 
            : "", 
      };

      print('📤 Sending to: ${ApiConstants.authUrl}/api/teacher/step3/levels');
      print('📦 Payload: ${jsonEncode(payload)}');

      final res = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/teacher/step3/levels"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      print('🟢 Response Status: ${res.statusCode}');
      print('📥 Response Body: ${res.body}');

      if (res.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherStep4Subjects(),
          ),
        );
      } else {
        final data = jsonDecode(res.body);
        _snack(data["message"] ?? "Failed to save data");
      }
    } catch (e) {
      print('❌ Error: $e');
      _snack("Server error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /* ================= Skip Function ================= */
  Future<void> _skipToNextStep() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();
      final email = prefs.getString("userEmail"); 

      if (token == null || email == null) {
        _snack("Session expired. Please login again.");
        return;
      }

      final payload = {
        "email": email, 
      };

      print('📤 Sending skip request with email: $email');

      final res = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/teacher/step3/skip"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherStep4Subjects(),
          ),
        );
      } else {
        print('❌ Skip failed with status: ${res.statusCode}');
        _snack("Skip failed");
      }
    } catch (e) {
      print('❌ Skip error: $e');
      _snack("Error skipping");
    }
  }

  /* ================= UI ================= */
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
                "Teaching Levels",
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
                      "Step 3 / 4",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _skipToNextStep,
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Education Level You Teach",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),
                      ...levels.keys.map(_levelCheckbox),

                      if (levels["Others"] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: TextField(
                            controller: otherLevelController,
                            decoration: TemplateTheme.inputDecoration(
                              label: "Specify Other Level",
                            ).copyWith(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),

                      const Text(
                        "Classes / Standards",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...levels.entries.where((e) => e.value).map((entry) {
                        final level = entry.key;
                        if (!classOptions.containsKey(level)) {
                          return const SizedBox();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 6),
                              child: Text(
                                level,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: TemplateTheme.textPrimary,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: classOptions[level]!.map((cls) {
                                final selected =
                                    selectedClasses[level]?.contains(cls) ??
                                        false;
                                return FilterChip(
                                  label: Text(cls),
                                  selected: selected,
                                  selectedColor: TemplateTheme.primary,
                                  backgroundColor: Colors.white.withOpacity(0.8),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : TemplateTheme.textPrimary,
                                  ),
                                  onSelected: (v) {
                                    setState(() {
                                      selectedClasses.putIfAbsent(
                                          level, () => []);
                                      v
                                          ? selectedClasses[level]!.add(cls)
                                          : selectedClasses[level]!.remove(cls);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveAndNext,
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
                                  "Next",
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

                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ================= Widgets ================= */
  Widget _levelCheckbox(String level) {
    return CheckboxListTile(
      title: Text(
        level,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TemplateTheme.textPrimary,
        ),
      ),
      value: levels[level],
      activeColor: TemplateTheme.primary,
      onChanged: (v) {
        setState(() {
          levels[level] = v!;
          if (!v) selectedClasses.remove(level);
        });
      },
    );
  }
}
