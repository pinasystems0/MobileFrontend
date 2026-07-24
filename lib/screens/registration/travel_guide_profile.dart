import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'registration_done.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/screens/constants.dart';

import '../../ui_template/utils/responsive_form_layout.dart';
import '../../ui_template/utils/template_theme.dart';

class TravelGuideProfile extends StatefulWidget {
  final String email;
  final bool isEditMode;

  const TravelGuideProfile({
    super.key,
    required this.email,
    this.isEditMode = false,
  });

  @override
  State<TravelGuideProfile> createState() => _TravelGuideProfileState();
}

class _TravelGuideProfileState extends State<TravelGuideProfile> {
  // ===========================================================================
  // Controllers
  // ===========================================================================
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController locationsController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();

  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // Dropdown selections
  // ---------------------------------------------------------------------------
  String? gender;
  String? guideType;
  String? yearsOfExperience;
  String? preferredLanguageForGuiding;

  // ---------------------------------------------------------------------------
  // Multi-select maps
  // ---------------------------------------------------------------------------
  final Map<String, bool> languagesKnown = {};
  final Map<String, bool> areasOfExpertise = {};
  final Map<String, bool> transportModes = {};
  final Map<String, bool> availability = {};

  // ---------------------------------------------------------------------------
  // Options lists
  // ---------------------------------------------------------------------------
  final List<String> genderOptions = const [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> guideTypeOptions = const [
    'Freelance',
    'Certified Guide',
    'Local Guide',
  ];

  final List<String> experienceOptions = const [
    '0-1 Years',
    '1-3 Years',
    '3-5 Years',
    '5-10 Years',
    '10+ Years',
  ];

  final List<String> allLanguages = const [
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
    'Odia',
    'Urdu',
    'French',
    'Spanish',
    'German',
    'Arabic',
    'Other',
  ];

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
    'Odia',
    'Urdu',
    'French',
    'Spanish',
    'German',
    'Arabic',
    'Other',
  ];

  final List<String> expertiseOptions = const [
    'Historical',
    'Adventure',
    'Wildlife',
    'Religious',
    'Cultural',
    'Food Tours',
    'Heritage',
    'City Tours',
  ];

  final List<String> transportOptions = const [
    'Walking',
    'Bike',
    'Car',
    'Bus',
    'Train',
  ];

  final List<String> availabilityOptions = const [
    'Weekdays',
    'Weekends',
    'Full Time',
    'Part Time',
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
    dobController.dispose();
    licenseController.dispose();
    experienceController.dispose();
    languagesController.dispose();
    locationsController.dispose();
    aboutController.dispose();
    emergencyNameController.dispose();
    emergencyPhoneController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _pickDOB() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: DateTime(1990),
    );

    if (date != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  List<String> _selectedKeys(Map<String, bool> map) {
    return map.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  // ===========================================================================
  // Validation & Submit
  // ===========================================================================
  Future<void> _saveAndNavigate() async {
    if (!_formKey.currentState!.validate()) return;

    // Custom validations for non-form fields
    if (guideType == null) {
      _snack('Please select Guide Type');
      return;
    }

    if (yearsOfExperience == null) {
      _snack('Please select Years of Experience');
      return;
    }

    if (_selectedKeys(languagesKnown).isEmpty) {
      _snack('Please select at least one language you know');
      return;
    }

    if (preferredLanguageForGuiding == null) {
      _snack('Please select Preferred Language for Guiding');
      return;
    }

    if (_selectedKeys(areasOfExpertise).isEmpty) {
      _snack('Please select at least one Area of Expertise');
      return;
    }

    if (locationsController.text.trim().isEmpty) {
      _snack('Please enter Preferred Locations / Destinations');
      return;
    }

    if (_selectedKeys(transportModes).isEmpty) {
      _snack('Please select at least one Mode of Transportation');
      return;
    }

    if (_selectedKeys(availability).isEmpty) {
      _snack('Please select at least one Availability option');
      return;
    }

    if (aboutController.text.trim().isEmpty) {
      _snack('Please tell us about yourself');
      return;
    }

    if (emergencyNameController.text.trim().isEmpty) {
      _snack('Please enter Emergency Contact Name');
      return;
    }

    if (emergencyPhoneController.text.trim().isEmpty) {
      _snack('Please enter Emergency Contact Number');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      if (token == null) {
        _snack('Authentication token not found. Please login again.');
        setState(() => isLoading = false);
        return;
      }

      final payload = {
        'email': widget.email,
        'isEdit': widget.isEditMode,
        'fullName': fullNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'dateOfBirth': dobController.text,
        'gender': gender,
        'guideType': guideType,
        'guideLicenseNumber': licenseController.text.trim(),
        'yearsOfExperience': yearsOfExperience,
        'languagesKnown': _selectedKeys(languagesKnown),
        'preferredLanguageForGuiding': preferredLanguageForGuiding,
        'areasOfExpertise': _selectedKeys(areasOfExpertise),
        'preferredLocations': locationsController.text.trim(),
        'modeOfTransportation': _selectedKeys(transportModes),
        'availability': _selectedKeys(availability),
        'aboutYourself': aboutController.text.trim(),
        'emergencyContactName': emergencyNameController.text.trim(),
        'emergencyContactNumber': emergencyPhoneController.text.trim(),
      };

      final response = await http
          .post(
            Uri.parse('${ApiConstants.authUrl}/api/travel-guide/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await prefs.setString('travelGuideFullName', fullNameController.text.trim());
        await prefs.setBool('completedStep3', true);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RegistrationDone(),
          ),
        );
      } else {
        _snack(data['message'] ?? 'Failed to save travel guide profile');
      }
    } catch (e) {
      _snack('Error saving data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 12,
          color: TemplateTheme.textPrimary,
        ),
        decoration: TemplateTheme.inputDecoration(
          label: required ? '$label *' : label,
          hint: hint,
          suffixIcon: suffixIcon,
        ).copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _buildChipSection({
    required String title,
    required Map<String, bool> items,
    required List<String> options,
    required Function(String, bool) onChanged,
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final selected = items[option] ?? false;
              return FilterChip(
                label: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : TemplateTheme.textPrimary,
                  ),
                ),
                selected: selected,
                selectedColor: TemplateTheme.primary,
                backgroundColor: Colors.white.withOpacity(0.8),
                checkmarkColor: Colors.white,
                onSelected: (v) => onChanged(option, v),
              );
            }).toList(),
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
          'Travel Guide Profile',
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
            title: 'Travel Guide Registration',
            subtitle: 'Complete your Travel Guide profile',
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

                      // Date of Birth
                      _buildTextField(
                        label: 'Date of Birth',
                        controller: dobController,
                        readOnly: true,
                        hint: 'YYYY-MM-DD',
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: TemplateTheme.textMuted,
                        ),
                        customValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Date of Birth is required';
                          }
                          return null;
                        },
                        onTap: _pickDOB,
                      ),

                      // Gender
                      _buildDropdownSection(
                        title: 'Gender',
                        value: gender,
                        options: genderOptions,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),

                      const SizedBox(height: 4),

                      // ======================================================
                      // SECTION 2: Guide Information
                      // ======================================================
                      _buildSectionHeader('Guide Information'),

                      // Guide Type
                      _buildDropdownSection(
                        title: 'Guide Type',
                        value: guideType,
                        options: guideTypeOptions,
                        onChanged: (value) {
                          setState(() {
                            guideType = value;
                          });
                        },
                      ),

                      // Guide License Number (Optional)
                      _buildTextField(
                        label: 'Guide License Number',
                        controller: licenseController,
                        required: false,
                        hint: 'Enter license number (optional)',
                      ),

                      // Years of Experience
                      _buildDropdownSection(
                        title: 'Years of Experience',
                        value: yearsOfExperience,
                        options: experienceOptions,
                        onChanged: (value) {
                          setState(() {
                            yearsOfExperience = value;
                          });
                        },
                      ),

                      // Languages Known
                      _buildChipSection(
                        title: 'Languages Known',
                        items: languagesKnown,
                        options: allLanguages,
                        onChanged: (option, value) {
                          setState(() {
                            languagesKnown[option] = value;
                          });
                        },
                      ),

                      // Preferred Language for Guiding
                      _buildDropdownSection(
                        title: 'Preferred Language for Guiding',
                        value: preferredLanguageForGuiding,
                        options: languageOptions,
                        onChanged: (value) {
                          setState(() {
                            preferredLanguageForGuiding = value;
                          });
                        },
                      ),

                      // Areas of Expertise
                      _buildChipSection(
                        title: 'Areas of Expertise',
                        items: areasOfExpertise,
                        options: expertiseOptions,
                        onChanged: (option, value) {
                          setState(() {
                            areasOfExpertise[option] = value;
                          });
                        },
                      ),

                      // Preferred Locations / Destinations
                      _buildTextField(
                        label: 'Preferred Locations / Destinations',
                        controller: locationsController,
                        hint: 'e.g. Mumbai, Goa, Kerala',
                      ),

                      // Mode of Transportation
                      _buildChipSection(
                        title: 'Mode of Transportation',
                        items: transportModes,
                        options: transportOptions,
                        onChanged: (option, value) {
                          setState(() {
                            transportModes[option] = value;
                          });
                        },
                      ),

                      // Availability
                      _buildChipSection(
                        title: 'Availability',
                        items: availability,
                        options: availabilityOptions,
                        onChanged: (option, value) {
                          setState(() {
                            availability[option] = value;
                          });
                        },
                      ),

                      // About Yourself
                      _buildTextField(
                        label: 'About Yourself',
                        controller: aboutController,
                        hint: 'Tell us about yourself, your experience, and passion for guiding',
                        maxLines: 4,
                      ),

                      const SizedBox(height: 4),

                      // ======================================================
                      // SECTION 3: Emergency Details
                      // ======================================================
                      _buildSectionHeader('Emergency Details'),

                      // Emergency Contact Name
                      _buildTextField(
                        label: 'Emergency Contact Name',
                        controller: emergencyNameController,
                        hint: 'Enter emergency contact name',
                      ),

                      // Emergency Contact Number
                      _buildTextField(
                        label: 'Emergency Contact Number',
                        controller: emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                        hint: 'Enter emergency contact number',
                        customValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Emergency Contact Number is required';
                          }
                          if (value.trim().length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
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

