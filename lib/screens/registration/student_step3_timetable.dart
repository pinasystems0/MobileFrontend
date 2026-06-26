import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/student_step4_exam.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class StudentStep3Timetable extends StatefulWidget {
  const StudentStep3Timetable({super.key});

  @override
  State<StudentStep3Timetable> createState() => _StudentStep3TimetableState();
}

class _StudentStep3TimetableState extends State<StudentStep3Timetable> {
  bool isLoading = false;

  String timetableType = "class";
  String selectedDay = "monday";

  final days = [
    "monday",
    "tuesday", 
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday"
  ];

  // ✅ STEP 1: UPDATED LIST with new types
  final timetableTypes = [
    "class",
    "hobby",
    "sports",
    "selfStudy",
    "privateTuition",
    "coachingClass"
  ];
  
  // Nested data structure - timetableType -> day -> list of controllers
  late Map<String, Map<String, List<TextEditingController>>> timetableData;
  
  static const int maxSlots = 15;

  @override
  void initState() {
    super.initState();
    _initializeTimetableData();
  }

  void _initializeTimetableData() {
    timetableData = {};
    
    // Initialize for each timetable type
    for (var type in timetableTypes) {
      timetableData[type] = {};
      
      // Initialize with 3 empty slots for each day
      for (var day in days) {
        timetableData[type]![day] = [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ];
      }
    }
  }

  // ✅ STEP 2: UPDATED slotLabel with new cases
  String slotLabel(int index) {
    switch (timetableType) {
      case "class":
        return "Lecture ${index + 1}";
      case "hobby":
        return "Session ${index + 1}";
      case "sports":
        return "Practice ${index + 1}";
      case "selfStudy":
        return "Study Block ${index + 1}";
      case "privateTuition":
        return "Tuition ${index + 1}";
      case "coachingClass":
        return "Coaching ${index + 1}";
      default:
        return "Slot ${index + 1}";
    }
  }

  // ✅ NEW: Helper function to display nice names
  String displayName(String type) {
    switch (type) {
      case "privateTuition":
        return "Private Tuition";
      case "coachingClass":
        return "Coaching Class";
      case "selfStudy":
        return "Self Study";
      default:
        return type[0].toUpperCase() + type.substring(1);
    }
  }

  void addSlot() {
    // Get current slots for selected timetable type and day
    final currentSlots = timetableData[timetableType]![selectedDay]!;
    
    if (currentSlots.length >= maxSlots) return;

    setState(() {
      currentSlots.add(TextEditingController());
    });
  }

  void removeSlot(int index) {
    setState(() {
      final currentSlots = timetableData[timetableType]![selectedDay]!;
      if (index < currentSlots.length) {
        // Dispose the controller to prevent memory leaks
        currentSlots[index].dispose();
        currentSlots.removeAt(index);
      }
    });
  }

  Future<void> saveTimetable() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await SessionService.getAuthToken();

      if (token == null) {
        _snack("User session missing");
        setState(() => isLoading = false);
        return;
      }

      // Build payload for ALL timetable types
      final Map<String, dynamic> allTimetables = {};
      
      for (var type in timetableTypes) {
        final Map<String, dynamic> typeData = {};
        
        for (var day in days) {
          final Map<String, String> slots = {};
          int slotIndex = 1;
          
          final dayControllers = timetableData[type]![day]!;
          for (var controller in dayControllers) {
            final value = controller.text.trim();
            if (value.isNotEmpty) {
              slots["slot$slotIndex"] = value;
              slotIndex++;
            }
          }
          
          if (slots.isNotEmpty) {
            typeData[day] = slots;
          }
        }
        
        if (typeData.isNotEmpty) {
          allTimetables[type] = typeData;
        }
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/registration/step3/timetable"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "timetableType": timetableType,
          "allTimetables": allTimetables,
        }),
      );

      if (response.statusCode == 200) {
        _snack("Timetable saved");
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentStep4Exam()),
        );
      } else {
        _snack("Failed to save timetable");
      }
    } catch (e) {
      debugPrint("Error saving timetable: $e");
      _snack("Server error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: TemplateTheme.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current slots for display
    final currentSlots = timetableData[timetableType]![selectedDay]!;
    
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
                "Timetable",
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
                      "Step 3 / 4",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentStep4Exam()),
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
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle("Timetable Type"),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text("Class"),
                            selected: timetableType == "class",
                            selectedColor: TemplateTheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timetableType == "class" ? Colors.white : TemplateTheme.textPrimary,
                            ),
                            onSelected: (v) => setState(() {
                              timetableType = "class";
                              selectedDay = "monday";
                            }),
                          ),
                          FilterChip(
                            label: const Text("Hobby"),
                            selected: timetableType == "hobby", 
                            selectedColor: TemplateTheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timetableType == "hobby" ? Colors.white : TemplateTheme.textPrimary,
                            ),
                            onSelected: (v) => setState(() {
                              timetableType = "hobby";
                              selectedDay = "monday";
                            }),
                          ),
                          FilterChip(
                            label: const Text("Sports"),
                            selected: timetableType == "sports",
                            selectedColor: TemplateTheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timetableType == "sports" ? Colors.white : TemplateTheme.textPrimary,
                            ),
                            onSelected: (v) => setState(() {
                              timetableType = "sports";
                              selectedDay = "monday";
                            }),
                          ),
                          FilterChip(
                            label: const Text("Self Study"),
                            selected: timetableType == "selfStudy",
                            selectedColor: TemplateTheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timetableType == "selfStudy" ? Colors.white : TemplateTheme.textPrimary,
                            ),
                            onSelected: (v) => setState(() {
                              timetableType = "selfStudy";
                              selectedDay = "monday";
                            }),
                          ),
                          // ✅ STEP 3: ADDED PRIVATE TUITION CHIP
                          FilterChip(
                            label: const Text("Tuition"),
                            selected: timetableType == "privateTuition",
                            selectedColor: TemplateTheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timetableType == "privateTuition"
                                  ? Colors.white
                                  : TemplateTheme.textPrimary,
                            ),
                            onSelected: (v) => setState(() {
                              timetableType = "privateTuition";
                              selectedDay = "monday";
                            }),
                          ),
                          // ✅ STEP 3: ADDED COACHING CLASS CHIP
                          FilterChip(
                            label: const Text("Coaching"),
                            selected: timetableType == "coachingClass",
                            selectedColor: TemplateTheme.primary,
                            backgroundColor: Colors.white.withOpacity(0.8),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: timetableType == "coachingClass"
                                  ? Colors.white
                                  : TemplateTheme.textPrimary,
                            ),
                            onSelected: (v) => setState(() {
                              timetableType = "coachingClass";
                              selectedDay = "monday";
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _sectionTitle("Select Day"),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: days.map((day) {
                            final isSelected = selectedDay == day;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  day.substring(0, 3).toUpperCase(),
                                ),
                                selected: isSelected,
                                selectedColor: TemplateTheme.primary,
                                backgroundColor: Colors.white.withOpacity(0.8),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : TemplateTheme.textPrimary,
                                ),
                                onSelected: (v) => setState(() => selectedDay = day),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _sectionTitle("${selectedDay.substring(0, 3).toUpperCase()} Schedule"),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          // ✅ FIXED: Using displayName() for clean formatting
                          "📚 ${displayName(timetableType)} Timetable",
                          style: TextStyle(
                            fontSize: 14, 
                            color: TemplateTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        "Add your daily timetable slots below. Up to 15 slots supported.",
                        style: TextStyle(fontSize: 14, color: TemplateTheme.textMuted),
                      ),
                      const SizedBox(height: 12),

                      // Display slots for current timetable type and selected day
                      ...List.generate(
                        currentSlots.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: currentSlots[index],
                                  decoration: TemplateTheme.inputDecoration(
                                    label: slotLabel(index),
                                  ).copyWith(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => removeSlot(index),
                                      tooltip: 'Remove slot',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      if (currentSlots.length < maxSlots)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: addSlot,
                              icon: Icon(Icons.add, color: TemplateTheme.primary),
                              label: Text(
                                "Add ${slotLabel(currentSlots.length)}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: TemplateTheme.primary,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (currentSlots.length >= maxSlots)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TemplateTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Maximum 15 slots reached",
                            style: TextStyle(
                              fontWeight: FontWeight.w500, 
                              color: TemplateTheme.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : saveTimetable,
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
                                  "Save & Continue",
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

                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.15),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Properly dispose all controllers to prevent memory leaks
    for (var type in timetableData.keys) {
      for (var day in timetableData[type]!.keys) {
        for (var controller in timetableData[type]![day]!) {
          controller.dispose();
        }
      }
    }
    super.dispose();
  }
}
