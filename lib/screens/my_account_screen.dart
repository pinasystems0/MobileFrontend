import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:pina/screens/constants.dart';
import 'package:pina/screens/registration/registration.dart';
import 'package:pina/services/role_service.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool _loading = true;

  final TextEditingController _nameController = TextEditingController();
  String _email = '';
  String _role = '';
  String _mobile = ''; // ✅ ADDED mobile field
  String? _profileImagePath;
  Uint8List? _imageBytes; // ✅ For backend image

  @override
  void initState() {
    super.initState();
    _loadUserFromBackend();
  }

  // ✅ सीधे backend से data load
  Future<void> _loadUserFromBackend() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = await SessionService.getAuthToken();

    if (token == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final res = await http.get(
        Uri.parse("${ApiConstants.authUrl}/api/auth/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        if (data['success'] == true && data['user'] != null) {
          final user = data['user'];
          
          // 👇 PROFILE IMAGE HANDLE - FIXED VERSION
          Uint8List? tempImage;
          
          if (user['profilePicture'] != null &&
              user['profilePicture'].toString().isNotEmpty) {
            try {
              tempImage = base64Decode(user['profilePicture']);
              
              // Save to SharedPreferences for drawer
              await prefs.setString('profileImageBase64', user['profilePicture']);
              print("Profile image saved to SharedPreferences");
            } catch (e) {
              print("Image decode error: $e");
              tempImage = null;
            }
          } else {
            tempImage = null;
          }
          
          // ✅ Get mobile number FIRST
          final mobile = (user['mobile'] ?? '').toString();
          
          // ✅ EXACT FINAL FIX - role INSIDE setState
          final backendRole = (user['category'] ?? '').toString();
          
          // FORCE correct company role and set institute flag
          if (backendRole == "Educational Institute") {
            await prefs.setBool("isEducationalInstitute", true);
          }
          
          // ✅ SINGLE setState - ALL UPDATES TOGETHER including role and mobile
          setState(() {
            _imageBytes = tempImage;
            _role = backendRole; // ✅ MOVED INSIDE setState
            _mobile = mobile;    // ✅ MOVED INSIDE setState
            
            _nameController.text =
                (user['name'] != null && user['name'].toString().isNotEmpty)
                    ? user['name'].toString()
                    : 'User';

            _email =
                (user['email'] != null && user['email'].toString().isNotEmpty)
                    ? user['email'].toString()
                    : '';
          });

          // ✅ Save basic info with CORRECT values (use backendRole, not _role variable)
          await prefs.setString('userName', _nameController.text);
          await prefs.setString('userEmail', _email);
          await prefs.setString('userRole', backendRole); // ✅ Use backendRole directly
          await prefs.setString('category', backendRole); // ✅ Use backendRole directly
          await prefs.setString('userMobile', _mobile);
          
          final userType = user['userType']?.toString();
          if (userType != null && userType.isNotEmpty) {
            await prefs.setString('userType', userType);
          }
        }
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  // ✅ Image picker with backend update
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
        _imageBytes = null; // Clear backend image when picking new one
      });
      
      // Upload to backend
      await _uploadProfileImage(File(image.path));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', image.path);
    }
  }
  
  // ✅ Upload profile image to backend
  Future<void> _uploadProfileImage(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await SessionService.getAuthToken();
    
    if (token == null) return;
    
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse("${ApiConstants.authUrl}/api/auth/update-profile-picture"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "profilePicture": base64Image,
        }),
      );
      
      if (response.statusCode == 200) {
        // Save to SharedPreferences for drawer
        await prefs.setString('profileImageBase64', base64Image);
        _showSnackBar("Profile picture updated");
        await _loadUserFromBackend(); // Reload to get updated image
      } else {
        _showSnackBar("Failed to update profile picture");
      }
    } catch (e) {
      print("Upload error: $e");
      _showSnackBar("Error uploading image");
    }
  }

  // ✅ Refresh function
  Future<void> _refreshProfile() async {
    await _loadUserFromBackend();
  }

  // DELETE ACCOUNT CONFIRMATION DIALOG
  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text(
          "Are you sure you want to delete your account? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    final token = await SessionService.getAuthToken();

    if (token == null) {
      _showSnackBar("No active session found");
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    try {
      final res = await http.delete(
        Uri.parse("${ApiConstants.authUrl}/api/auth/delete-account"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (mounted) Navigator.pop(context);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        await SessionService.clearSession();
        await RoleService.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Registration()),
            (route) => false,
          );
        }
      } else {
        _showSnackBar(data['message'] ?? "Failed to delete account");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar("Network error. Please try again.");
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
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              title: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Image.asset(
      'assets/template/icons/arthum_logo.png',
      height: 28,
      width: 28,
    ),
    const SizedBox(width: 8),
    const Text(
      "My Profile",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: TemplateTheme.textPrimary,
        fontFamily: 'Poppins',
      ),
    ),
  ],
),
              actions: [
                IconButton(
                  onPressed: _refreshProfile,
                  icon: const Icon(Icons.refresh, color: TemplateTheme.textPrimary),
                  tooltip: "Refresh Profile",
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Registration(
                          isEditMode: true,
                          editName: _nameController.text,
                          editEmail: _email,
                          editRole: _role,
                          editMobile: _mobile, // ✅ CRITICAL FIX: Passing mobile now
                        ),
                      ),
                    ).then((_) {
                      _loadUserFromBackend();
                    });
                  },
                  icon: const Icon(Icons.edit, color: TemplateTheme.textPrimary),
                  tooltip: "Edit Profile",
                ),
                IconButton(
                  onPressed: _showDeleteConfirmation,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: "Delete Account",
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Card - Glass Style
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickProfileImage,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          // ✅ FIXED: Show both backend AND locally picked images
                          backgroundImage: _imageBytes != null
                              ? MemoryImage(_imageBytes!)
                              : (_profileImagePath != null
                                  ? FileImage(File(_profileImagePath!)) as ImageProvider
                                  : null),
                          child: (_imageBytes == null && _profileImagePath == null)
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? 'User' : _nameController.text,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: TemplateTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email,
                              style: TextStyle(
                                fontSize: 12,
                                color: TemplateTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // ✅ Verified Account Badge
                            Row(
                              children: const [
                                Icon(Icons.verified,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Verified Account",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Profile Information Card - Glass Style
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Profile Information",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _infoRow("Email Address", _email),
                      const Divider(),
                      _infoRow("Role", _role),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: TemplateTheme.textMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TemplateTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}