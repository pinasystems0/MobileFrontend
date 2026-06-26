import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/student_step2_parent.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class StudentStep1Profile extends StatefulWidget {
  final String email;
  final bool isEditMode;

  const StudentStep1Profile({
    super.key,
    required this.email,
    this.isEditMode = false,
  });

  @override
  State<StudentStep1Profile> createState() => _StudentStep1ProfileState();
}

class _StudentStep1ProfileState extends State<StudentStep1Profile> {
  String board = "CBSE";
  String standard = "10";
  String medium = "English";
  String? stream;

  final TextEditingController schoolName = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  bool isLoading = false;

  final boards = ["CBSE", "ICSE", "ISC", "State Board"];
  final standards = ["6", "7", "8", "9", "10", "11", "12"];
  final mediums = ["English", "Hindi"];
  final streams = ["Science", "Commerce", "Arts"];

  @override
  void initState() {
    super.initState();
    
    if (widget.isEditMode) {
      _loadExistingProfileData();
    }
  }

  Future<void> _loadExistingProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();
      
      if (token == null) return;

      final res = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/student/profile?email=${widget.email}"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['profile'] != null) {
          final profile = data['profile'];
          
          setState(() {
            board = profile['board'] ?? "CBSE";
            standard = profile['standard']?.toString() ?? "10";
            medium = profile['medium'] ?? "English";
            stream = profile['stream'];
            schoolName.text = profile['schoolName'] ?? '';
            city.text = profile['city'] ?? '';
            state.text = profile['state'] ?? '';
            dobController.text = profile['dob'] ?? '';
          });
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    if (ScaffoldMessenger.of(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> pickDOB() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      initialDate: DateTime(2010),
    );

    if (date != null) {
      dobController.text = DateFormat("yyyy-MM-dd").format(date);
    }
  }

  int _calculateAge(String dob) {
    final birthDate = DateTime.parse(dob);
    final today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> saveProfile() async {
    if (schoolName.text.trim().isEmpty ||
        city.text.trim().isEmpty ||
        state.text.trim().isEmpty ||
        dobController.text.isEmpty) {
      _snack("Please fill all required fields");
      return;
    }

    if ((standard == "11" || standard == "12") && stream == null) {
      _snack("Please select stream");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = await SessionService.getAuthToken();

      if (token == null) {
        _snack("Session expired. Please login again.");
        setState(() => isLoading = false);
        return;
      }

      final payload = {
        "email": widget.email,
        "isEdit": widget.isEditMode,
        
        "board": board,
        "standard": standard,
        "schoolName": schoolName.text.trim(),
        "medium": medium,
        "stream": stream,

        "dob": dobController.text,
        "city": city.text.trim(),
        "state": state.text.trim(),
      };

      final endpoint = widget.isEditMode 
          ? "${ApiConstants.authUrl}/api/student/profile/update"
          : "${ApiConstants.authUrl}/api/registration/step3/profile";
      
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        await prefs.setBool("completedStep3", true);

        if (!widget.isEditMode) {
          final int age = _calculateAge(dobController.text);
          
          if (!mounted) return;

          if (age < 18) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentStep2Parent(
                  email: widget.email,
                ),
              ),
            );
          } else {
            _snack("Profile saved. Redirecting to timetable...");
          }
        } else {
          _snack("Profile updated successfully");
          Navigator.pop(context);
        }
      } else {
        _snack(data["message"] ?? "Failed to save profile");
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
                "Student Profile",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      "Step 1 / 4",
                      style: const TextStyle(
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
                        builder: (_) => StudentStep2Parent(email: widget.email),
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
                      _sectionTitle("Education Details"),
                      _sectionTitle("Board"),
                      DropdownButtonFormField<String>(
                        value: board,
                        hint: const Text("Select Board"),
                        items: boards.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => board = v!),
                        decoration: TemplateTheme.inputDecoration(label: "Select Board").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _sectionTitle("Class / Standard"),
                      DropdownButtonFormField<String>(
                        value: standard,
                        hint: const Text("Select Standard"),
                        items: standards.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) {
                          setState(() {
                            standard = v!;
                            if (v != "11" && v != "12") stream = null;
                          });
                        },
                        decoration: TemplateTheme.inputDecoration(label: "Select Standard").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (standard == "11" || standard == "12") ...[
                        _sectionTitle("Stream"),
                        DropdownButtonFormField<String>(
                          value: stream,
                          hint: const Text("Select Stream"),
                          items: streams.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => stream = v),
                          decoration: TemplateTheme.inputDecoration(label: "Select Stream").copyWith(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      _sectionTitle("Medium"),
                      DropdownButtonFormField<String>(
                        value: medium,
                        hint: const Text("Select Medium"),
                        items: mediums.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => medium = v!),
                        decoration: TemplateTheme.inputDecoration(label: "Select Medium").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _sectionTitle("School Details"),
                      TextField(
                        controller: schoolName,
                        decoration: TemplateTheme.inputDecoration(label: "School Name *").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: city,
                              decoration: TemplateTheme.inputDecoration(label: "City *").copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: state,
                              decoration: TemplateTheme.inputDecoration(label: "State *").copyWith(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _sectionTitle("Date of Birth *"),
                      TextField(
                        controller: dobController,
                        readOnly: true,
                        onTap: pickDOB,
                        decoration: TemplateTheme.inputDecoration(label: "YYYY-MM-DD").copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : saveProfile,
                          style: TemplateTheme.primaryButtonStyle(),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: TemplateTheme.textPrimary,
                                  ),
                                )
                              : Text(
                                  widget.isEditMode ? "Update Profile" : "Continue",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 80),
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
    schoolName.dispose();
    city.dispose();
    state.dispose();
    dobController.dispose();
    super.dispose();
  }
}
