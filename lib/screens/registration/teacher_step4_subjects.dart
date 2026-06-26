import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/registration_done.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class TeacherStep4Subjects extends StatefulWidget {
  const TeacherStep4Subjects({super.key});

  @override
  State<TeacherStep4Subjects> createState() => _TeacherStep4SubjectsState();
}

class _TeacherStep4SubjectsState extends State<TeacherStep4Subjects> {
  bool isLoading = false;

  final TextEditingController subjectController = TextEditingController();

  /* ================= Master Suggestions ================= */
  final List<String> masterSubjects = [
    "Mathematics", "Maths",
    "Physics",
    "Chemistry",
    "Biology",
    "Science",
    "English",
    "Hindi", "Marathi", "Tamil", "Telugu", "Kannada", "Malayalam",
    "Computer", "Computer Science",
    "Coding", "Programming",
    "AI", "Artificial Intelligence",
    "Data Science", "Machine Learning",
    "Social Science",
    "History",
    "Geography",
    "Economics",
    "Accountancy",
    "Business Studies", "Commerce",
    "Music",
    "Dance",
    "Sports", "Physical Education",
    "Yoga",
    "Art", "Drawing", "Painting",
    "Environmental Science",
    "Political Science",
    "Psychology",
    "Sociology",
    "Sanskrit",
    "French",
    "German",
    "Spanish",
    "Robotics",
    "Web Development",
    "Mobile App Development",
    "Database Management",
    "Cyber Security",
    "Cloud Computing",
    "Internet of Things",
    "Blockchain",
    "Digital Marketing",
    "Graphic Design",
    "Animation",
  ];

  final List<String> selectedSubjects = [];

  /* ================= Helpers ================= */
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validate() {
    if (selectedSubjects.isEmpty) {
      _snack("Please add at least one subject");
      return false;
    }
    return true;
  }

  void _addSubject(String value) {
    final subject = value.trim();
    if (subject.isEmpty) return;

    // Capitalize first letter
    String formattedSubject = subject;
    if (formattedSubject.isNotEmpty) {
      formattedSubject = formattedSubject[0].toUpperCase() + 
                         formattedSubject.substring(1).toLowerCase();
    }

    if (!selectedSubjects.contains(formattedSubject)) {
      setState(() {
        selectedSubjects.add(formattedSubject);
      });
    }
    subjectController.clear();
  }

  /* ================= Save & Finish ================= */
  Future<void> _finishRegistration() async {
    if (!_validate()) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();
      final email = prefs.getString("userEmail");

      if (token == null) {
        _snack("Session expired. Please login again.");
        return;
      }

      final payload = {
        "email": email,
        "subjects": selectedSubjects,
      };

      final res = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/teacher/step4/subjects"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const RegistrationDone(),
          ),
          (_) => false,
        );
      } else {
        final data = jsonDecode(res.body);
        _snack(data["message"] ?? "Failed to complete registration");
      }
    } catch (e) {
      _snack("Server error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /* ================= Skip Function ================= */
  void _skipAndFinish() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const RegistrationDone(),
      ),
      (_) => false,
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
                "Subjects",
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
                  onPressed: _skipAndFinish,
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
                        "Subjects You Teach",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Type or select subjects from suggestions.",
                        style: TextStyle(
                          fontSize: 13,
                          color: TemplateTheme.textMuted,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /* ===== Simple Autocomplete ===== */
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue value) {
                          if (value.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return masterSubjects.where(
                            (s) => s.toLowerCase().contains(value.text.toLowerCase()),
                          );
                        },
                        onSelected: (selection) => _addSubject(selection),
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                color: Colors.white,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(
                                        option,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: TemplateTheme.textPrimary,
                                        ),
                                      ),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: TemplateTheme.inputDecoration(
                              label: "Type subject name",
                            ).copyWith(
                              hintText: "e.g. Mathematics, Coding...",
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.add, color: TemplateTheme.primary),
                                onPressed: () => _addSubject(controller.text),
                                tooltip: "Add subject",
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: TemplateTheme.textPrimary,
                            ),
                            onSubmitted: _addSubject,
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      /* ===== Quick Suggestions ===== */
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Popular Subjects:",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              "Mathematics",
                              "Science",
                              "English",
                              "Physics",
                              "Chemistry",
                              "History",
                              "Geography",
                              "Computer",
                              "Coding",
                              "Music",
                              "Art",
                              "Economics"
                            ].map((subject) {
                              return FilterChip(
                                label: Text(subject),
                                selected: selectedSubjects.contains(subject),
                                selectedColor: TemplateTheme.primary,
                                backgroundColor: Colors.white.withOpacity(0.8),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selectedSubjects.contains(subject)
                                      ? Colors.white
                                      : TemplateTheme.textPrimary,
                                ),
                                onSelected: (selected) => _addSubject(subject),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      /* ===== Selected Subjects ===== */
                      if (selectedSubjects.isNotEmpty) ...[
                        Text(
                          "Your Subjects:",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: TemplateTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedSubjects.map((sub) {
                            return Chip(
                              label: Text(
                                sub,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: TemplateTheme.textPrimary,
                                ),
                              ),
                              backgroundColor: Colors.white.withOpacity(0.9),
                              deleteIcon: Icon(Icons.close, size: 18, color: TemplateTheme.textMuted),
                              onDeleted: () {
                                setState(() {
                                  selectedSubjects.remove(sub);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],

                      const SizedBox(height: 20),

                      /* ===== Finish Button ===== */
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _finishRegistration,
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
                          const SizedBox(height: 12),
                          Text(
                            "${selectedSubjects.length} subject${selectedSubjects.length == 1 ? '' : 's'} added",
                            style: TextStyle(
                              fontSize: 12,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                        ],
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
}
