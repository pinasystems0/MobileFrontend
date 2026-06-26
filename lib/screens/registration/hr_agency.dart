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

class HrAgencyProfile extends StatefulWidget {
  final String email;

  const HrAgencyProfile({
    super.key,
    required this.email,
  });

  @override
  State<HrAgencyProfile> createState() => _HrAgencyProfileState();
}

class _HrAgencyProfileState extends State<HrAgencyProfile> {
  final TextEditingController employeeController = TextEditingController();
  bool isLoading = false;

  // Multi-select lists
  List<String> selectedActivities = [];
  List<String> selectedIndustries = [];
  List<String> selectedOperations = [];
  List<String> selectedCountries = [];
  List<String> selectedHiringTypes = [];

  // Options
  final List<String> hrActivityOptions = const [
    'Payroll',
    'Recruitment',
    'Background Verification',
    'Head Hunting',
    'HR Advisory',
    'Labour Law',
    'Immigration',
  ];

  final List<String> hrIndustryOptions = const [
    'IT',
    'ITES/BPO',
    'Manufacturing',
    'Healthcare',
    'Mining',
  ];

  final List<String> hrOperationOptions = const [
    'Domestic',
    'International',
  ];

  final List<String> hrCountryOptions = const [
    'USA',
    'Australia',
    'Canada',
    'United Kingdom',
    'Germany',
    'Singapore',
    'UAE',
    'India',
  ];

  final List<String> hrHiringTypeOptions = const [
    'Fresher',
    'Lateral Hiring',
  ];

  @override
  void dispose() {
    employeeController.dispose();
    super.dispose();
  }

  void _toggleSelection(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  void _toggleOperations(String value) {
    setState(() {
      if (selectedOperations.contains(value)) {
        selectedOperations.remove(value);
        // If International is deselected, clear countries
        if (value == 'International') {
          selectedCountries.clear();
        }
      } else {
        selectedOperations.add(value);
      }
    });
  }

  Future<void> _saveAndNavigate() async {
    // Validation
    if (employeeController.text.trim().isEmpty) {
      _showSnackBar('Please enter number of employees');
      return;
    }

    if (selectedActivities.isEmpty) {
      _showSnackBar('Please select at least one HR activity');
      return;
    }

    if (selectedIndustries.isEmpty) {
      _showSnackBar('Please select at least one industry');
      return;
    }

    if (selectedOperations.isEmpty) {
      _showSnackBar('Please select at least one operation type');
      return;
    }

    if (selectedOperations.contains('International') && selectedCountries.isEmpty) {
      _showSnackBar('Please select at least one country for international operations');
      return;
    }

    if (selectedHiringTypes.isEmpty) {
      _showSnackBar('Please select at least one hiring type');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Keep SharedPreferences as backup
      await prefs.setString('hrNumberOfEmployees', employeeController.text.trim());
      await prefs.setStringList('hrActivities', selectedActivities);
      await prefs.setStringList('hrIndustries', selectedIndustries);
      await prefs.setStringList('hrOperations', selectedOperations);
      await prefs.setStringList('hrCountries', selectedCountries);
      await prefs.setStringList('hrHiringTypes', selectedHiringTypes);

      // ---- POST /api/hr-agency/profile BEFORE navigating ----
      final token = await SessionService.getAuthToken();
      if (token == null) {
        _showSnackBar('Authentication token not found. Please login again.');
        return;
      }

      final companyName = prefs.getString('companyName')?.trim() ?? '';

      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/hr-agency/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'companyName': companyName,
          'email': widget.email,
          'mobile': '',
          'numberOfEmployees': employeeController.text.trim(),
          'activities': selectedActivities,
          'industries': selectedIndustries,
          'operations': selectedOperations,
          'countries': selectedCountries,
          'hiringTypes': selectedHiringTypes,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompanyAI(
              email: widget.email,
              isHrPlacementAgency: true,
            ),
          ),
        );
      } else {
        _showSnackBar(data['message'] ?? 'Failed to save HR agency profile');
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

  Widget _buildCheckboxSection({
    required String title,
    required List<String> options,
    required List<String> selectedList,
    required Function(String) onToggle,
    bool required = true,
  }) {
    return Column(
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
        const SizedBox(height: 8),
      ],
    );
  }

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
          'HR / Placement Agency',
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
                    isHrPlacementAgency: true,
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
            title: "HR / Placement Agency Details",
            subtitle: "Complete your HR / Placement Agency profile",
            content: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number of Employees
                  TextFormField(
                    controller: employeeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TemplateTheme.textPrimary,
                    ),
                    decoration: TemplateTheme.inputDecoration(
                      label: 'Number of Employees *',
                      hint: 'Enter total employees',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Activities
                  _buildCheckboxSection(
                    title: 'Activities',
                    options: hrActivityOptions,
                    selectedList: selectedActivities,
                    onToggle: (value) => _toggleSelection(selectedActivities, value),
                  ),

                  // Industries
                  _buildCheckboxSection(
                    title: 'Industries',
                    options: hrIndustryOptions,
                    selectedList: selectedIndustries,
                    onToggle: (value) => _toggleSelection(selectedIndustries, value),
                  ),

                  // Operations
                  _buildCheckboxSection(
                    title: 'Operations',
                    options: hrOperationOptions,
                    selectedList: selectedOperations,
                    onToggle: _toggleOperations,
                  ),

                  // Countries (only if International is selected)
                  if (selectedOperations.contains('International'))
                    _buildCheckboxSection(
                      title: 'Countries',
                      options: hrCountryOptions,
                      selectedList: selectedCountries,
                      onToggle: (value) => _toggleSelection(selectedCountries, value),
                    ),

                  // Hiring Types
                  _buildCheckboxSection(
                    title: 'Hiring Types',
                    options: hrHiringTypeOptions,
                    selectedList: selectedHiringTypes,
                    onToggle: (value) => _toggleSelection(selectedHiringTypes, value),
                  ),
                ],
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