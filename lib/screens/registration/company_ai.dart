import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'registration_done.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

// ✅ STEP 2: Class name changed from CompanyStep5AI to CompanyAI
class CompanyAI extends StatefulWidget {
  final String email;
  final bool isHrPlacementAgency;

  // ✅ STEP 3: Constructor name changed
  const CompanyAI({
    super.key,
    required this.email,
    this.isHrPlacementAgency = false,
  });


  // ✅ STEP 4: State class name changed
  @override
  State<CompanyAI> createState() => _CompanyAIState();
}

// ✅ STEP 4: State class name changed
class _CompanyAIState extends State<CompanyAI> {
  bool? usingAI;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModels = prefs.getStringList('company_ai_models') ?? [];
    setState(() {
      usingAI = prefs.getBool('company_using_ai');
      models.updateAll((key, value) => savedModels.contains(key));
      whyCtrl.text = prefs.getString('company_ai_reason') ?? '';
      helpCtrl.text = prefs.getString('company_ai_help') ?? '';
    });
  }

  void _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('registrationCompleted', true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationDone()),
      (route) => false,
    );
  }

  final Map<String, bool> models = {
    "ChatGPT": false,
    "Google Gemini": false,
    "Azure OpenAI": false,
    "Oracle Cloud": false,
    "Perplexity": false,
    "Meta (LLaMA)": false,
    "Amazon Bedrock": false,
    "DeepSeek": false,
    "Other": false,
  };

  final whyCtrl = TextEditingController();
  final helpCtrl = TextEditingController();

  Future<void> _submit() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      if (token == null) {
        _showSnackBar('Authentication token not found. Please login again.');
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final selectedModels = models.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      // ──────────────────────────────────────────────────────────────────────
      // Read HR Agency profile data from SharedPreferences (mirroring
      // the existing save pattern in HrAgencyProfile).
      // ──────────────────────────────────────────────────────────────────────
      final String? hrNumberOfEmployees =
          prefs.getString('hrNumberOfEmployees');
      final List<String> hrActivities =
          prefs.getStringList('hrActivities') ?? [];
      final List<String> hrIndustries =
          prefs.getStringList('hrIndustries') ?? [];
      final List<String> hrOperations =
          prefs.getStringList('hrOperations') ?? [];
      final List<String> hrCountries =
          prefs.getStringList('hrCountries') ?? [];
      final List<String> hrHiringTypes =
          prefs.getStringList('hrHiringTypes') ?? [];

      final bool hasHrData =
          hrNumberOfEmployees != null && hrNumberOfEmployees.isNotEmpty;

      // ──────────────────────────────────────────────────────────────────────
      // Read Travel Agency profile data from SharedPreferences (mirroring
      // the save pattern in TravelAgencyProfile).
      // ──────────────────────────────────────────────────────────────────────
      final String? travelAgencyName =
          prefs.getString('travelAgencyName');
      final String? travelRegistrationNo =
          prefs.getString('travelRegistrationNo');
      final String? travelContactPerson =
          prefs.getString('travelContactPerson');
      final String? travelBusinessEmail =
          prefs.getString('travelBusinessEmail');
      final String? travelMobile =
          prefs.getString('travelMobile');
      final String? travelOfficeAddress =
          prefs.getString('travelOfficeAddress');
      final String? travelWebsite =
          prefs.getString('travelWebsite');
      final String? travelGst =
          prefs.getString('travelGst');
      final bool? travelApprovedByIata =
          prefs.getBool('travelApprovedByIata');
      final List<String> travelModesOfTransport =
          prefs.getStringList('travelModesOfTransport') ?? [];
      final bool? travelHasMgmtSoftware =
          prefs.getBool('travelHasMgmtSoftware');
      final String? travelSoftwareName =
          prefs.getString('travelSoftwareName');
      final List<String> travelServicesOffered =
          prefs.getStringList('travelServicesOffered') ?? [];
      final String? travelOperationsType =
          prefs.getString('travelOperationsType');
      final String? travelCountriesCovered =
          prefs.getString('travelCountriesCovered');
      final String? travelNumberOfEmployees =
          prefs.getString('travelNumberOfEmployees');

      final bool hasTravelData =
          travelAgencyName != null && travelAgencyName.isNotEmpty;

      // ──────────────────────────────────────────────────────────────────────
      // Read Hotels & Lodging profile data from SharedPreferences (mirroring
      // the save pattern in HotelsLodgingProfile).
      // ──────────────────────────────────────────────────────────────────────
      final String? hotelPropertyName =
          prefs.getString('hotelPropertyName');
      final String? hotelPropertyType =
          prefs.getString('hotelPropertyType');
      final String? hotelStarRating =
          prefs.getString('hotelStarRating');
      final List<String> hotelAmenities =
          prefs.getStringList('hotelAmenities') ?? [];
      final String? hotelRooms =
          prefs.getString('hotelRooms');
      final String? hotelEmployees =
          prefs.getString('hotelEmployees');
      final String? hotelContactPerson =
          prefs.getString('propertyContactPerson');
      final String? hotelBusinessEmail =
          prefs.getString('propertyBusinessEmail');
      final String? hotelMobile =
          prefs.getString('propertyMobile');
      final String? hotelAddress =
          prefs.getString('propertyAddress');
      final String? hotelWebsite =
          prefs.getString('propertyWebsite');
      final String? hotelGst =
          prefs.getString('propertyGst');
      final String? hotelCheckInTime =
          prefs.getString('propertyCheckInTime');
      final String? hotelCheckOutTime =
          prefs.getString('propertyCheckOutTime');

      final bool hasHotelsData =
          hotelPropertyName != null && hotelPropertyName.isNotEmpty;

      print('Starting API call for AI preferences');

      // ──────────────────────────────────────────────────────────────────────
      // Build the request body starting with AI preferences, then merge
      // profile data for any company type that was completed.
      // ──────────────────────────────────────────────────────────────────────
      final Map<String, dynamic> requestBody = {
        'usingGenerativeAI': usingAI ?? false,
        'aiModelsUsed': selectedModels,
        'aiUsageReason': whyCtrl.text,
        'aiHelpExpectation': helpCtrl.text,
      };

      // Include HR Agency profile data if the user completed that flow
      if (hasHrData) {
        requestBody['hrAgencyProfile'] = {
          'numberOfEmployees': hrNumberOfEmployees,
          'activities': hrActivities,
          'industries': hrIndustries,
          'operations': hrOperations,
          'countries': hrCountries,
          'hiringTypes': hrHiringTypes,
        };
      }

      // Include Travel Agency profile data if the user completed that flow
      if (hasTravelData) {
        requestBody['travelAgencyProfile'] = {
          'agencyName': travelAgencyName,
          'registrationNumber': travelRegistrationNo,
          'contactPerson': travelContactPerson,
          'businessEmail': travelBusinessEmail,
          'mobile': travelMobile,
          'officeAddress': travelOfficeAddress,
          'website': travelWebsite,
          'gstNumber': travelGst,
          'approvedByIata': travelApprovedByIata,
          'modesOfTransport': travelModesOfTransport,
          'hasTravelMgmtSoftware': travelHasMgmtSoftware,
          'softwareName':
              travelHasMgmtSoftware == true ? (travelSoftwareName ?? '') : '',
          'servicesOffered': travelServicesOffered,
          'operationsType': travelOperationsType,
          'countriesCovered': travelCountriesCovered,
          'numberOfEmployees': travelNumberOfEmployees,
        };
      }

      // Include Hotels & Lodging profile data if the user completed that flow
      if (hasHotelsData) {
        requestBody['hotelsLodgingProfile'] = {
          'propertyName': hotelPropertyName,
          'propertyType': hotelPropertyType,
          'starRating': hotelStarRating,
          'amenities': hotelAmenities,
          'numberOfRooms': hotelRooms,
          'numberOfEmployees': hotelEmployees,
          'contactPerson': hotelContactPerson,
          'businessEmail': hotelBusinessEmail,
          'mobile': hotelMobile,
          'propertyAddress': hotelAddress,
          'website': hotelWebsite,
          'gstNumber': hotelGst,
          'checkInTime': hotelCheckInTime,
          'checkOutTime': hotelCheckOutTime,
        };
      }

// ✅ STEP 6: API endpoint (keeping as is for now - can be renamed later)
      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/company-ai/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      print('API call completed for AI preferences');

      if (response.statusCode == 200 && data['success'] == true) {
        // Save to local storage as backup
        await prefs.setBool('completedStep5', true);
        await prefs.setBool('registrationCompleted', true);
        await prefs.setBool('company_using_ai', usingAI ?? false);
        await prefs.setStringList('company_ai_models', selectedModels);
        await prefs.setString('company_ai_reason', whyCtrl.text);
        await prefs.setString('company_ai_help', helpCtrl.text);

        _showSnackBar('Registration completed successfully!');

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationDone()),
          (route) => false,
        );
      } else {
        _showSnackBar(data['message'] ?? 'Failed to complete registration');
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar('Network error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
                "AI Usage",
                // ✅ CHANGED: fontSize 18 → 15
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              actions: [
                // ✅ STEP 5: Changed from "Step 5 / 5" to "AI Preferences"
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: Text(
                      "AI Preferences",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
            // ✅ CHANGED: Body padding all(16) → symmetric(14, 10)
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              child: ListView(
                children: [
                  const Text(
                    "Generative AI Usage",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                  // ✅ CHANGED: SizedBox height 20 → 14
                  const SizedBox(height: 14),

                  // ✅ ADDED: dense + compact + zero padding to RadioListTile
                  RadioListTile<bool>(
                    title: const Text(
                      "Yes",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    value: true,
                    groupValue: usingAI,
                    activeColor: TemplateTheme.primary,
                    onChanged: (v) => setState(() => usingAI = v),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile<bool>(
                    title: const Text(
                      "No",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    value: false,
                    groupValue: usingAI,
                    activeColor: TemplateTheme.primary,
                    onChanged: (v) => setState(() => usingAI = v),
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (usingAI == true) ...[
                    const Divider(color: TemplateTheme.textMuted),
                    const SizedBox(height: 8),
                    // ✅ ADDED: dense + compact + zero padding to CheckboxListTile
                    ...models.keys.map(
                      (k) => CheckboxListTile(
                        title: Text(
                          k,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: TemplateTheme.textPrimary,
                          ),
                        ),
                        value: models[k],
                        activeColor: TemplateTheme.primary,
                        onChanged: (v) => setState(() => models[k] = v!),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: whyCtrl,
                      maxLength: 1000,
                      decoration: TemplateTheme.inputDecoration(
                        label: "Why are you using Generative AI?",
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: helpCtrl,
                      maxLength: 1000,
                      decoration: TemplateTheme.inputDecoration(
                        label: "How can we help you?",
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                  ],

                  // ✅ CHANGED: SizedBox height 20 → 14
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: (usingAI == null || _isLoading) ? null : _submit,
                      style: TemplateTheme.primaryButtonStyle(),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  // ✅ CHANGED: SizedBox height 20 → 14
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}