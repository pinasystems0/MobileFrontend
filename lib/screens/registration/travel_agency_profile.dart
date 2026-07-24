import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'company_ai.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/screens/constants.dart';

import '../../ui_template/utils/backgroundscreen.dart';
import '../../ui_template/utils/responsive_form_layout.dart';
import '../../ui_template/utils/template_theme.dart';

class TravelAgencyProfile extends StatefulWidget {
  final String email;

  const TravelAgencyProfile({
    super.key,
    required this.email,
  });

  @override
  State<TravelAgencyProfile> createState() => _TravelAgencyProfileState();
}

class _TravelAgencyProfileState extends State<TravelAgencyProfile> {
  // ===========================================================================
  // SECTION 1: Basic Information Controllers
  // ===========================================================================
  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController contactPersonController =
      TextEditingController();
  final TextEditingController businessEmailController =
      TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController officeAddressController =
      TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  // ===========================================================================
  // SECTION 2: Business Information Controllers
  // ===========================================================================
  final TextEditingController softwareNameController =
      TextEditingController();
  final TextEditingController countriesCoveredController =
      TextEditingController();
  final TextEditingController employeesController = TextEditingController();

  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // Radio selections
  // ---------------------------------------------------------------------------
  bool? approvedByIata;
  bool? hasTravelMgmtSoftware;

  // ---------------------------------------------------------------------------
  // Multi-select lists
  // ---------------------------------------------------------------------------
  List<String> selectedModesOfTransport = [];
  List<String> selectedServicesOffered = [];

  // ---------------------------------------------------------------------------
  // Dropdown selection
  // ---------------------------------------------------------------------------
  String? operationsType;

  // ---------------------------------------------------------------------------
  // Options lists
  // ---------------------------------------------------------------------------
  final List<String> transportOptions = const [
    'Flight',
    'Train',
    'Bus',
    'Cruise',
    'Cab / Taxi',
    'Self Drive',
  ];

  final List<String> servicesOptions = const [
    'Flight Booking',
    'Hotel Booking',
    'Holiday Packages',
    'Visa Assistance',
    'Travel Insurance',
    'Corporate Travel',
    'Other',
  ];

  final List<String> operationsOptions = const [
    'Domestic',
    'International',
    'Both',
  ];

  // ===========================================================================
  // Form key
  // ===========================================================================
  final _formKey = GlobalKey<FormState>();

  // ===========================================================================
  // Dispose
  // ===========================================================================
  @override
  void dispose() {
    agencyNameController.dispose();
    registrationNumberController.dispose();
    contactPersonController.dispose();
    businessEmailController.dispose();
    mobileController.dispose();
    officeAddressController.dispose();
    websiteController.dispose();
    gstController.dispose();
    softwareNameController.dispose();
    countriesCoveredController.dispose();
    employeesController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Toggle helpers
  // ===========================================================================
  void _toggleSelection(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  // ===========================================================================
  // Validation & Submit
  // ===========================================================================
  Future<void> _saveAndNavigate() async {
    if (!_formKey.currentState!.validate()) return;

    // Radio validation
    if (approvedByIata == null) {
      _showSnackBar('Please select Approved by IATA');
      return;
    }

    if (selectedModesOfTransport.isEmpty) {
      _showSnackBar('Please select at least one mode of transport');
      return;
    }

    if (hasTravelMgmtSoftware == null) {
      _showSnackBar('Please select Travel Management Software');
      return;
    }

    if (hasTravelMgmtSoftware == true &&
        softwareNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter the software name');
      return;
    }

    if (selectedServicesOffered.isEmpty) {
      _showSnackBar('Please select at least one service offered');
      return;
    }

    if (operationsType == null) {
      _showSnackBar('Please select Domestic / International Operations');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // ---- POST /api/travel-agency/profile ----
      final token = await SessionService.getAuthToken();
      if (token == null) {
        _showSnackBar('Authentication token not found. Please login again.');
        setState(() => isLoading = false);
        return;
      }

      final companyName = prefs.getString('companyName')?.trim() ?? '';

      final response = await http
          .post(
            Uri.parse('${ApiConstants.authUrl}/api/travel-agency/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'companyName': companyName,
              'email': widget.email,
              // Basic Information
              'agencyName': agencyNameController.text.trim(),
              'registrationNumber': registrationNumberController.text.trim(),
              'contactPerson': contactPersonController.text.trim(),
              'businessEmail': businessEmailController.text.trim(),
              'mobile': mobileController.text.trim(),
              'officeAddress': officeAddressController.text.trim(),
              'website': websiteController.text.trim(),
              'gstNumber': gstController.text.trim(),
              // Business Information
              'approvedByIata': approvedByIata,
              'modesOfTransport': selectedModesOfTransport,
              'hasTravelMgmtSoftware': hasTravelMgmtSoftware,
              'softwareName': hasTravelMgmtSoftware == true
                  ? softwareNameController.text.trim()
                  : '',
              'servicesOffered': selectedServicesOffered,
              'operationsType': operationsType,
              'countriesCovered': countriesCoveredController.text.trim(),
              'numberOfEmployees': employeesController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save to local storage as backup
        await prefs.setString(
            'travelAgencyName', agencyNameController.text.trim());
        await prefs.setString(
            'travelRegistrationNo', registrationNumberController.text.trim());
        await prefs.setString(
            'travelContactPerson', contactPersonController.text.trim());
        await prefs.setString(
            'travelBusinessEmail', businessEmailController.text.trim());
        await prefs.setString(
            'travelMobile', mobileController.text.trim());
        await prefs.setString(
            'travelOfficeAddress', officeAddressController.text.trim());
        await prefs.setString(
            'travelWebsite', websiteController.text.trim());
        await prefs.setString(
            'travelGst', gstController.text.trim());
        await prefs.setBool(
            'travelApprovedByIata', approvedByIata ?? false);
        await prefs.setStringList(
            'travelModesOfTransport', selectedModesOfTransport);
        await prefs.setBool(
            'travelHasMgmtSoftware', hasTravelMgmtSoftware ?? false);
        if (hasTravelMgmtSoftware == true) {
          await prefs.setString(
              'travelSoftwareName', softwareNameController.text.trim());
        }
        await prefs.setStringList(
            'travelServicesOffered', selectedServicesOffered);
        await prefs.setString(
            'travelOperationsType', operationsType ?? '');
        await prefs.setString(
            'travelCountriesCovered', countriesCoveredController.text.trim());
        await prefs.setString(
            'travelNumberOfEmployees', employeesController.text.trim());

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyAI(
              email: widget.email,
              isHrPlacementAgency: false,
            ),
          ),
        );
      } else {
        _showSnackBar(
            data['message'] ?? 'Failed to save travel agency profile');
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
    required bool? groupValue,
    required Function(bool?) onChanged,
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
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text(
                    'Yes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                  value: true,
                  groupValue: groupValue,
                  activeColor: TemplateTheme.primary,
                  onChanged: onChanged,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                  value: false,
                  groupValue: groupValue,
                  activeColor: TemplateTheme.primary,
                  onChanged: onChanged,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxSection({
    required String title,
    required List<String> options,
    required List<String> selectedList,
    required Function(String) onToggle,
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: options.map((option) {
              final isSelected = selectedList.contains(option);
              return GestureDetector(
                onTap: () => onToggle(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TemplateTheme.primary
                        : Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? TemplateTheme.primary
                          : TemplateTheme.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? TemplateTheme.primary.withValues(alpha: 0.16)
                            : TemplateTheme.night.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : TemplateTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        option,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : TemplateTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
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
          'Travel Agency',
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
                  builder: (_) => CompanyAI(
                    email: widget.email,
                    isHrPlacementAgency: false,
                  ),
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
            title: 'Travel Agency Registration',
            subtitle: 'Complete your Travel Agency profile',
            content: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // SECTION 1: Basic Information
                      // ======================================================
                      _buildSectionHeader('Basic Information'),

                      // Agency Name
                      _buildTextField(
                        label: 'Agency Name',
                        controller: agencyNameController,
                        hint: 'Enter agency name',
                      ),

                      // Registration Number
                      _buildTextField(
                        label: 'Registration Number',
                        controller: registrationNumberController,
                        hint: 'Enter registration number',
                      ),

                      // Contact Person
                      _buildTextField(
                        label: 'Contact Person',
                        controller: contactPersonController,
                        hint: 'Enter contact person name',
                      ),

                      // Business Email
                      _buildTextField(
                        label: 'Business Email',
                        controller: businessEmailController,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'Enter business email',
                        customValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Business Email is required';
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

                      // Office Address (Multiline)
                      _buildTextField(
                        label: 'Office Address',
                        controller: officeAddressController,
                        hint: 'Enter office address',
                        maxLines: 2,
                      ),

                      // Website (Optional)
                      _buildTextField(
                        label: 'Website',
                        controller: websiteController,
                        keyboardType: TextInputType.url,
                        required: false,
                        hint: 'Enter website URL (optional)',
                      ),

                      // GST Number (Optional)
                      _buildTextField(
                        label: 'GST Number',
                        controller: gstController,
                        required: false,
                        hint: 'Enter GST number (optional)',
                      ),

                      const SizedBox(height: 4),

                      // ======================================================
                      // SECTION 2: Business Information
                      // ======================================================
                      _buildSectionHeader('Business Information'),

                      // Approved by IATA - Radio
                      _buildRadioSection(
                        title: 'Approved by IATA',
                        groupValue: approvedByIata,
                        onChanged: (value) {
                          setState(() {
                            approvedByIata = value;
                          });
                        },
                      ),

                      // Modes of Transport - Multi-select
                      _buildCheckboxSection(
                        title: 'Modes of Transport',
                        options: transportOptions,
                        selectedList: selectedModesOfTransport,
                        onToggle: (value) =>
                            _toggleSelection(selectedModesOfTransport, value),
                      ),

                      // Travel Management Software - Radio
                      _buildRadioSection(
                        title: 'Travel Management Software',
                        groupValue: hasTravelMgmtSoftware,
                        onChanged: (value) {
                          setState(() {
                            hasTravelMgmtSoftware = value;
                            if (value == false) {
                              softwareNameController.clear();
                            }
                          });
                        },
                      ),

                      // Software Name (shown only when Yes is selected)
                      if (hasTravelMgmtSoftware == true)
                        _buildTextField(
                          label: 'Software Name',
                          controller: softwareNameController,
                          hint: 'Enter software name',
                        ),

                      // Services Offered - Multi-select
                      _buildCheckboxSection(
                        title: 'Services Offered',
                        options: servicesOptions,
                        selectedList: selectedServicesOffered,
                        onToggle: (value) =>
                            _toggleSelection(selectedServicesOffered, value),
                      ),

                      // Domestic / International Operations - Dropdown
                      _buildDropdownSection(
                        title: 'Domestic / International Operations',
                        value: operationsType,
                        options: operationsOptions,
                        onChanged: (value) {
                          setState(() {
                            operationsType = value;
                          });
                        },
                      ),

                      // Countries Covered (Multiline)
                      _buildTextField(
                        label: 'Countries Covered',
                        controller: countriesCoveredController,
                        hint: 'Enter countries covered',
                        required: false,
                        maxLines: 2,
                      ),

                      // Number of Employees (Numeric)
                      _buildTextField(
                        label: 'Number of Employees',
                        controller: employeesController,
                        keyboardType: TextInputType.number,
                        hint: 'Enter total employees',
                        customValidator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Number of Employees is required';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                            return 'Enter a valid number';
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

