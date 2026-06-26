import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/professional_ai_screen.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class ProfessionDetailsScreen extends StatefulWidget {
  const ProfessionDetailsScreen({super.key});

  @override
  State<ProfessionDetailsScreen> createState() =>
      _ProfessionDetailsScreenState();
}

class _ProfessionDetailsScreenState extends State<ProfessionDetailsScreen> {

  final _formKey = GlobalKey<FormState>();

  String? profession;
  String? educationLevel;
  String? educationDegree;
  String? experience;
  String? industry;
  String? role;
  String? careerTarget; // ✅ ADDED: Career Target variable

  bool isLoading = false;
  bool isLoadingProfessions = true;

  // ================= DROPDOWN DATA =================

  List<String> professions = [];

  final educationLevels = [
    "SSC",
    "HSC",
    "Graduate",
    "Postgraduate",
    "Diploma",
    "Doctorate",
  ];

  final educationDegrees = [
    "Art",
    "Science",
    "Commerce",
    "Engineering",
    "Medical",
    "MBA",
    "BCA",
    "MCA",
    "B.Com",
    "MBBS",
    "PhD",
    "Other",
  ];

  final experiences = [
    "0-2 Years",
    "2-5 Years",
    "5-10 Years",
    "10+ Years",
  ];

  final industries = [
    "Information Technology",
    "Healthcare",
    "Finance",
    "Education",
    "Legal",
    "Construction",
    "Consulting",
    "Sports",
    "Arts",
    "Event Management",
    "Manufacturing",
    "Other",
  ];

  final roles = [
    "Trainee",
    "Junior",
    "Senior",
    "Manager",
    "Consultant",
    "Director",
    "Other",
  ];

  // ✅ ADDED: Career Target options
  final List<String> careerTargets = [
    'Doctor',
    'Engineer',
    'Teacher',
    'Lawyer',
    'Accountant',
    'Architect',
    'Nurse',
    'Pharmacist',
    'Dentist',
    'Psychologist',
    'Data Scientist',
    'Software Developer',
    'Designer',
    'Consultant',
    'Other',
  ];

  // ================= API FUNCTIONS =================

  Future<void> loadProfessions() async {
    try {
      final token = await SessionService.getAuthToken();

      final response = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/professional/professions"),
        headers: token != null
            ? {"Authorization": "Bearer $token"}
            : {},
      );

      final data = jsonDecode(response.body);

      if (data["success"]) {
        setState(() {
          professions = List<String>.from(
            data["data"].map((e) => e["profession_name"]),
          );
          isLoadingProfessions = false;
        });
      } else {
        print("Failed to load professions: ${data["message"]}");
        setState(() {
          isLoadingProfessions = false;
        });
      }
    } catch (e) {
      print("Error loading professions: $e");
      setState(() {
        isLoadingProfessions = false;
      });
    }
  }

  Future<void> submitDetails() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {

      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/professional/details"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "profession": profession,
          "educationLevel": educationLevel,
          "educationDegree": educationDegree,
          "experience": experience,
          "industry": industry,
          "role": role,
          "careerTarget": careerTarget, // ✅ ADDED: Career Target in API body
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfessionalAIScreen(),
          ),
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

  // ================= INIT STATE =================

  @override
  void initState() {
    super.initState();
    loadProfessions();
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
                "Professional Details",
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
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfessionalAIScreen(),
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
                Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 12),

                      dropdown(
                        "Profession",
                        profession,
                        professions,
                        (v) => setState(() => profession = v),
                        isLoading: isLoadingProfessions,
                      ),

                      const SizedBox(height: 12),

                      dropdown(
                        "Education Level",
                        educationLevel,
                        educationLevels,
                        (v) => setState(() => educationLevel = v),
                      ),

                      const SizedBox(height: 12),

                      dropdown(
                        "Education Degree",
                        educationDegree,
                        educationDegrees,
                        (v) => setState(() => educationDegree = v),
                      ),

                      const SizedBox(height: 12),

                      dropdown(
                        "Experience",
                        experience,
                        experiences,
                        (v) => setState(() => experience = v),
                      ),

                      const SizedBox(height: 12),

                      dropdown(
                        "Industry",
                        industry,
                        industries,
                        (v) => setState(() => industry = v),
                      ),

                      const SizedBox(height: 12),

                      dropdown(
                        "Role",
                        role,
                        roles,
                        (v) => setState(() => role = v),
                      ),

                      const SizedBox(height: 12),

                      // ✅ ADDED: Career Target dropdown (Optional)
                      dropdown(
                        "Career Target (Optional)",
                        careerTarget,
                        careerTargets,
                        (v) => setState(() => careerTarget = v),
                        isRequired: false, // ✅ IMPORTANT: Optional field
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitDetails,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= REUSABLE DROPDOWN WITH LOADING FALLBACK =================

  Widget dropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    bool isLoading = false,
    bool isRequired = true, // ✅ NEW PARAMETER (default = required)
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: TemplateTheme.inputDecoration(label: label).copyWith(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: isLoading || items.isEmpty
          ? [
              const DropdownMenuItem<String>(
                value: null,
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 13,
                    color: TemplateTheme.textMuted,
                  ),
                ),
              )
            ]
          : items.map((e) {
              return DropdownMenuItem<String>(
                value: e,
                child: Text(
                  e,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
      onChanged: isLoading ? null : onChanged,
      validator: (v) {
        if (!isRequired) return null; // ✅ OPTIONAL: No validation
        return v == null && !isLoading ? "Required" : null; // ✅ REQUIRED: Validation applies
      },
      style: const TextStyle(
        fontSize: 13,
        color: TemplateTheme.textPrimary,
      ),
    );
  }
}