import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/student_step1_profile.dart';
import 'package:pina/screens/registration/teacher_step2_profile.dart';
import 'package:pina/screens/registration/employee_education_details.dart';
import 'package:pina/screens/registration/registration_done.dart';
import 'package:pina/screens/registration/profession_details_screen.dart';
import 'package:pina/ui_template/utils/responsive_form_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/registration/educational_institute_profile.dart';
import 'package:pina/screens/registration/hr_agency.dart';
import 'package:pina/screens/registration/travel_agency_profile.dart';
import 'package:pina/screens/registration/hotels_lodging_profile.dart';
import 'package:pina/screens/registration/company_ai.dart';
import 'package:pina/screens/registration/tourist_profile.dart';
import 'package:pina/screens/registration/travel_guide_profile.dart';

class RegistrationStep2 extends StatefulWidget {
  final String email;
  final String category;
  final bool isEducationalInstitute;

  const RegistrationStep2({
    super.key,
    required this.email,
    required this.category,
    this.isEducationalInstitute = false,
  });

  @override
  State<RegistrationStep2> createState() => _RegistrationStep2State();
}

class _RegistrationStep2State extends State<RegistrationStep2> {
  static const Duration _requestTimeout = Duration(seconds: 20);

  String userType = "free";
  String accountType = "private";
  bool isLoading = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= STEP 2 API =================
  Future<void> _onContinuePressed() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final payload = {
        "email": widget.email,
        "userType": userType,
        "accountType": accountType,
        "category": widget.category,
        "isEducationalInstitute": widget.isEducationalInstitute,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/registration/step2"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      ).timeout(_requestTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ save local progress
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("completedStep2", true);
        await prefs.setString("category", widget.category);
        await prefs.setString("userRole", widget.category);
        await prefs.setString("userType", userType);

        _snack("Step 2 completed");

        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;

        // Extract nextStep from response
        final int nextStep = data['nextStep'] ?? 3;

        if (nextStep == 3) {
          if (widget.category == "Student") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentStep1Profile(email: widget.email),
              ),
            );
          }
          else if (widget.category == "Teacher") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TeacherStep2Profile(email: widget.email),
              ),
            );
          }
          else if (widget.category == "Employee") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const EmployeeEducationDetailsScreen(),
              ),
            );
          }
          else if (widget.category == "Tourist") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TouristProfile(email: widget.email),
              ),
            );
          }
          else if (widget.category == "Travel Guide") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TravelGuideProfile(email: widget.email),
              ),
            );
          }
          // else if (widget.category == "Company AI") {
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => const CompanyAIScreen(),
          //     ),
          //   );
          // }
          else if (widget.category == "Educational Institute") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const EducationalInstituteProfile(),
              ),
            );
          }
          else if (widget.category == "HR Placement Agency") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HrAgencyProfile(
                  email: widget.email,
                ),
              ),
            );
          }
          else if (widget.category == "Travel Agency") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => TravelAgencyProfile(
                  email: widget.email,
                ),
              ),
            );
          }
          else if (widget.category == "Hotels & Lodging") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HotelsLodgingProfile(
                  email: widget.email,
                ),
              ),
            );
          }
          else if (widget.category == "Professional") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfessionDetailsScreen(),
              ),
            );
          }
          else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegistrationDone()),
            );
          }
        }
        else {
          // Fallback for unexpected nextStep values.
          // All known categories (Student, Teacher, Employee,
          // Educational Institute, HR Placement Agency, Travel Agency,
          // Hotels & Lodging, Professional) are routed in the nextStep == 3
          // branch above, so we only reach this fallback when the backend
          // returns an unfamiliar nextStep value.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RegistrationDone()),
          );
        }
      } else {
        _snack(data["toastMessage"] ?? "Failed to save Step 2");
      }
    } on TimeoutException {
      _snack("Server timeout. Check backend at ${ApiConstants.authUrl}");
    } on SocketException {
      _snack("Cannot reach server. Check network/backend.");
    } catch (e) {
      _snack("Server error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: TemplateBackdrop(
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(
                  color: TemplateTheme.textPrimary,
                ),
                title: const Text(
                  "Account Preferences",
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
                ],
              ),
              body: SafeArea(
                child: ResponsiveFormLayout(
                  title: "Account Preferences",
                  subtitle: "Category: ${widget.category}",
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: userType,
                        decoration: TemplateTheme.inputDecoration(
                          label: "Subscription Type",
                        ).copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: "free", child: Text("Free")),
                          DropdownMenuItem(value: "paid", child: Text("Paid")),
                        ],
                        onChanged: isLoading ? null : (v) => setState(() => userType = v!),
                        style: const TextStyle(
                          fontSize: 13,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: accountType,
                        decoration: TemplateTheme.inputDecoration(
                          label: "Account Type",
                        ).copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: "private", child: Text("Private")),
                          DropdownMenuItem(value: "company", child: Text("Company")),
                        ],
                        onChanged: isLoading ? null : (v) => setState(() => accountType = v!),
                        style: const TextStyle(
                          fontSize: 13,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  bottomButtons: [
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onContinuePressed,
                        style: TemplateTheme.primaryButtonStyle(),
                        child: isLoading 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}