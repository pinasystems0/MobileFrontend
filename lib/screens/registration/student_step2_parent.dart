import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/student_step3_timetable.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class StudentStep2Parent extends StatefulWidget {
  final String email;

  const StudentStep2Parent({
    super.key,
    required this.email,
  });

  @override
  State<StudentStep2Parent> createState() => _StudentStep2ParentState();
}

class _StudentStep2ParentState extends State<StudentStep2Parent> {
  final parentName = TextEditingController();
  final parentMobile = TextEditingController();
  final parentEmail = TextEditingController();

  String relationship = "Father";
  bool isLoading = false;

  final relations = ["Father", "Mother", "Guardian"];

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> saveParentDetails() async {
    if (parentName.text.trim().isEmpty ||
        parentMobile.text.trim().isEmpty) {
      _snack("Please fill required fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = await SessionService.getAuthToken();

      if (token == null) {
        _snack("User session missing");
        return;
      }

      final payload = {
        "parentName": parentName.text.trim(),
        "parentMobile": parentMobile.text.trim(),
        "parentEmail": parentEmail.text.trim(),
        "relationship": relationship,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/registration/step3/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _snack("Parent details saved");

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StudentStep3Timetable(),
          ),
        );
      } else {
        _snack("Failed to save parent details");
      }
    } catch (e) {
      _snack("Server error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
                "Parent Details",
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentStep3Timetable(),
                      ),
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Parent / Guardian Information"),
                      TextField(
                        controller: parentName,
                        decoration: TemplateTheme.inputDecoration(label: "Parent Name *").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: parentMobile,
                        keyboardType: TextInputType.phone,
                        decoration: TemplateTheme.inputDecoration(label: "Parent Mobile *").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: parentEmail,
                        keyboardType: TextInputType.emailAddress,
                        decoration: TemplateTheme.inputDecoration(label: "Parent Email (optional)").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionTitle("Relationship"),
                      DropdownButtonFormField<String>(
                        value: relationship,
                        hint: const Text("Select relationship"),
                        items: relations.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (v) => setState(() => relationship = v!),
                        decoration: TemplateTheme.inputDecoration(label: "Select relationship").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : saveParentDetails,
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
                                  "Continue",
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

  @override
  void dispose() {
    parentName.dispose();
    parentMobile.dispose();
    parentEmail.dispose();
    super.dispose();
  }
}
