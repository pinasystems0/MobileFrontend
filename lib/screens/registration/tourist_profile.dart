import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'registration_done.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/screens/constants.dart';

import '../../ui_template/utils/backgroundscreen.dart';
import '../../ui_template/utils/responsive_form_layout.dart';
import '../../ui_template/utils/template_theme.dart';

class TouristProfile extends StatefulWidget {
  final String email;

  const TouristProfile({
    super.key,
    required this.email,
  });

  @override
  State<TouristProfile> createState() => _TouristProfileState();
}

class _TouristProfileState extends State<TouristProfile> {
  // ===========================================================================
  // Controllers
  // ===========================================================================
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController membersController = TextEditingController();

  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // Radio selections
  // ---------------------------------------------------------------------------
  String? travelMode; // "Single" or "Group"
  String? nationality; // "Indian" or "Non-Indian"

  // ---------------------------------------------------------------------------
  // Dropdown selection
  // ---------------------------------------------------------------------------
  String? preferredLanguage;

  // ---------------------------------------------------------------------------
  // Options lists
  // ---------------------------------------------------------------------------
  final List<String> languageOptions = const [
    'English',
    'Hindi',
    'Marathi',
    'Gujarati',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Punjabi',
    'Other',
  ];

  // ===========================================================================
  // Form key
  // ===========================================================================
  final _formKey = GlobalKey<FormState>();

  // ===========================================================================
  // Init
  // ===========================================================================
  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  // ===========================================================================
  // Dispose
  // ===========================================================================
  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    membersController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Validation & Submit
  // ===========================================================================
  Future<void> _saveAndNavigate() async {
    if (!_formKey.currentState!.validate()) return;

    // Radio validation
    if (travelMode == null) {
      _showSnackBar('Please select Single or Group');
      return;
    }

    if (nationality == null) {
      _showSnackBar('Please select Indian or Non-Indian');
      return;
    }

    // Conditional validation: Number of Members required if Group
    if (travelMode == 'Group' && membersController.text.trim().isEmpty) {
      _showSnackBar('Please enter number of members for Group');
      return;
    }

    if (preferredLanguage == null) {
      _showSnackBar('Please select preferred language');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // ---- POST /api/tourist/profile ----
      final token = await SessionService.getAuthToken();
      if (token == null) {
        _showSnackBar('Authentication token not found. Please login again.');
        setState(() => isLoading = false);
        return;
      }

      final response = await http
          .post(
            Uri.parse('${ApiConstants.authUrl}/api/tourist/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'email': widget.email,
              'fullName': fullNameController.text.trim(),
              'mobile': mobileController.text.trim(),
              'travelMode': travelMode,
              'nationality': nationality,
              'numberOfMembers': travelMode == 'Group'
                  ? membersController.text.trim()
                  : '',
              'preferredLanguage': preferredLanguage,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save to local storage as backup
        await prefs.setString('touristFullName', fullNameController.text.trim());
        await prefs.setString('touristMobile', mobileController.text.trim());
        await prefs.setString('touristTravelMode', travelMode ?? '');
        await prefs.setString('touristNationality', nationality ?? '');
        await prefs.setString(
            'touristNumberOfMembers',
            travelMode == 'Group' ? membersController.text.trim() : '');
        await prefs.setString('touristPreferredLanguage', preferredLanguage ?? '');

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RegistrationDone(),
          ),
        );
      } else {
        _showSnackBar(data['message'] ?? 'Failed to save tourist profile');
      }
    } catch (e) {
      _showSnackBar('Error saving data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===========================================================================
  // Reusable Widgets
  // ===========================================================================
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
    bool readOnly = false,
    String? Function(String?)? customValidator,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        style: const TextStyle(
          fontSize: 12,
          color: TemplateTheme.textPrimary,
        ),
        decoration: TemplateTheme.inputDecoration(
          label: required ? '$label *' : label,
          hint: hint,
        ),
        validator: customValidator ??
            (required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                : null),
      ),
    );
  }

  Widget _buildRadioSection({
    required String title,
    required List<String> options,
    required String? groupValue,
    required Function(String?) onChanged,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title${required ? ' *' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: TemplateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: options.map((option) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                  value: option,
                  groupValue: groupValue,
                  activeColor: TemplateTheme.primary,
                  onChanged: onChanged,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title${required ? ' *' : ''}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: TemplateTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.white,
            decoration: TemplateTheme.inputDecoration(
              label: title,
            ).copyWith(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 13,
              color: TemplateTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: TemplateTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: TemplateTheme.primary,
        ),
      ),
    );
  }

  // ===========================================================================
  // Build
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: TemplateTheme.textPrimary,
        ),
        title: const Text(
          'Tourist Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TemplateTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegistrationDone(),
                ),
              );
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: TemplateTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TemplateBackdrop(
        child: SafeArea(
          child: ResponsiveFormLayout(
            title: 'Tourist Registration',
            subtitle: 'Complete your Tourist profile',
            content: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // SECTION 1: Personal Information
                      // ======================================================
                      _buildSectionHeader('Personal Information'),

                      // Full Name
                      _buildTextField(
                        label: 'Full Name',
                        controller: fullNameController,
                        hint: 'Enter your full name',
                      ),

                      // Email (prefilled and read-only)
                      _buildTextField(
                        label: 'Email',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        hint: widget.email,
                        customValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      // Mobile Number
                      _buildTextField(
                        label: 'Mobile Number',
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        hint: 'Enter mobile number',
                        customValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile Number is required';
                          }
                          if (value.trim().length < 10) {
                            return 'Enter a valid mobile number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 4),

                      // ======================================================
                      // SECTION 2: Travel Details
                      // ======================================================
                      _buildSectionHeader('Travel Details'),

                      // Single / Group - Radio
                      _buildRadioSection(
                        title: 'Travel Mode',
                        options: const ['Single', 'Group'],
                        groupValue: travelMode,
                        onChanged: (value) {
                          setState(() {
                            travelMode = value;
                            if (value == 'Single') {
                              membersController.clear();
                            }
                          });
                        },
                      ),

                      // Number of Members (shown only when Group is selected)
                      if (travelMode == 'Group')
                        _buildTextField(
                          label: 'Number of Members',
                          controller: membersController,
                          keyboardType: TextInputType.number,
                          hint: 'Enter number of members',
                          customValidator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Number of Members is required for Group';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                              return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),

                      // Indian / Non-Indian - Radio
                      _buildRadioSection(
                        title: 'Nationality',
                        options: const ['Indian', 'Non-Indian'],
                        groupValue: nationality,
                        onChanged: (value) {
                          setState(() {
                            nationality = value;
                          });
                        },
                      ),

                      // Preferred Language - Dropdown
                      _buildDropdownSection(
                        title: 'Preferred Language',
                        value: preferredLanguage,
                        options: languageOptions,
                        onChanged: (value) {
                          setState(() {
                            preferredLanguage = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            bottomButtons: [
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveAndNavigate,
                  style: TemplateTheme.primaryButtonStyle(
                    padding: EdgeInsets.zero,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

