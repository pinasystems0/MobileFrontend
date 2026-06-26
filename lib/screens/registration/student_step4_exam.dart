import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/registration_done.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class StudentStep4Exam extends StatefulWidget {
  const StudentStep4Exam({super.key});

  @override
  State<StudentStep4Exam> createState() => _StudentStep4ExamState();
}

class _StudentStep4ExamState extends State<StudentStep4Exam> {
  bool isLoading = false;

  // Controllers
  final TextEditingController examName = TextEditingController();
  final TextEditingController subject = TextEditingController();
  final TextEditingController totalMarks = TextEditingController();
  final TextEditingController obtainedMarks = TextEditingController();
  final TextEditingController grade = TextEditingController();
  final TextEditingController semester = TextEditingController();
  final TextEditingController examDate = TextEditingController();
  final TextEditingController digilockerUrl = TextEditingController();

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      examDate.text =
          "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
    }
  }

  Future<void> saveExam() async {
    if (examName.text.trim().isEmpty || subject.text.trim().isEmpty) {
      _snack("Exam name and subject are required");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      if (token == null) {
        _snack("User session missing");
        setState(() => isLoading = false);
        return;
      }

      final payload = {
        "examName": examName.text.trim(),
        "subject": subject.text.trim(),
        "totalMarks": totalMarks.text.trim(),
        "obtainedMarks": obtainedMarks.text.trim(),
        "grade": grade.text.trim(),
        "semester": semester.text.trim(),
        "examDate": examDate.text.trim(),
        "digilockerUrl": digilockerUrl.text.trim(),
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/registration/step3/exam"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        _snack("Exam details saved");

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationDone()),
        );
      } else {
        _snack(data["message"] ?? "Failed to save exam");
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
                "Exam Details",
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistrationDone()),
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
                      _sectionTitle("Academic Performance"),
                      TextField(
                        controller: examName,
                        decoration: TemplateTheme.inputDecoration(label: "Exam Name *").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: subject,
                        decoration: TemplateTheme.inputDecoration(label: "Subject *").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: totalMarks,
                              keyboardType: TextInputType.number,
                              decoration: TemplateTheme.inputDecoration(label: "Total Marks").copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: obtainedMarks,
                              keyboardType: TextInputType.number,
                              decoration: TemplateTheme.inputDecoration(label: "Obtained Marks").copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: grade,
                        decoration: TemplateTheme.inputDecoration(label: "Grade").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: semester,
                        decoration: TemplateTheme.inputDecoration(label: "Semester").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _sectionTitle("Exam Date"),
                      TextField(
                        controller: examDate,
                        readOnly: true,
                        onTap: pickDate,
                        decoration: TemplateTheme.inputDecoration(label: "YYYY-MM-DD").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: digilockerUrl,
                        decoration: TemplateTheme.inputDecoration(label: "Digilocker URL (optional)").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : saveExam,
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
    examName.dispose();
    subject.dispose();
    totalMarks.dispose();
    obtainedMarks.dispose();
    grade.dispose();
    semester.dispose();
    examDate.dispose();
    digilockerUrl.dispose();
    super.dispose();
  }
}
