import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/registration/teacher_step3_levels.dart';

class TeacherStep2Profile extends StatefulWidget {
  final String email;

  const TeacherStep2Profile({
    super.key,
    required this.email,
  });

  @override
  State<TeacherStep2Profile> createState() => _TeacherStep2ProfileState();
}

class _TeacherStep2ProfileState extends State<TeacherStep2Profile> {
  bool isLoading = false;

  /* ================= Teacher Types ================= */
  final Map<String, bool> teacherTypes = {
    "School Teacher": false,
    "College Teacher": false,
    "Coaching Class Teacher": false,
    "Private Tutor": false,
  };

  /* ================= Teaching Mode ================= */
  final Map<String, bool> teachingModes = {
    "Online": false,
    "Offline": false,
    "Both": false,
  };

  /* ================= Languages ================= */
  final List<String> allLanguages = [
    "English",
    "Hindi",
    "Marathi",
    "Gujarati",
    "Tamil",
    "Telugu",
    "Kannada",
    "Malayalam",
    "Bengali",
    "Punjabi",
    "Odia",
    "Urdu",
  ];
  final List<String> selectedLanguages = [];

  /* ================= Location ================= */
  final List<String> indianStates = [
    "Andhra Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Delhi",
    "Gujarat",
    "Haryana",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Tamil Nadu",
    "Telugu",
    "Telangana",
    "Uttar Pradesh",
    "West Bengal",
  ];

  String? selectedState;
  final TextEditingController cityController = TextEditingController();

  /* ================= Institutions ================= */
  final List<TextEditingController> institutions = [
    TextEditingController(),
  ];

  /* ================= Boards ================= */
  final Map<String, bool> boards = {
    "CBSE": false,
    "ICSE": false,
    "ISC": false,
    "State Board": false,
  };

  String? selectedStateBoard;

  /* ================= Helpers ================= */
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validate() {
    if (!teacherTypes.containsValue(true)) {
      _snack("Select at least one type of teacher");
      return false;
    }

    if (!teachingModes.containsValue(true)) {
      _snack("Select mode of teaching");
      return false;
    }

    if (selectedLanguages.isEmpty) {
      _snack("Select at least one language");
      return false;
    }

    if (selectedState == null) {
      _snack("Select your state");
      return false;
    }

    if (boards["State Board"] == true && selectedStateBoard == null) {
      _snack("Select state board");
      return false;
    }

    for (final c in institutions) {
      if (c.text.isNotEmpty && c.text.length < 2) {
        _snack("Institution name must be at least 2 characters");
        return false;
      }
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
      print('  Widget Email: ${widget.email}');
      print('  Stored Email: $email');
      print('  Token exists: ${token != null}');

      if (token == null || token.isEmpty) {
        _snack("Session expired. Please login again.");
        setState(() => isLoading = false);
        return;
      }

      if (email == null || email.isEmpty) {
        _snack("Email not found. Please login again.");
        setState(() => isLoading = false);
        return;
      }

      final payload = {
        "email": email, 
        "teacherTypes": teacherTypes.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        "teachingMode": teachingModes.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        "languages": selectedLanguages,
        "location": {
          "state": selectedState,
          "city": cityController.text.trim(),
        },
        "institutions": institutions
            .map((e) => e.text.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        "boards": boards.entries
            .where((e) => e.value)
            .map((e) => e.key)
            .toList(),
        "stateBoard": boards["State Board"] == true ? selectedStateBoard : null,
      };

      print('📤 Sending to: ${ApiConstants.authUrl}/api/teacher/step2/profile');
      print('📦 Payload: $payload');

      final res = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/api/teacher/step2/profile"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - Server not responding');
            },
          );

      print('🟢 Response Status: ${res.statusCode}');
      print('📥 Response Body: ${res.body}');

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _snack(data["message"] ?? "Profile saved successfully");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherStep3Levels(),
          ),
        );
      } else {
        final data = jsonDecode(res.body);
        _snack(data["message"] ?? "Failed to save profile");
      }
    } catch (e) {
      print('❌ Error: $e');
      _snack("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /* ================= Skip Function ================= */
  void _skipToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherStep3Levels(),
      ),
    );
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
                "Teacher Profile",
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
                      "Step 2 / 4",
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
                      _sectionTitle("Type of Teacher"),
                      ...teacherTypes.keys.map(_teacherTypeTile),

                      _sectionTitle("Mode of Teaching"),
                      ...teachingModes.keys.map(_teachingModeTile),

                      _sectionTitle("Language of Teaching"),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allLanguages.map((lang) {
                          final selected = selectedLanguages.contains(lang);
                          return FilterChip(
                            label: Text(lang),
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
                                v
                                    ? selectedLanguages.add(lang)
                                    : selectedLanguages.remove(lang);
                              });
                            },
                          );
                        }).toList(),
                      ),

                      _sectionTitle("Location"),
                      DropdownButtonFormField<String>(
                        value: selectedState,
                        hint: const Text("Select State"),
                        items: indianStates
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedState = v),
                        decoration: TemplateTheme.inputDecoration(label: "Select State").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: cityController,
                        decoration: TemplateTheme.inputDecoration(label: "City (Optional)").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),

                      _sectionTitle("Institution Name"),
                      ...institutions.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextField(
                              controller: c,
                              decoration: TemplateTheme.inputDecoration(label: "Institution").copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          )),
                      if (institutions.length < 3)
                        TextButton(
                          onPressed: () =>
                              setState(() => institutions.add(TextEditingController())),
                          child: Text(
                            "+ Add another",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: TemplateTheme.primary,
                            ),
                          ),
                        ),

                      _sectionTitle("Board You Teach"),
                      ...boards.keys.map(_boardTile),

                      if (boards["State Board"] == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: DropdownButtonFormField<String>(
                            value: selectedStateBoard,
                            hint: const Text("Select State Board"),
                            items: indianStates
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() => selectedStateBoard = v),
                            decoration: TemplateTheme.inputDecoration(label: "Select State Board").copyWith(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),

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
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
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

  Widget _teacherTypeTile(String key) {
    return CheckboxListTile(
      title: Text(
        key,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TemplateTheme.textPrimary,
        ),
      ),
      value: teacherTypes[key],
      activeColor: TemplateTheme.primary,
      onChanged: (v) => setState(() => teacherTypes[key] = v!),
    );
  }

  Widget _teachingModeTile(String key) {
    return CheckboxListTile(
      title: Text(
        key,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TemplateTheme.textPrimary,
        ),
      ),
      value: teachingModes[key],
      activeColor: TemplateTheme.primary,
      onChanged: (v) {
        setState(() {
          if (key == "Both" && v == true) {
            teachingModes.updateAll((k, v) => false);
            teachingModes["Both"] = true;
          } else {
            teachingModes["Both"] = false;
            teachingModes[key] = v!;
          }
        });
      },
    );
  }

  Widget _boardTile(String key) {
    return CheckboxListTile(
      title: Text(
        key,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: TemplateTheme.textPrimary,
        ),
      ),
      value: boards[key],
      activeColor: TemplateTheme.primary,
      onChanged: (v) => setState(() => boards[key] = v!),
    );
  }
}
