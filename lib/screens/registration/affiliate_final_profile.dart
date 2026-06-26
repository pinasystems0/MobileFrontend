import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/registration/registration_done.dart';


class AffiliateFinalProfile extends StatefulWidget {
  const AffiliateFinalProfile({super.key});

  @override
  State<AffiliateFinalProfile> createState() => _AffiliateFinalProfileState();
}

class _AffiliateFinalProfileState extends State<AffiliateFinalProfile> {
  static final RegExp _mongoIdRegex =
      RegExp(r'^[a-fA-F0-9]{24}$');
  String? remunerationType;
  bool _isSaving = false;

  Future<void> _saveFinalProfileAndComplete() async {
    if (_isSaving) {
      return;
    }

    try {
      final userEmail = await SessionService.getUserEmail();
      debugPrint('[AffiliateFinalProfile] userEmail=$userEmail');

      if (userEmail == null || userEmail.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User email not found. Please login again.')),
        );
        return;
      }

      final headers = await SessionService.authHeaders(
        includeJsonContentType: true,
      );

      if (!headers.containsKey('Authorization')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User session missing. Please login again.'),
          ),
        );
        return;
      }

      final cleanedCompanies = companyControllers
          .map((c) => c.text.trim())
          .where((v) => v.isNotEmpty)
          .toList();

      if (remunerationType == null || remunerationType!.isEmpty) {
        throw Exception('Please select a remuneration type');
      }

      if (remunerationType == 'Other' &&
          otherController.text.trim().isEmpty) {
        throw Exception('Please enter the remuneration type');
      }

      if (cleanedCompanies.length > 15) {
        throw Exception('Maximum 15 company IDs are allowed');
      }

      final invalidCompanyIds = cleanedCompanies
          .where((value) => !_mongoIdRegex.hasMatch(value))
          .toList();

      if (invalidCompanyIds.isNotEmpty) {
        throw Exception('Please enter valid 24-character company IDs');
      }

      setState(() => _isSaving = true);

      final payload = {
        'email': userEmail.trim().toLowerCase(),
        'remunerationType': remunerationType,
        'otherRemuneration': remunerationType == 'Other' ? otherController.text.trim() : '',
        'linkedCompanyIds': cleanedCompanies,
      };

      debugPrint('[AffiliateFinalProfile] BODY: ${jsonEncode(payload)}');

      final res = await http
          .post(
            Uri.parse(
              '${ApiConstants.authUrl}/api/affiliate-registration/final-profile',
            ),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('[AffiliateFinalProfile] RESPONSE status=${res.statusCode} body=${res.body}');

      final data = jsonDecode(res.body);

      if (!mounted) return;

      if (res.statusCode == 200 && data['success'] == true) {
        await SessionService.saveRegistrationProgress(
          completedStep1: true,
          completedStep2: true,
          completedStep3: true,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const RegistrationDone(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['toastMessage']?.toString() ?? 'Failed to complete affiliate registration',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[AffiliateFinalProfile] ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing registration: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  final TextEditingController otherController = TextEditingController();

  List<TextEditingController> companyControllers = [
    TextEditingController(),
  ];

  @override
  void dispose() {
    otherController.dispose();

    for (var controller in companyControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
  }) {
    return TemplateTheme.inputDecoration(
      label: label,
      hint: hint,
    ).copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _buildRewardOption(String value) {
    final selected = remunerationType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          remunerationType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected
              ? TemplateTheme.primary
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? TemplateTheme.primary : TemplateTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 18,
              color: selected ? Colors.white : TemplateTheme.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : TemplateTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addCompanyField() {
    if (companyControllers.length >= 15) return;

    setState(() {
      companyControllers.add(TextEditingController());
    });
  }

  void _removeCompanyField(int index) {
    if (companyControllers.length == 1) return;

    setState(() {
      companyControllers[index].dispose();
      companyControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ARTHUM AI",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Remuneration / Reward",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Choose how the affiliate earns rewards",
                      style: TextStyle(
                        fontSize: 11,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.52),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      child: const Text(
                        "Final Step",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: TemplateTheme.glassPanel(
                        color: Colors.white,
                        opacity: 0.92,
                        radius: 24,
                        borderColor: Colors.white.withOpacity(0.72),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "How would you like to earn?",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: TemplateTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildRewardOption("Fixed"),
                          const SizedBox(height: 8),
                          _buildRewardOption("Commission"),
                          const SizedBox(height: 8),
                          _buildRewardOption("Other"),
                          // OTHER TEXTBOX
                          if (remunerationType == "Other") ...[
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: otherController,
                              decoration: _inputDecoration(
                                label: "Enter remuneration type",
                                hint: "e.g. Bonus, Incentive",
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),
                          // ✅ COMPANY TITLE CHOTA KARO - fontSize 13 → 12
                          const Text(
                            "Company IDs",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: TemplateTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // ✅ DESCRIPTION TEXT COMPACT - fontSize 11 → 10
                          const Text(
                            "Enter IDs of companies you work with",
                            style: TextStyle(
                              fontSize: 10,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // ✅ DESCRIPTION TEXT COMPACT - fontSize 10 → 9
                          const Text(
                            "Add company user IDs connected with your affiliate account",
                            style: TextStyle(
                              fontSize: 9,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          // COMPANY ID FIELDS
                          ...List.generate(
                            companyControllers.length,
                            (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: companyControllers[index],
                                        decoration: _inputDecoration(
                                          label: "Company User ID",
                                          hint: "e.g. 685ab23d91fa...",
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // ADD BUTTON
                                    if (index == companyControllers.length - 1)
                                      GestureDetector(
                                        onTap: _addCompanyField,
                                        child: Container(
                                          height: 42,
                                          width: 42,
                                          decoration: BoxDecoration(
                                            color: TemplateTheme.primary,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    // REMOVE BUTTON
                                    if (companyControllers.length > 1 && index != 0)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: GestureDetector(
                                          onTap: () {
                                            _removeCompanyField(index);
                                          },
                                          child: Container(
                                            height: 42,
                                            width: 42,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${companyControllers.length}/15 company accounts added",
                            style: const TextStyle(
                              fontSize: 10,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                          // ✅ BUTTON TOP SPACE THODA KAM - SizedBox 20 → 16
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : _saveFinalProfileAndComplete,
                              style: TemplateTheme.primaryButtonStyle(),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Complete Registration",
                                      style: TextStyle(
                                        fontSize: 13,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
