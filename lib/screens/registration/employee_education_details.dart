import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'employee_work_details.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class EmployeeEducationDetailsScreen extends StatefulWidget {
  const EmployeeEducationDetailsScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeEducationDetailsScreen> createState() =>
      _EmployeeEducationDetailsScreenState();
}

class _EmployeeEducationDetailsScreenState
    extends State<EmployeeEducationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  String? educationLevel;
  String? educationDegree;
  String? experience;
  String? industry;
  String? role;
  String? careerTarget; // ✅ ADDED: Career Target variable

  final TextEditingController otherDegreeController =
      TextEditingController();
  final TextEditingController otherIndustryController =
      TextEditingController();
  final TextEditingController otherRoleController =
      TextEditingController();

  bool isLoading = false;

  // ================= DROPDOWN DATA =================

  final List<String> educationLevels = [
    'SSC',
    'HSC',
    'Graduate',
    'Postgraduate',
    'Diploma',
    'Doctorate',
  ];

  final List<String> educationDegrees = [
    'Art',
    'Science',
    'Commerce',
    'Arts',
    'Engineering',
    'Doctor',
    'MBA',
    'Chartered Accountant',
    'Company Secretary',
    'CFA',
    'IAS',
    'IPS',
    'Other',
  ];

  final List<String> experiences = [
    '0-2 Years',
    '2-5 Years',
    '5-10 Years',
    '10+ Years',
  ];

  final List<String> industries = [
    'Diet Manufacturing',
    'Chemical',
    'Information Technology',
    'BPO',
    'Automobile',
    'Telecom',
    'Other',
  ];

  final List<String> roles = [
    'Trainee',
    'Clerk',
    'Officer',
    'Manager',
    'Director',
    'Other', 
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

  // ================= API CALL =================

  Future<void> submitEducationDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      if (token == null) {
        throw Exception("Authentication token missing");
      }

      final response = await http.post(
        Uri.parse(
          '${ApiConstants.authUrl}/api/employee/education-details',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'educationLevel': educationLevel,
          'educationDegree': educationDegree,
          'otherDegree':
              educationDegree == 'Other' ? otherDegreeController.text : null,
          'experience': experience,
          'industry': industry,
          'otherIndustry':
              industry == 'Other' ? otherIndustryController.text : null,
          'employeeRole': role,
          'otherRole': role == 'Other' ? otherRoleController.text : null,
          'careerTarget': careerTarget, // ✅ ADDED: Career Target in API body
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const EmployeeWorkDetailsScreen(),
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
          content: Text('Error: $e'),
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
                "Education Details",
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
                      "Step 1 / 2",
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
                        builder: (_) => const EmployeeWorkDetailsScreen(),
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
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _dropdown(
                      label: 'Education Level',
                      value: educationLevel,
                      items: educationLevels,
                      onChanged: (v) => setState(() => educationLevel = v),
                      isRequired: true, // ✅ Required
                    ),
                    const SizedBox(height: 12),

                    _dropdown(
                      label: 'Education Degree',
                      value: educationDegree,
                      items: educationDegrees,
                      onChanged: (v) => setState(() => educationDegree = v),
                      isRequired: true, // ✅ Required
                    ),
                    const SizedBox(height: 12),

                    if (educationDegree == 'Other')
                      TextFormField(
                        controller: otherDegreeController,
                        decoration: TemplateTheme.inputDecoration(
                          label: 'Specify Other Degree',
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

                    const SizedBox(height: 12),

                    _dropdown(
                      label: 'Experience',
                      value: experience,
                      items: experiences,
                      onChanged: (v) => setState(() => experience = v),
                      isRequired: true, // ✅ Required
                    ),
                    const SizedBox(height: 12),

                    _dropdown(
                      label: 'Industry',
                      value: industry,
                      items: industries,
                      onChanged: (v) => setState(() => industry = v),
                      isRequired: true, // ✅ Required
                    ),

                    const SizedBox(height: 12),

                    if (industry == 'Other')
                      TextFormField(
                        controller: otherIndustryController,
                        decoration: TemplateTheme.inputDecoration(
                          label: 'Specify Other Industry',
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

                    const SizedBox(height: 12),

                    _dropdown(
                      label: 'Role',
                      value: role,
                      items: roles,
                      onChanged: (v) => setState(() => role = v),
                      isRequired: true, // ✅ Required
                    ),

                    const SizedBox(height: 12),

                    if (role == 'Other')
                      TextFormField(
                        controller: otherRoleController,
                        decoration: TemplateTheme.inputDecoration(
                          label: 'Specify Other Role',
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

                    const SizedBox(height: 12),

                    // ✅ ADDED: Career Target dropdown (Optional)
                    _dropdown(
                      label: 'Career Target (Optional)',
                      value: careerTarget,
                      items: careerTargets,
                      onChanged: (v) => setState(() => careerTarget = v),
                      isRequired: false, // ✅ OPTIONAL - No validation
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : submitEducationDetails,
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
                                'Next',
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
      ),
    );
  }

  // ================= REUSABLE DROPDOWN =================

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = true, // ✅ NEW PARAMETER (default = required)
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: TemplateTheme.inputDecoration(label: label).copyWith(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: const TextStyle(
                  fontSize: 13,
                  color: TemplateTheme.textPrimary,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) {
        if (!isRequired) return null; // ✅ OPTIONAL: No validation
        return v == null ? 'Required' : null; // ✅ REQUIRED: Validation applies
      },
      style: const TextStyle(
        fontSize: 13,
        color: TemplateTheme.textPrimary,
      ),
    );
  }
}