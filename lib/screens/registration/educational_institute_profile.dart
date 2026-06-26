import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:pina/screens/registration/company_ai.dart';

class EducationalInstituteProfile extends StatefulWidget {
  const EducationalInstituteProfile({super.key});

  @override
  State<EducationalInstituteProfile> createState() =>
      _EducationalInstituteProfileState();
}

class _EducationalInstituteProfileState
    extends State<EducationalInstituteProfile> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Basic Details Controllers
  final instituteNameController = TextEditingController();
  final addressController = TextEditingController();
  final instituteEmailController = TextEditingController();
  final contactController = TextEditingController();
  final streamController = TextEditingController();
  final sportsController = TextEditingController();
  final studentsController = TextEditingController();
  final teachersController = TextEditingController();

  // Academic Levels
  final List<String> academicLevels = [
    "Primary",
    "Secondary",
    "Higher",
    "UG",
    "PG",
  ];
  List<String> selectedAcademicLevels = [];

  // Mode of Education
  final List<String> modeOptions = ["Online", "Offline", "Hybrid"];
  String? selectedMode;

  // Toggle between Teacher and Student view
  String selectedTab = "teachers";

  // Dynamic Lists
  List<Map<String, dynamic>> teachersList = [];
  List<Map<String, dynamic>> studentsList = [];

  // Expansion state for forms
  bool _isTeacherFormExpanded = false;
  bool _isStudentFormExpanded = false;

  // Track expanded cards
  Set<int> _expandedTeacherCards = {};
  Set<int> _expandedStudentCards = {};

  // Controllers for Add Forms (NO VALIDATORS)
  final Map<String, TextEditingController> teacherFormControllers = {
    "name": TextEditingController(),
    "email": TextEditingController(),
    "mobile": TextEditingController(),
    "teacherType": TextEditingController(),
    "teachingMode": TextEditingController(),
    "languages": TextEditingController(),
    "state": TextEditingController(),
    "city": TextEditingController(),
    "subjects": TextEditingController(),
    "classes": TextEditingController(),
    "boards": TextEditingController(),
    "experience": TextEditingController(),
  };

  final Map<String, TextEditingController> studentFormControllers = {
    "name": TextEditingController(),
    "email": TextEditingController(),
    "mobile": TextEditingController(),
    "board": TextEditingController(),
    "standard": TextEditingController(),
    "medium": TextEditingController(),
    "school": TextEditingController(),
    "city": TextEditingController(),
    "state": TextEditingController(),
    "dob": TextEditingController(),
    "stream": TextEditingController(),
  };

  @override
  void dispose() {
    instituteNameController.dispose();
    addressController.dispose();
    instituteEmailController.dispose();
    contactController.dispose();
    streamController.dispose();
    sportsController.dispose();
    studentsController.dispose();
    teachersController.dispose();
    for (var controller in teacherFormControllers.values) {
      controller.dispose();
    }
    for (var controller in studentFormControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void addTeacher() {
    final newTeacher = {
      "name": teacherFormControllers["name"]?.text.trim() ?? "",
      "email": teacherFormControllers["email"]?.text.trim() ?? "",
      "mobile": teacherFormControllers["mobile"]?.text.trim() ?? "",
      "teacherType": teacherFormControllers["teacherType"]?.text.trim() ?? "",
      "teachingMode": teacherFormControllers["teachingMode"]?.text.trim() ?? "",
      "languages": teacherFormControllers["languages"]?.text.trim() ?? "",
      "state": teacherFormControllers["state"]?.text.trim() ?? "",
      "city": teacherFormControllers["city"]?.text.trim() ?? "",
      "subjects": teacherFormControllers["subjects"]?.text.trim() ?? "",
      "classes": teacherFormControllers["classes"]?.text.trim() ?? "",
      "boards": teacherFormControllers["boards"]?.text.trim() ?? "",
      "experience": teacherFormControllers["experience"]?.text.trim() ?? "",
    };

    if (newTeacher["name"]!.isEmpty || newTeacher["email"]!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Email are required for Teacher")),
      );
      return;
    }

    setState(() {
      teachersList.add(newTeacher);
    });

    for (var controller in teacherFormControllers.values) {
      controller.clear();
    }

    _isTeacherFormExpanded = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Teacher added successfully")),
    );
  }

  void addStudent() {
    final newStudent = {
      "name": studentFormControllers["name"]?.text.trim() ?? "",
      "email": studentFormControllers["email"]?.text.trim() ?? "",
      "mobile": studentFormControllers["mobile"]?.text.trim() ?? "",
      "board": studentFormControllers["board"]?.text.trim() ?? "",
      "standard": studentFormControllers["standard"]?.text.trim() ?? "",
      "medium": studentFormControllers["medium"]?.text.trim() ?? "",
      "school": studentFormControllers["school"]?.text.trim() ?? "",
      "city": studentFormControllers["city"]?.text.trim() ?? "",
      "state": studentFormControllers["state"]?.text.trim() ?? "",
      "dob": studentFormControllers["dob"]?.text.trim() ?? "",
      "stream": studentFormControllers["stream"]?.text.trim() ?? "",
    };

    if (newStudent["name"]!.isEmpty || newStudent["email"]!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Email are required for Student")),
      );
      return;
    }

    setState(() {
      studentsList.add(newStudent);
    });

    for (var controller in studentFormControllers.values) {
      controller.clear();
    }

    _isStudentFormExpanded = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student added successfully")),
    );
  }

  void deleteTeacher(int index) {
    setState(() {
      teachersList.removeAt(index);
      _expandedTeacherCards.remove(index);
      
      Set<int> shiftedIndices = {};
      for (int oldIndex in _expandedTeacherCards) {
        if (oldIndex > index) {
          shiftedIndices.add(oldIndex - 1);
        } else {
          shiftedIndices.add(oldIndex);
        }
      }
      _expandedTeacherCards.clear();
      _expandedTeacherCards.addAll(shiftedIndices);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Teacher deleted successfully")),
    );
  }

  void deleteStudent(int index) {
    setState(() {
      studentsList.removeAt(index);
      _expandedStudentCards.remove(index);
      
      Set<int> shiftedIndices = {};
      for (int oldIndex in _expandedStudentCards) {
        if (oldIndex > index) {
          shiftedIndices.add(oldIndex - 1);
        } else {
          shiftedIndices.add(oldIndex);
        }
      }
      _expandedStudentCards.clear();
      _expandedStudentCards.addAll(shiftedIndices);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Student deleted successfully")),
    );
  }

  // MAIN INSTITUTE FIELDS WITH VALIDATOR (MANDATORY)
  Widget buildMainTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: TemplateTheme.textPrimary,
          fontSize: 13,
        ),
        decoration: TemplateTheme.inputDecoration(
          label: label,
        ).copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "$label is required";
          }
          return null;
        },
      ),
    );
  }

  // OPTIONAL FIELDS FOR TEACHER/STUDENT (NO VALIDATOR)
  Widget buildOptionalTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: TemplateTheme.textPrimary,
          fontSize: 13,
        ),
        decoration: TemplateTheme.inputDecoration(
          label: label,
        ).copyWith(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget buildAcademicLevelChip(String level) {
    final isSelected = selectedAcademicLevels.contains(level);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAcademicLevels.remove(level);
          } else {
            selectedAcademicLevels.add(level);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TemplateTheme.primary
              : TemplateTheme.card.withOpacity(.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TemplateTheme.primary
                : TemplateTheme.card.withOpacity(.95),
          ),
        ),
        child: Text(
          level,
          style: TextStyle(
            color: isSelected ? Colors.white : TemplateTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildTeacherCard(Map<String, dynamic> teacher, int index) {
    final isExpanded = _expandedTeacherCards.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TemplateTheme.card.withOpacity(0.7),
        border: Border.all(color: TemplateTheme.card.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  teacher["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TemplateTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () => deleteTeacher(index),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Email", teacher["email"]),
          _buildInfoRow("Mobile", teacher["mobile"]),
          _buildInfoRow("Subjects", teacher["subjects"]),

          if (!isExpanded) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedTeacherCards.add(index);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View More",
                    style: TextStyle(
                      color: TemplateTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: TemplateTheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],

          if (isExpanded) ...[
            const SizedBox(height: 8),
            const Divider(color: TemplateTheme.textMuted, height: 1),
            const SizedBox(height: 8),
            _buildInfoRow("Teacher Type", teacher["teacherType"]),
            _buildInfoRow("Teaching Mode", teacher["teachingMode"]),
            _buildInfoRow("Languages", teacher["languages"]),
            _buildInfoRow("State", teacher["state"]),
            _buildInfoRow("City", teacher["city"]),
            _buildInfoRow("Classes", teacher["classes"]),
            _buildInfoRow("Boards", teacher["boards"]),
            _buildInfoRow("Experience", teacher["experience"]),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedTeacherCards.remove(index);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Less",
                    style: TextStyle(
                      color: TemplateTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: TemplateTheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildStudentCard(Map<String, dynamic> student, int index) {
    final isExpanded = _expandedStudentCards.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: TemplateTheme.card.withOpacity(0.7),
        border: Border.all(color: TemplateTheme.card.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  student["name"] ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TemplateTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GestureDetector(
                  onTap: () => deleteStudent(index),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow("Email", student["email"]),
          _buildInfoRow("Mobile", student["mobile"]),
          _buildInfoRow("Board", student["board"]),

          if (!isExpanded) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedStudentCards.add(index);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View More",
                    style: TextStyle(
                      color: TemplateTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: TemplateTheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],

          if (isExpanded) ...[
            const SizedBox(height: 8),
            const Divider(color: TemplateTheme.textMuted, height: 1),
            const SizedBox(height: 8),
            _buildInfoRow("Standard", student["standard"]),
            _buildInfoRow("Medium", student["medium"]),
            _buildInfoRow("School", student["school"]),
            _buildInfoRow("City", student["city"]),
            _buildInfoRow("State", student["state"]),
            _buildInfoRow("DOB", student["dob"]),
            _buildInfoRow("Stream", student["stream"]),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedStudentCards.remove(index);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View Less",
                    style: TextStyle(
                      color: TemplateTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: TemplateTheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TemplateTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: TemplateTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTeacherForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (teachersList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: TemplateTheme.textMuted.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "No teachers added yet",
                  style: TextStyle(
                    color: TemplateTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Tap + Add New Teacher to get started",
                  style: TextStyle(
                    color: TemplateTheme.textMuted.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        Card(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              "+ Add New Teacher",
              style: const TextStyle(
                color: TemplateTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            initiallyExpanded: _isTeacherFormExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isTeacherFormExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildOptionalTextField(label: "Teacher Name", controller: teacherFormControllers["name"]!),
                    buildOptionalTextField(label: "Email", controller: teacherFormControllers["email"]!, keyboardType: TextInputType.emailAddress),
                    buildOptionalTextField(label: "Mobile", controller: teacherFormControllers["mobile"]!, keyboardType: TextInputType.phone),
                    buildOptionalTextField(label: "Teacher Type", controller: teacherFormControllers["teacherType"]!),
                    buildOptionalTextField(label: "Teaching Mode", controller: teacherFormControllers["teachingMode"]!),
                    buildOptionalTextField(label: "Languages (comma separated)", controller: teacherFormControllers["languages"]!),
                    buildOptionalTextField(label: "State", controller: teacherFormControllers["state"]!),
                    buildOptionalTextField(label: "City", controller: teacherFormControllers["city"]!),
                    buildOptionalTextField(label: "Subjects (comma separated)", controller: teacherFormControllers["subjects"]!),
                    buildOptionalTextField(label: "Classes (comma separated)", controller: teacherFormControllers["classes"]!),
                    buildOptionalTextField(label: "Boards (comma separated)", controller: teacherFormControllers["boards"]!),
                    buildOptionalTextField(label: "Experience (years)", controller: teacherFormControllers["experience"]!),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemplateTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: addTeacher,
                        child: const Text(
                          "Save Teacher",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildStudentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (studentsList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.center,
            child: Column(
              children: [
                // FIX 2: Changed Icons.school_outline to Icons.school_outlined
                Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: TemplateTheme.textMuted.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  "No students added yet",
                  style: TextStyle(
                    color: TemplateTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "Tap + Add New Student to get started",
                  style: TextStyle(
                    color: TemplateTheme.textMuted.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        Card(
          margin: EdgeInsets.zero,
          color: Colors.transparent,
          elevation: 0,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text(
              "+ Add New Student",
              style: const TextStyle(
                color: TemplateTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            initiallyExpanded: _isStudentFormExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isStudentFormExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildOptionalTextField(label: "Student Name", controller: studentFormControllers["name"]!),
                    buildOptionalTextField(label: "Email", controller: studentFormControllers["email"]!, keyboardType: TextInputType.emailAddress),
                    buildOptionalTextField(label: "Mobile", controller: studentFormControllers["mobile"]!, keyboardType: TextInputType.phone),
                    buildOptionalTextField(label: "Board", controller: studentFormControllers["board"]!),
                    buildOptionalTextField(label: "Standard", controller: studentFormControllers["standard"]!),
                    buildOptionalTextField(label: "Medium", controller: studentFormControllers["medium"]!),
                    buildOptionalTextField(label: "School", controller: studentFormControllers["school"]!),
                    buildOptionalTextField(label: "City", controller: studentFormControllers["city"]!),
                    buildOptionalTextField(label: "State", controller: studentFormControllers["state"]!),
                    buildOptionalTextField(label: "Date of Birth", controller: studentFormControllers["dob"]!),
                    buildOptionalTextField(label: "Stream", controller: studentFormControllers["stream"]!),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemplateTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: addStudent,
                        child: const Text(
                          "Save Student",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedAcademicLevels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one academic level")),
      );
      return;
    }
    if (selectedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select mode of education")),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final token = await SessionService.getAuthToken();

      final payload = {
        "instituteName": instituteNameController.text.trim(),
        "address": addressController.text.trim(),
        "instituteEmail": instituteEmailController.text.trim(),
        "contact": contactController.text.trim(),
        "academicLevels": selectedAcademicLevels,
        "stream": streamController.text.trim(),
        "sports": sportsController.text.trim(),
        "noOfStudents": studentsController.text.trim(),
        "noOfTeachers": teachersController.text.trim(),
        "modeOfEducation": selectedMode,
        "teachers": teachersList,
        "students": studentsList,
      };

      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/educational-institute/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyAI(email: instituteEmailController.text.trim()),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"] ?? "Failed to save profile")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: TemplateBackdrop(
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Educational Institute",
                style: TextStyle(
                  color: TemplateTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CompanyAI(email: instituteEmailController.text.trim()),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: TemplateTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: TemplateTheme.card.withOpacity(.7),
                        border: Border.all(color: TemplateTheme.card.withOpacity(.8)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Institute Profile",
                            style: TextStyle(
                              color: TemplateTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Complete your institute details to continue registration.",
                            style: TextStyle(
                              color: TemplateTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // MAIN INSTITUTE FIELDS (WITH VALIDATORS - MANDATORY)
                    buildMainTextField(label: "Institute Name", controller: instituteNameController),
                    buildMainTextField(label: "Address", controller: addressController, maxLines: 2),
                    buildMainTextField(label: "Institute Email", controller: instituteEmailController, keyboardType: TextInputType.emailAddress),
                    buildMainTextField(label: "Contact Number", controller: contactController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 6),
                    const Text(
                      "Academic Levels",
                      style: TextStyle(
                        color: TemplateTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(children: academicLevels.map(buildAcademicLevelChip).toList()),
                    const SizedBox(height: 10),
                    buildMainTextField(label: "Stream", controller: streamController),
                    buildMainTextField(label: "Sports", controller: sportsController),
                    buildMainTextField(label: "Number Of Students", controller: studentsController, keyboardType: TextInputType.number),
                    buildMainTextField(label: "Number Of Teachers", controller: teachersController, keyboardType: TextInputType.number),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMode,
                      dropdownColor: TemplateTheme.night,
                      decoration: TemplateTheme.inputDecoration(label: "Mode Of Education").copyWith(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      items: modeOptions.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(
                            mode,
                            style: const TextStyle(
                              color: TemplateTheme.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedMode = value),
                      validator: (value) => value == null ? "Please select mode" : null,
                    ),
                    const SizedBox(height: 16),

                    // Teacher/Student Toggle
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = "teachers"),
                            child: Container(
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedTab == "teachers"
                                    ? TemplateTheme.primary
                                    : TemplateTheme.card.withOpacity(.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Teacher Details",
                                style: TextStyle(
                                  color: selectedTab == "teachers" ? Colors.white : TemplateTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = "students"),
                            child: Container(
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedTab == "students"
                                    ? TemplateTheme.primary
                                    : TemplateTheme.card.withOpacity(.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Student Details",
                                style: TextStyle(
                                  color: selectedTab == "students" ? Colors.white : TemplateTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Cards List with Empty State
                    selectedTab == "teachers"
                        ? Column(
                            children: [
                              if (teachersList.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: teachersList.length,
                                  itemBuilder: (context, index) => buildTeacherCard(teachersList[index], index),
                                ),
                              buildTeacherForm(),
                            ],
                          )
                        : Column(
                            children: [
                              if (studentsList.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: studentsList.length,
                                  itemBuilder: (context, index) => buildStudentCard(studentsList[index], index),
                                ),
                              buildStudentForm(),
                            ],
                          ),

                    const SizedBox(height: 80),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemplateTheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: submitProfile,
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
                                "Continue",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 120),
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