import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'company_ai.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/services/registration_completion_service.dart';
import 'package:pina/screens/constants.dart';

import '../../ui_template/utils/backgroundscreen.dart';
import '../../ui_template/utils/responsive_form_layout.dart';
import '../../ui_template/utils/template_theme.dart';

class HotelsLodgingProfile extends StatefulWidget {
  final String email;

  const HotelsLodgingProfile({
    super.key,
    required this.email,
  });

  @override
  State<HotelsLodgingProfile> createState() => _HotelsLodgingProfileState();
}

class _HotelsLodgingProfileState extends State<HotelsLodgingProfile> {
  // ---------------------------------------------------------------------------
  // Basic Information Controllers
  // ---------------------------------------------------------------------------
  final TextEditingController propertyNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController businessEmailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController propertyAddressController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  // ---------------------------------------------------------------------------
  // Property Information Controllers
  // ---------------------------------------------------------------------------
  final TextEditingController roomsController = TextEditingController();
  final TextEditingController checkInTimeController = TextEditingController();
  final TextEditingController checkOutTimeController = TextEditingController();
  final TextEditingController employeesController = TextEditingController();

  bool isLoading = false;

  // ---------------------------------------------------------------------------
  // Dropdown selections
  // ---------------------------------------------------------------------------
  String? selectedPropertyType;
  String? selectedStarRating;

  // ---------------------------------------------------------------------------
  // Multi-select: Property Amenities
  // ---------------------------------------------------------------------------
  List<String> selectedAmenities = [];

  final List<String> propertyTypeOptions = const [
    'Hotel',
    'Resort',
    'Homestay',
    'Guest House',
    'Hostel',
    'Lodge',
    'Villa',
    'Apartment',
  ];

  final List<String> starRatingOptions = const [
    '1 Star',
    '2 Star',
    '3 Star',
    '4 Star',
    '5 Star',
    'Boutique',
    'Unrated',
  ];

  final List<String> amenityOptions = const [
    'Restaurant',
    'Room Service',
    'Housekeeping',
    'Laundry',
    'Concierge',
    'Parking',
    'Swimming Pool',
    'Gym',
    'Spa',
    'Wi-Fi',
  ];

  // ---------------------------------------------------------------------------
  // Form key for validation
  // ---------------------------------------------------------------------------
  final _formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------
  @override
  void dispose() {
    propertyNameController.dispose();
    contactPersonController.dispose();
    businessEmailController.dispose();
    mobileController.dispose();
    propertyAddressController.dispose();
    websiteController.dispose();
    gstController.dispose();
    roomsController.dispose();
    checkInTimeController.dispose();
    checkOutTimeController.dispose();
    employeesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Toggle helpers
  // ---------------------------------------------------------------------------
  void _toggleSelection(List<String> list, String value) {
    setState(() {
      if (list.contains(value)) {
        list.remove(value);
      } else {
        list.add(value);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Validation & Submit
  // ---------------------------------------------------------------------------
  Future<void> _saveAndNavigate() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPropertyType == null) {
      _showSnackBar('Please select property type');
      return;
    }

    if (selectedStarRating == null) {
      _showSnackBar('Please select star rating');
      return;
    }

    if (selectedAmenities.isEmpty) {
      _showSnackBar('Please select at least one amenity');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // Keep SharedPreferences as backup (keeping existing hotel* keys for backward compatibility)
      await prefs.setString(
          'hotelPropertyName', propertyNameController.text.trim());
      await prefs.setString('hotelPropertyType', selectedPropertyType!);
      await prefs.setString('hotelStarRating', selectedStarRating!);
      await prefs.setStringList('hotelAmenities', selectedAmenities);
      await prefs.setString('hotelRooms', roomsController.text.trim());
      await prefs.setString(
          'hotelEmployees', employeesController.text.trim());
      // New fields saved with property prefix
      await prefs.setString(
          'propertyContactPerson', contactPersonController.text.trim());
      await prefs.setString(
          'propertyBusinessEmail', businessEmailController.text.trim());
      await prefs.setString('propertyMobile', mobileController.text.trim());
      await prefs.setString(
          'propertyAddress', propertyAddressController.text.trim());
      await prefs.setString('propertyWebsite', websiteController.text.trim());
      await prefs.setString('propertyGst', gstController.text.trim());
      await prefs.setString(
          'propertyCheckInTime', checkInTimeController.text.trim());
      await prefs.setString(
          'propertyCheckOutTime', checkOutTimeController.text.trim());

      // ---- POST /api/hotels-lodging/profile (keeping existing endpoint) ----
      final token = await SessionService.getAuthToken();
      if (token == null) {
        _showSnackBar('Authentication token not found. Please login again.');
        setState(() => isLoading = false);
        return;
      }

      final companyName =
          prefs.getString('companyName')?.trim() ?? '';

      final response = await http
          .post(
            Uri.parse('${ApiConstants.authUrl}/api/hotels-lodging/profile'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'companyName': companyName,
              'propertyName': propertyNameController.text.trim(),
              'email': widget.email,
              'contactPerson': contactPersonController.text.trim(),
              'businessEmail': businessEmailController.text.trim(),
              'mobile': mobileController.text.trim(),
              'propertyAddress': propertyAddressController.text.trim(),
              'website': websiteController.text.trim(),
              'gstNumber': gstController.text.trim(),
              'propertyType': selectedPropertyType,
              'starRating': selectedStarRating,
              'amenities': selectedAmenities,
              'numberOfRooms': roomsController.text.trim(),
              'checkInTime': checkInTimeController.text.trim(),
              'checkOutTime': checkOutTimeController.text.trim(),
              'numberOfEmployees': employeesController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Mark registration as completed on the backend
        // The backend assigns the correct balance.
        await RegistrationCompletionService.completeRegistration(
          email: widget.email,
        );

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
            data['message'] ?? 'Failed to save property profile');
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

  // ---------------------------------------------------------------------------
  // Reusable Widgets
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
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
          'Properties & Lodging',
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
            title: 'Property Registration',
            subtitle: 'Complete your Property profile',
            content: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ======================================================
                      // BASIC INFORMATION
                      // ======================================================
                      _buildSectionHeader('Basic Information'),

                      // Property Name
                      _buildTextField(
                        label: 'Property Name',
                        controller: propertyNameController,
                        hint: 'Enter property name',
                      ),

                      // Property Type
                      _buildDropdownSection(
                        title: 'Property Type',
                        value: selectedPropertyType,
                        options: propertyTypeOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedPropertyType = value;
                          });
                        },
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

                      // Property Address
                      _buildTextField(
                        label: 'Property Address',
                        controller: propertyAddressController,
                        hint: 'Enter property address',
                        maxLines: 2,
                      ),

                      // Website
                      _buildTextField(
                        label: 'Website',
                        controller: websiteController,
                        keyboardType: TextInputType.url,
                        required: false,
                        hint: 'Enter website URL (optional)',
                      ),

                      // GST Number
                      _buildTextField(
                        label: 'GST Number',
                        controller: gstController,
                        required: false,
                        hint: 'Enter GST number (optional)',
                      ),

                      const SizedBox(height: 8),

                      // ======================================================
                      // PROPERTY INFORMATION
                      // ======================================================
                      _buildSectionHeader('Property Information'),

                      // Star Rating
                      _buildDropdownSection(
                        title: 'Star Rating',
                        value: selectedStarRating,
                        options: starRatingOptions,
                        onChanged: (value) {
                          setState(() {
                            selectedStarRating = value;
                          });
                        },
                      ),

                      // Number of Rooms
                      _buildTextField(
                        label: 'Number of Rooms',
                        controller: roomsController,
                        keyboardType: TextInputType.number,
                        hint: 'Enter total rooms',
                        required: false,
                      ),

                      // Property Amenities
                      _buildCheckboxSection(
                        title: 'Property Amenities',
                        options: amenityOptions,
                        selectedList: selectedAmenities,
                        onToggle: (value) =>
                            _toggleSelection(selectedAmenities, value),
                      ),

                      // Check-in Time
                      _buildTextField(
                        label: 'Check-in Time',
                        controller: checkInTimeController,
                        hint: 'e.g. 14:00',
                        required: false,
                      ),

                      // Check-out Time
                      _buildTextField(
                        label: 'Check-out Time',
                        controller: checkOutTimeController,
                        hint: 'e.g. 11:00',
                        required: false,
                      ),

                      // Number of Employees
                      _buildTextField(
                        label: 'Number of Employees',
                        controller: employeesController,
                        keyboardType: TextInputType.number,
                        hint: 'Enter total employees',
                        required: false,
                      ),

                      const SizedBox(height: 12),
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

