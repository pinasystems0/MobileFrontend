// 📁 affiliate_library_profile.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/affiliate_final_profile.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class AffiliateLibraryProfile extends StatefulWidget {
  const AffiliateLibraryProfile({super.key});

  @override
  State<AffiliateLibraryProfile> createState() =>
      _AffiliateLibraryProfileState();
}


class _AffiliateLibraryProfileState
    extends State<AffiliateLibraryProfile> {
  final _formKey = GlobalKey<FormState>();
  final totalSeatsController = TextEditingController();
  final occupiedSeatsController = TextEditingController();
  final vacantSeatsController = TextEditingController();

  final addressController = TextEditingController();
  final seatCostController = TextEditingController();
  final minimumBookingController = TextEditingController();

  String? selectedBookingHours;
  String? selectedSeatCostType;
  String? selectedMinimumBookingType;

  String? selectedSupportedExam;
  bool _isSaving = false;


  final List<String> bookingHourOptions = [
    "1 Hour",
    "2 Hours",
    "4 Hours",
    "6 Hours",
    "8 Hours",
    "12 Hours",
    "24 Hours",
  ];

  final List<String> seatCostOptions = [
    "Per Hour",
    "Per Day",
    "Per Week",
    "Per Month",
  ];

  final List<String> bookingDurationOptions = [
    "Hours",
    "Days",
    "Weeks",
    "Months",
  ];

  final List<String> examOptions = [
    "JEE Main",
    "JEE Advanced",
    "NEET UG",
    "CUET",
    "NDA",
    "UPSC",
    "SSC CGL",
    "SSC CHSL",
    "Bank PO",
    "Railway",
    "CAT",
    "GATE",
    "CLAT",
    "CA Foundation",
    "State Board",
    "10th Board",
    "12th Board",
  ];



  @override
  void initState() {
    super.initState();

    totalSeatsController.addListener(_calculateVacant);
    occupiedSeatsController.addListener(_calculateVacant);
  }

  void _calculateVacant() {
    final total =
        int.tryParse(totalSeatsController.text.trim()) ?? 0;

    final occupied =
        int.tryParse(occupiedSeatsController.text.trim()) ?? 0;

    final vacant = total - occupied;

    vacantSeatsController.text =
        vacant < 0 ? "0" : vacant.toString();
  }

  @override
  void dispose() {
    totalSeatsController.dispose();
    occupiedSeatsController.dispose();
    vacantSeatsController.dispose();

    addressController.dispose();
    seatCostController.dispose();
    minimumBookingController.dispose();

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
      // ✅ Changed vertical from 10 to 8
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
    );
  }



  Future<void> _saveLibraryProfileAndProceed() async {
    if (_isSaving) {
      return;
    }

    // Student Test Support is REQUIRED
      if (selectedSupportedExam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select student test support')),
        );
        return;
      }

    try {
      final userEmail = await SessionService.getUserEmail();

      debugPrint('[AffiliateLibraryProfile] userEmail=$userEmail');

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

      setState(() => _isSaving = true);

      final totalSeats = int.tryParse(totalSeatsController.text.trim()) ?? 0;
      final occupiedSeats = int.tryParse(occupiedSeatsController.text.trim()) ?? 0;
      final vacantSeats = int.tryParse(vacantSeatsController.text.trim()) ?? 0;

      final bookingHours = selectedBookingHours ?? '';
      final supportedExams =
          selectedSupportedExam == null ? [] : [selectedSupportedExam!];
      final libraryAddress = addressController.text.trim();


      final seatCost = int.tryParse(seatCostController.text.trim()) ?? 0;
      final seatCostType = selectedSeatCostType ?? '';

      final minimumBookingDuration =
          int.tryParse(minimumBookingController.text.trim()) ?? 0;
      final minimumBookingType = selectedMinimumBookingType ?? '';

      if (totalSeats <= 0) {
        throw Exception('Total seats must be greater than 0');
      }

      if (occupiedSeats < 0 || occupiedSeats > totalSeats) {
        throw Exception('Occupied seats must be between 0 and total seats');
      }

      if (bookingHours.isEmpty) {
        throw Exception('Please select booking hours');
      }

      if (libraryAddress.isEmpty) {
        throw Exception('Library address is required');
      }

      if (seatCostType.isEmpty) {
        throw Exception('Please select seat cost type');
      }

      if (minimumBookingDuration <= 0) {
        throw Exception('Minimum booking duration must be greater than 0');
      }

      if (minimumBookingType.isEmpty) {
        throw Exception('Please select minimum booking type');
      }

      final payload = {
        'email': userEmail.trim().toLowerCase(),
        'totalSeats': totalSeats,
        'occupiedSeats': occupiedSeats,
        'vacantSeats': vacantSeats,
        'bookingHours': bookingHours,
        'supportedExams': supportedExams,
        'libraryAddress': libraryAddress,
        'seatCost': seatCost,
        'seatCostType': seatCostType,
        'minimumBookingDuration': minimumBookingDuration,
        'minimumBookingType': minimumBookingType,
      };

      debugPrint('[AffiliateLibraryProfile] BODY: ${jsonEncode(payload)}');

      final res = await http
          .post(
            Uri.parse(
                '${ApiConstants.authUrl}/api/affiliate-registration/library-profile'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      debugPrint(
          '[AffiliateLibraryProfile] RESPONSE status=${res.statusCode} body=${res.body}');

      final data = jsonDecode(res.body);

      if (!mounted) return;

      if (res.statusCode == 200 && data['success'] == true) {
        await SessionService.saveRegistrationProgress(
          completedStep1: true,
          completedStep2: true,
          completedStep3: false,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AffiliateFinalProfile(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['toastMessage']?.toString() ?? 'Failed to save library profile',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[AffiliateLibraryProfile] ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving library profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.transparent,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ARTHUM AI",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 1,
                        color:
                            TemplateTheme
                                .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Library Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            TemplateTheme
                                .textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Add your library information",
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            TemplateTheme
                                .textMuted,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(
                                0.52),
                        borderRadius:
                            BorderRadius.circular(
                                999),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.75),
                        ),
                      ),
                      child: const Text(
                        "Step 2 / 3",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              TemplateTheme
                                  .textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        padding:
                            const EdgeInsets.all(14),
                        decoration:
                            TemplateTheme.glassPanel(
                          color: Colors.white,
                          opacity: 0.92,
                          radius: 24,
                          borderColor: Colors.white
                              .withOpacity(0.72),
                        ),
                        child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: [
                          // SEATS
                          Row(
                            children: [
                              Expanded(
                                child:
                                    TextFormField(
                                  controller:
                                      totalSeatsController,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Total",
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 8),

                              Expanded(
                                child:
                                    TextFormField(
                                  controller:
                                      occupiedSeatsController,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Occupied",
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 8),

                              Expanded(
                                child:
                                    TextFormField(
                                  controller:
                                      vacantSeatsController,
                                  readOnly: true,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Vacant",
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // BOOKING HOURS
                          DropdownButtonFormField<
                              String>(
                            value:
                                selectedBookingHours,
                            dropdownColor:
                                Colors.white,
                            decoration:
                                _inputDecoration(
                              label:
                                  "Booking Hours",
                            ),
                            items:
                                bookingHourOptions
                                    .map(
                                      (e) =>
                                          DropdownMenuItem(
                                        value: e,
                                        child:
                                            Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedBookingHours =
                                    value;
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // ✅ FIX 1: REMOVED double label (REMOVED the extra Text widget)
                          // Only dropdown with label remains
                          DropdownButtonFormField<String>(
                            value: selectedSupportedExam,
                            dropdownColor: Colors.white,
                            decoration: _inputDecoration(
                              label: 'Student Test Support',
                            ),
                            items: examOptions
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      // ✅ FIX 2: DROPDOWN TEXT COMPACT
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSupportedExam = value;
                              });
                            },
                          ),


                          const SizedBox(height: 16),

                          // ADDRESS
                          TextFormField(
                            controller:
                                addressController,
                            maxLines: 2,
                            decoration:
                                _inputDecoration(
                              label:
                                  "Library Address",
                              hint:
                                  "Enter full address",
                            ),
                          ),

                          const SizedBox(height: 10),

                          // SEAT COST
                          const Text(
                            "Seat Cost",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  TemplateTheme
                                      .textPrimary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Expanded(
                                child:
                                    TextFormField(
                                  controller:
                                      seatCostController,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Amount",
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 8),

                              Expanded(
                                child:
                                    DropdownButtonFormField<
                                        String>(
                                  value:
                                      selectedSeatCostType,
                                  dropdownColor:
                                      Colors
                                          .white,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Type",
                                  ),
                                  items:
                                      seatCostOptions
                                          .map(
                                            (e) =>
                                                DropdownMenuItem(
                                              value:
                                                  e,
                                              child:
                                                  Text(
                                                e,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      selectedSeatCostType =
                                          value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // MINIMUM BOOKING
                          const Text(
                            "Minimum Booking Duration",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  TemplateTheme
                                      .textPrimary,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Row(
                            children: [
                              Expanded(
                                child:
                                    TextFormField(
                                  controller:
                                      minimumBookingController,
                                  keyboardType:
                                      TextInputType
                                          .number,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Duration",
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  width: 8),

                              Expanded(
                                child:
                                    DropdownButtonFormField<
                                        String>(
                                  value:
                                      selectedMinimumBookingType,
                                  dropdownColor:
                                      Colors
                                          .white,
                                  decoration:
                                      _inputDecoration(
                                    label:
                                        "Type",
                                  ),
                                  items:
                                      bookingDurationOptions
                                          .map(
                                            (e) =>
                                                DropdownMenuItem(
                                              value:
                                                  e,
                                              child:
                                                  Text(
                                                e,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged:
                                      (value) {
                                    setState(() {
                                      selectedMinimumBookingType =
                                          value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // BUTTON
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : _saveLibraryProfileAndProceed,
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
                                      "Continue",
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
               ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}