import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/screens/loginscreen.dart';
import 'package:pina/screens/registration/registration_step2.dart';
import 'package:pina/screens/registration/affiliate_final_profile.dart';
import 'package:pina/screens/registration/hr_agency.dart';
import 'package:pina/screens/trial.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pina/screens/registration/affiliate_library_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class Registration extends StatefulWidget {

  final bool isEditMode;
  final String? editName;
  final String? editEmail;
  final String? editMobile;
  final String? editRole;

  const Registration({
    super.key,
    this.isEditMode = false,
    this.editName,
    this.editEmail,
    this.editMobile,
    this.editRole,
  });

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  static const Duration _requestTimeout = Duration(seconds: 20);
  static const List<String> _affiliateRoleOptions = [
    "Stationary",
    "Photo Copy & Printer",
    "Library",
    "School Uniform",
  ];
  static const String _legacyAffiliateRole = "School Uniform / Bag / Bus";
  static const TextStyle _compactFieldTextStyle = TextStyle(
    fontSize: 12,
    color: TemplateTheme.textPrimary,
  );

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();

  final referralCodeController = TextEditingController();
  final couponCodeController = TextEditingController();

  String accountType = "Personal";
  String? selectedRole;
  String isd = "+91";
  bool agree = false;
  bool isLoading = false;
  
  // Educational Institute flag (only flag, no fields)
  bool isEducationalInstitute = false;

  File? image;

  String? _emailError;
  String? _checkboxError;

  // STEP 1 😤🔥 - ADD THIS METHOD
  bool get _isEditAccountTypeLocked {
    return widget.isEditMode;
  }

  // Helper to check if HR Placement Agency is selected
  bool get _isHrPlacementAgency {
    return accountType == "Company" && selectedRole == "HR Placement Agency";
  }

  // Dynamic roles based on accountType
  List<String> get roles {
    if (accountType == "Affiliate") {
      return _affiliateRoleOptions;
    }
    if (accountType == "Company") {
      return [
        "Educational Institute",
        "HR Placement Agency",
      ];
    }
    return [
      "Student",
      "Teacher",
      "Employee",
      "Professional",
    ];
  }
  
  final isdCodes = ["+91", "+1", "+44", "+61"];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        "30121480557-c265oqagifsq6gl43ittkmnsve8cri16.apps.googleusercontent.com",
    serverClientId:
        "30121480557-ktvjufrttg368vsmro4lc1lgdi760hvb.apps.googleusercontent.com",
  );

  String? _normalizeAffiliateRole(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    if (cleaned == _legacyAffiliateRole) {
      return "School Uniform";
    }

    return cleaned;
  }

  bool _isAffiliateLibraryRole(String? value) {
    return _normalizeAffiliateRole(value) == "Library";
  }

  Widget _buildAffiliateNextScreenForRole(String? role) {
    if (_isAffiliateLibraryRole(role)) {
      return const AffiliateLibraryProfile();
    }

    return const AffiliateFinalProfile();
  }

  Widget _buildAffiliateNextScreen() {
    return _buildAffiliateNextScreenForRole(selectedRole);
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      nameController.text = widget.editName ?? '';
      emailController.text = widget.editEmail ?? '';
      mobileController.text = widget.editMobile?.replaceAll('+91 ', '') ?? '';
      agree = true;
      selectedRole = widget.editRole;
      
      // EXACT FIX 1 😤🔥 - Handle editRole properly
      if (widget.editRole == null || widget.editRole!.isEmpty) {
        _loadCurrentRole();
      } else {
        // Set accountType based on editRole
        if (widget.editRole == "Educational Institute" || widget.editRole == "HR Placement Agency") {
          accountType = "Company";
          if (widget.editRole == "Educational Institute") {
            isEducationalInstitute = true;
          }
        } else if (_affiliateRoleOptions.contains(widget.editRole)) {
          accountType = "Affiliate";
        } else {
          accountType = "Personal";
        }
      }
      
      _loadInstituteFlag();
    }

    emailController.addListener(_clearEmailError);
  }

  Future<void> _loadInstituteFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final isInstitute = prefs.getBool("isEducationalInstitute") ?? false;
    setState(() {
      isEducationalInstitute = isInstitute;
    });
  }

  Future<void> _loadCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    final currentRole = prefs.getString('userRole');
    final normalizedAffiliateRole = _normalizeAffiliateRole(currentRole);
    if (currentRole != null && currentRole.isNotEmpty) {
      setState(() {
        if (currentRole == "Educational Institute" || currentRole == "HR Placement Agency") {
          accountType = "Company";
          selectedRole = currentRole;
          if (currentRole == "Educational Institute") {
            isEducationalInstitute = true;
          }
        } else if (
            _affiliateRoleOptions.contains(normalizedAffiliateRole) ||
            currentRole == _legacyAffiliateRole
        ) {
          accountType = "Affiliate";
          selectedRole = normalizedAffiliateRole;
        } else {
          accountType = "Personal";
          // EXACT FIX 2 😤🔥 - Safe assignment with contains check
          selectedRole = roles.contains(currentRole) ? currentRole : null;
        }
      });
      debugPrint('Current role loaded: $currentRole, accountType: $accountType, selectedRole: $selectedRole');
    }
  }

  @override
  void dispose() {
    emailController.removeListener(_clearEmailError);
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    referralCodeController.dispose();
    couponCodeController.dispose();
    super.dispose();
  }

  void _clearEmailError() {
    if (_emailError != null) {
      setState(() => _emailError = null);
    }
  }

  Map<String, dynamic> _userPayloadFromResponse(Map<String, dynamic> data) {
    final rawUser = data['user'];
    if (rawUser is Map<String, dynamic>) {
      return rawUser;
    }
    if (rawUser is Map) {
      return rawUser.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  String? _resolveUserId(
    Map<String, dynamic> data, {
    Map<String, dynamic>? user,
  }) {
    return SessionService.resolveMongoUserId(
      data,
      user: user ?? _userPayloadFromResponse(data),
    );
  }

  Future<Map<String, String>> _saveSocialRegistrationSession(
    Map<String, dynamic> data, {
    required String fallbackName,
    required String fallbackEmail,
    required String fallbackRole,
  }) async {
    final user = _userPayloadFromResponse(data);
    final String? userId = _resolveUserId(data, user: user);
    final String userName = (user['name'] ?? fallbackName).toString();
    final String userEmail = (user['email'] ?? fallbackEmail).toString();
    final String token = (data['token'] ?? '').toString();
    final String role =
        _normalizeAffiliateRole(
          (user['category'] ?? user['affiliateRole'] ?? fallbackRole).toString(),
        ) ??
        fallbackRole;
    final String userType = (user['userType'] ?? 'free').toString();
    final bool isAffiliateSignup = accountType == "Affiliate";
    bool completedStep2 = false;
    bool completedStep3 = false;

    if (isAffiliateSignup) {
      final rawOnboarding = user['onboarding'] ?? data['onboarding'];
      if (rawOnboarding is Map) {
        completedStep2 = rawOnboarding['libraryProfileCompleted'] == true;
        completedStep3 = rawOnboarding['finalProfileCompleted'] == true;
      } else {
        completedStep2 = !_isAffiliateLibraryRole(role);
      }
    }

    debugPrint(
      "Social registration data - userId: '$userId', name: '$userName', email: '$userEmail', role: '$role'",
    );

    if (userId != null && userId.isNotEmpty) {
      await SessionService.saveSession(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        authToken: token,
        userRole: role,
        userType: userType,
        completedStep1: true,
        completedStep2: isAffiliateSignup ? !completedStep2 : null,
        completedStep3: isAffiliateSignup ? false : null,
      );
    }

    return {
      'userName': userName,
      'userEmail': userEmail,
      'role': role,
    };
  }

  double _compactButtonHeight(BuildContext context) =>
      MediaQuery.of(context).size.height * 0.055;

  InputDecoration _compactInputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TemplateTheme.inputDecoration(
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
    ).copyWith(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      errorStyle: const TextStyle(fontSize: 10, height: 1.1),
      labelStyle: const TextStyle(
        color: TemplateTheme.textMuted,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => image = File(picked.path));
    }
  }

  Future<void> _signUpWithGoogle() async {
    print("🔥 Google button clicked - accountType: $accountType, selectedRole: $selectedRole, agree: $agree");

    if (isLoading) {
      print("🚫 Google blocked - isLoading true");
      return;
    }

    if (accountType == "Personal" && (selectedRole == null || !roles.contains(selectedRole))) {
      print("🚫 Google blocked - role invalid: $selectedRole");
      _snack("Please select role");
      return;
    }
    if (!agree) {
      print("🚫 Google blocked - terms not accepted");
      setState(() {
        _checkboxError = 'You must accept the terms and conditions';
      });
      return;
    }

    if (mobileController.text.trim().isEmpty) {
      _snack("Please enter mobile number");
      return;
    }

    String categoryToSend;
    if (accountType == "Personal") {
      categoryToSend = selectedRole!;
    } else if (accountType == "Affiliate") {
      categoryToSend = selectedRole ?? "Affiliate";
    } else {
      categoryToSend = selectedRole ?? "";
    }
    print("✅ Google validation passed - categoryToSend: $categoryToSend");

    setState(() => isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("Google account selected: ${googleUser?.email ?? 'cancelled'}");
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        _snack("Google authentication failed - no token");
        setState(() => isLoading = false);
        return;
      }

      final response = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/api/auth/google-auth"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "idToken": idToken,
              "category": categoryToSend,
              "mobile": "$isd ${mobileController.text.trim()}",
              "accountType": accountType,
            }),
          )
          .timeout(_requestTimeout);

      print("🔥 Google API status: ${response.statusCode}");
      print("🔥 Google API response: ${response.body}");
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        final session = await _saveSocialRegistrationSession(
          data,
          fallbackName: googleUser.displayName ?? 'Unknown',
          fallbackEmail: googleUser.email,
          fallbackRole: categoryToSend,
        );
        final String userName = session['userName'] ?? 'Unknown';
        final String userEmail = session['userEmail'] ?? googleUser.email;
        final String role = session['role'] ?? categoryToSend;

        _snack("Google sign-up successful! Welcome $userName");
        if (!mounted) return;

        if (accountType == "Affiliate") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => _buildAffiliateNextScreenForRole(role),
            ),
          );
        } else {
          // All non-affiliate users go to RegistrationStep2
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegistrationStep2(
                email: userEmail,
                category: role,
                isEducationalInstitute: isEducationalInstitute,
              ),
            ),
          );
        }
      } else {
        _snack(data["message"] ?? "Google sign-up failed");
      }

      await _googleSignIn.signOut();
    } on TimeoutException {
      _snack("Server timeout. Check backend at ${ApiConstants.authUrl}");
    } on SocketException {
      _snack("Cannot reach server. Check network/backend.");
    } catch (e) {
      print("Google error: $e");
      _snack("Google sign-up error");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> signUpWithFacebook() async {
    print("👉 Facebook button clicked - accountType: $accountType, selectedRole: $selectedRole, agree: $agree");

    if (isLoading) {
      print("🚫 Facebook blocked - isLoading true");
      return;
    }

    if (accountType == "Personal" && (selectedRole == null || !roles.contains(selectedRole))) {
      print("🚫 Facebook blocked - role invalid: $selectedRole");
      _snack("Please select role");
      return;
    }
    if (!agree) {
      print("🚫 Facebook blocked - terms not accepted");
      setState(() {
        _checkboxError = 'You must accept the terms and conditions';
      });
      return;
    }

    if (mobileController.text.trim().isEmpty) {
      _snack("Please enter mobile number");
      return;
    }

    String categoryToSend;
    if (accountType == "Personal") {
      categoryToSend = selectedRole!;
    } else if (accountType == "Affiliate") {
      categoryToSend = selectedRole ?? "Affiliate";
    } else {
      categoryToSend = selectedRole ?? "";
    }
    print("✅ Facebook validation passed - categoryToSend: $categoryToSend");

    setState(() => isLoading = true);

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      print("📊 Facebook Status: ${result.status}");
      print("📊 Facebook Message: ${result.message}");

      if (result.status == LoginStatus.cancelled) {
        _snack("Facebook sign-up cancelled");
        return;
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        print("❌ Facebook login failed before backend call");
        _snack(result.message ?? "Facebook sign-up failed");
        return;
      }

      final userData = await FacebookAuth.instance.getUserData();
      final accessToken = result.accessToken!.token;

      print("✅ Facebook USER DATA: $userData");

      final response = await http
          .post(
            Uri.parse("${ApiConstants.authUrl}/api/auth/facebook-auth"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "accessToken": accessToken,
              "category": categoryToSend,
              "mobile": "$isd ${mobileController.text.trim()}",
              "accountType": accountType,
            }),
          )
          .timeout(_requestTimeout);

      print("🔥 Facebook API status: ${response.statusCode}");
      print("🔥 Facebook API response: ${response.body}");

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        final session = await _saveSocialRegistrationSession(
          data,
          fallbackName: (userData['name'] ?? 'Unknown').toString(),
          fallbackEmail: (userData['email'] ?? 'unknown@facebook.com').toString(),
          fallbackRole: categoryToSend,
        );
        final String userName = session['userName'] ?? 'Unknown';
        final String userEmail =
            session['userEmail'] ??
            (userData['email'] ?? 'unknown@facebook.com').toString();
        final String role = session['role'] ?? categoryToSend;

        _snack("Facebook sign-up successful! Welcome $userName");
        if (!mounted) return;

        if (accountType == "Affiliate") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => _buildAffiliateNextScreenForRole(role),
            ),
          );
        } else {
          // All non-affiliate users go to RegistrationStep2
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegistrationStep2(
                email: userEmail,
                category: role,
                isEducationalInstitute: isEducationalInstitute,
              ),
            ),
          );
        }
      } else {
        print("❌ Backend Error: ${data['message']}");
        _snack(data["message"] ?? "Facebook sign-up failed");
      }
    } on TimeoutException {
      _snack("Server timeout. Check backend at ${ApiConstants.authUrl}");
    } on SocketException {
      _snack("Cannot reach server. Check network/backend.");
    } catch (e) {
      print("💥 Facebook Error: $e");
      _snack("Facebook sign-up error");
    } finally {
      try {
        await FacebookAuth.instance.logOut();
      } catch (logoutError) {
        print("ℹ️ Facebook logout skipped: $logoutError");
      }

      if (mounted) setState(() => isLoading = false);
    }
  }

  void _validateAndProceed(String action) async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isEditMode && !agree) {
      setState(() {
        _checkboxError = 'You must accept the terms and conditions';
      });
      return;
    }

    setState(() => _checkboxError = null);

    final ok = await saveStep1(action);
    if (!ok || !mounted) return;

    if (accountType == "Affiliate") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _buildAffiliateNextScreen(),
        ),
      );
      return;
    }

    if (action == "submit") {
      if (!widget.isEditMode) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    String categoryForNext;
    if (accountType == "Personal") {
      categoryForNext = selectedRole ?? "Student";
    } else if (accountType == "Affiliate") {
      categoryForNext = selectedRole ?? "Affiliate";
    } else {
      categoryForNext = selectedRole ?? "";
    }

    // All non-affiliate users go to RegistrationStep2
    // HR Placement Agency users will be redirected from RegistrationStep2
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "companyName",
      nameController.text.trim(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RegistrationStep2(
          email: emailController.text.trim(),
          category: categoryForNext,
          isEducationalInstitute: isEducationalInstitute,
        ),
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  String? _passwordValidator(String? value) {
    if (widget.isEditMode && (value == null || value.isEmpty)) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<bool> saveStep1(String action) async {
    setState(() => isLoading = true);

    try {
      String? base64Image;
      if (image != null) {
        base64Image = base64Encode(await image!.readAsBytes());
      }

      final String? existingUserId = await SessionService.getUserId();

      Future<void> saveFcmTokenToBackend({required String userId}) async {
        debugPrint('DEBUG PRINT 4: Inside saveFcmTokenToBackend()');

        debugPrint('DEBUG PRINT 4a: Before FirebaseMessaging.instance.getToken()');
        final fcmToken = await FirebaseMessaging.instance.getToken();
        debugPrint('DEBUG PRINT 5: After getToken() - token=${(fcmToken == null || fcmToken.trim().isEmpty) ? 'NULL' : fcmToken}');

        if (fcmToken == null || fcmToken.trim().isEmpty) {
          throw Exception('FCM token not available');
        }

        debugPrint('DEBUG PRINT 6: Before POST /save-token');
        final res = await http
            .post(
              Uri.parse('${ApiConstants.authUrl}/save-token'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'userId': userId.trim().toLowerCase(),
                'fcmToken': fcmToken,
                'platform': 'flutter_mobile',
              }),
            )
            .timeout(_requestTimeout);

        debugPrint(
          'DEBUG PRINT 7: After POST /save-token - statusCode=${res.statusCode} body=${res.body}',
        );

        if (res.statusCode != 200) {
          throw Exception(
            'FCM token save failed status=${res.statusCode} body=${res.body}',
          );
        }

        debugPrint('DEBUG PRINT 10: Before return true (saveFcmTokenToBackend completed)');
      }


      String categoryToSend;
      if (accountType == "Personal") {
        categoryToSend = selectedRole ?? "";
      } else if (accountType == "Affiliate") {
        categoryToSend = _normalizeAffiliateRole(selectedRole) ?? "";
      } else {
        categoryToSend = selectedRole ?? "";
      }

      final payload = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": "$isd ${mobileController.text.trim()}",
        "password": passwordController.text.trim(),
        "profilePicture": base64Image,
        "category": categoryToSend,
        "accountType": accountType == "Personal"
            ? "private"
            : accountType == "Company"
                ? "company"
                : "affiliate",
        "action": action,
        "isEdit": existingUserId != null,
        "referralCode": referralCodeController.text.trim(),
        "couponCode": couponCodeController.text.trim(),
        "termsAccepted": agree,
        "isEducationalInstitute": isEducationalInstitute,
      };

      debugPrint('DEBUG PRINT 1: Before POST /api/registration/step1');
      
      if (existingUserId != null) {
        payload["userId"] = existingUserId;
      }

      debugPrint(
        "[Registration.saveStep1] endpoint=${accountType == "Affiliate" ? "affiliate" : "normal"} "
        "payload=${jsonEncode(payload)}",
      );

      final res = await http
          .post(
            Uri.parse(accountType == "Affiliate"
                ? "${ApiConstants.authUrl}/api/affiliate-registration/step1"
                : "${ApiConstants.authUrl}/api/registration/step1"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout);

      debugPrint(
        'DEBUG PRINT 2: After POST /api/registration/step1 - statusCode=${res.statusCode} body=${res.body}',
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        String roleToSave = categoryToSend;
        if (data['user'] != null && data['user']['category'] != null) {
          roleToSave = data['user']['category'].toString();
        } else if (data['category'] != null) {
          roleToSave = data['category'].toString();
        }
        roleToSave = _normalizeAffiliateRole(roleToSave) ?? roleToSave;

        final user = _userPayloadFromResponse(data);
        final resolvedUserId = _resolveUserId(data, user: user) ?? existingUserId;
        final isAffiliateRegistration = accountType == "Affiliate";
        final needsLibraryStep = isAffiliateRegistration && _isAffiliateLibraryRole(roleToSave);

        if (resolvedUserId != null && resolvedUserId.isNotEmpty) {
          await SessionService.saveSession(
            userId: resolvedUserId,
            userName: user['name']?.toString() ?? nameController.text.trim(),
            userEmail: user['email']?.toString() ?? emailController.text.trim(),
            authToken: data["token"]?.toString(),
            userRole: roleToSave,
            userType: user['userType']?.toString(),
            completedStep1: true,
            completedStep2: isAffiliateRegistration ? !needsLibraryStep : null,
            completedStep3: isAffiliateRegistration ? false : null,
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("isEducationalInstitute", isEducationalInstitute);
        }

        // ✅ FIX: Save FCM token before allowing backend to fire success notification.
        // Backend sends notification inside POST /api/registration/step1 for NEW users,
        // so we must ensure /save-token is persisted first and notification is delayed server-side.
        // Frontend requirement: token fetch + /save-token before triggering client success handling.
        final String userIdForSaveToken = emailController.text.trim().toLowerCase();
        if (userIdForSaveToken.isNotEmpty) {
          try {
            await saveFcmTokenToBackend(userId: userIdForSaveToken);

            // Trigger backend registration-success notification ONLY after token is saved.
            final notifyRes = await http
                .post(
                  Uri.parse('${ApiConstants.authUrl}/api/notifications/registration-success'),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'userId': userIdForSaveToken,
                    'templateCode': widget.isEditMode
                            ? 'PROFILE_UPDATED'
                            : 'REGISTRATION_SUCCESS',
                  }),
                )
                .timeout(_requestTimeout);

            if (notifyRes.statusCode != 200) {
              throw Exception(
                'Registration success notification failed status=${notifyRes.statusCode} body=${notifyRes.body}',
              );
            }
          } catch (e) {
            print('Notification isolation failed (non-blocking): $e');
          }
        }

        _snack(
          data["toastMessage"] ??
              (widget.isEditMode ? "Profile updated successfully" : "Saved"),
        );
        return true;

      } else if (data["toastMessage"]?.toString().toLowerCase().contains("already registered") == true ||
          res.statusCode == 409) {

        setState(() {
          _emailError = "This email is already registered. Please try with another email.";
        });
        return false;
      } else {
        _snack(
          data["toastMessage"] ??
              (widget.isEditMode ? "Failed to update profile" : "Failed"),
        );
        return false;
      }
    } on TimeoutException {
      _snack("Server timeout. Check backend at ${ApiConstants.authUrl}");
      return false;
    } on SocketException {
      _snack("Cannot reach server. Check network/backend.");
      return false;
    } catch (e) {
      print('Error in saveStep1: $e');
      _snack("Server error");
      return false;
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                _buildHeader(),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 420,
                            child: _buildFormCard(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo + Name
        Row(
          children: [
            Image.asset(
              "assets/template/icons/arthum_logo.png",
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              "Arthum AI",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: TemplateTheme.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Multi-Modal Generative AI Platform",
          style: TextStyle(
            fontSize: 12,
            color: TemplateTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Registration",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TemplateTheme.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.52),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                accountType == "Affiliate"
                    ? "Step 1 / 3"
                    : "Step 1 / 4",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    final isCompanyOrAffiliate = accountType == "Company" || accountType == "Affiliate";
    final isCompanyMode = accountType == "Company";

    return Container(
      width: 420,
      padding: const EdgeInsets.all(12),
      decoration: TemplateTheme.glassPanel(
        color: Colors.white,
        opacity: 0.92,
        radius: 24,
        borderColor: Colors.white.withOpacity(0.72),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormContent(isCompanyOrAffiliate, isCompanyMode),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent(bool isCompanyOrAffiliate, bool isCompanyMode) {
    final isLocked = _isEditAccountTypeLocked;
    
    return [
      Text(
        widget.isEditMode ? "Edit your details" : "Create your account",
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: TemplateTheme.textPrimary,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        widget.isEditMode
            ? "Update your account information and continue to the next step."
            : "Complete this first step to set up your Arthum AI profile.",
        style: const TextStyle(
          fontSize: 11,
          height: 1.3,
          color: TemplateTheme.textMuted,
        ),
      ),
      const SizedBox(height: 8),
      _buildProfileImagePicker(),
      const SizedBox(height: 8),
      const Text(
        "Account Type",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: TemplateTheme.textPrimary,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: _toggle("Personal", Icons.person_outline_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _toggle("Company", Icons.business_outlined),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _toggle("Affiliate", Icons.groups_rounded),
          ),
        ],
      ),
      const SizedBox(height: 8),

      TextFormField(
        controller: nameController,
        textInputAction: TextInputAction.next,
        enabled: !isLocked,
        style: _compactFieldTextStyle,
        decoration: _compactInputDecoration(
          label: accountType == "Company"
              ? (_isHrPlacementAgency ? "Agency Name" : (isEducationalInstitute ? "Institute Name" : "Company Name"))
              : accountType == "Affiliate"
                  ? "Affiliate Name"
                  : "Full Name",
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 6),
      
      TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        enabled: !widget.isEditMode,
        style: _compactFieldTextStyle,
        decoration: _compactInputDecoration(
          label: "Email",
          errorText: _emailError,
          suffixIcon: widget.isEditMode
              ? const Icon(
                  Icons.lock_outline_rounded,
                  color: TemplateTheme.textMuted,
                  size: 16,
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        },
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          SizedBox(
            width: 85,
            child: DropdownButtonFormField<String>(
              value: isd,
              isExpanded: true,
              dropdownColor: Colors.white,
              style: _compactFieldTextStyle,
              decoration: _compactInputDecoration(
                label: "Code",
              ),
              items: isdCodes
                  .map(
                    (code) => DropdownMenuItem<String>(
                      value: code,
                      child: Text(
                        code,
                        style: _compactFieldTextStyle,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: widget.isEditMode ? null : (value) {
                if (value != null) {
                  setState(() => isd = value);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextFormField(
              controller: mobileController,
              enabled: !widget.isEditMode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: _compactFieldTextStyle,
              decoration: _compactInputDecoration(
                label: "Mobile Number",
              ),
              validator: (value) {
                if (widget.isEditMode) return null;
                if (value == null || value.isEmpty) {
                  return 'Mobile number is required';
                }
                if (value.length != 10) {
                  return 'Mobile number must be 10 digits';
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: passwordController,
        obscureText: true,
        textInputAction: TextInputAction.done,
        style: _compactFieldTextStyle,
        decoration: _compactInputDecoration(
          label: "Password",
        ),
        validator: _passwordValidator,
      ),
      if (widget.isEditMode) ...[
        const SizedBox(height: 4),
        const Text(
          "Leave the password empty to keep your current password.",
          style: TextStyle(
            fontSize: 10,
            color: TemplateTheme.textMuted,
          ),
        ),
      ],

      // Role dropdown - for Personal, Affiliate, or Company account type
      if (accountType == "Personal" ||
          accountType == "Affiliate" ||
          accountType == "Company") ...[
        const SizedBox(height: 6),
        Builder(
          builder: (context) {
            final uniqueRoles = roles.toSet().toList();
            
            return DropdownButtonFormField<String>(
              value: uniqueRoles.contains(selectedRole) ? selectedRole : null,
              isExpanded: true,
              dropdownColor: Colors.white,
              hint: Text(
                "Select Role",
                style: _compactFieldTextStyle.copyWith(color: TemplateTheme.textMuted),
              ),
              style: _compactFieldTextStyle,
              decoration: _compactInputDecoration(
                label: "Role / Category",
              ),
              items: uniqueRoles.map(
                (role) => DropdownMenuItem<String>(
                  value: role,
                  child: Text(
                    role,
                    style: _compactFieldTextStyle,
                  ),
                ),
              ).toList(),
              onChanged: widget.isEditMode
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          selectedRole = value;
                          if (accountType == "Company") {
                            isEducationalInstitute = value == "Educational Institute";
                          }
                        });
                      }
                    },
              validator: (value) {
                if (widget.isEditMode) {
                  return null;
                }
                if (value == null || value.isEmpty) {
                  return 'Role / Category is required';
                }
                return null;
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          "Referral Code (Optional)",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: TemplateTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: referralCodeController,
          enabled: !widget.isEditMode,
          style: _compactFieldTextStyle,
          decoration: _compactInputDecoration(
            label: "Enter referral code",
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Coupon Code (Optional)",
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: TemplateTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: couponCodeController,
          enabled: !widget.isEditMode,
          style: _compactFieldTextStyle,
          decoration: _compactInputDecoration(
            label: "Enter coupon code",
          ),
        ),
      ],
      
      const SizedBox(height: 8),
      _buildTermsSection(),
      const SizedBox(height: 8),
      _buildActionButtons(),
      if (!widget.isEditMode) ...[
        const SizedBox(height: 8),
        _buildSocialSection(),
      ],
    ];
  }

  Widget _buildTermsSection() {
    final isLocked = _isEditAccountTypeLocked;

    // Build backend PDF URLs from existing ApiConstants.authUrl origin
    final String termsUrl = "${Uri.parse(ApiConstants.authUrl).origin}/docs/TERMS%20AND%20CONDITIONS.pdf";
    final String privacyUrl = "${Uri.parse(ApiConstants.authUrl).origin}/docs/Privacy%20Policy.pdf";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: TemplateTheme.border.withOpacity(0.85),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: agree,
                activeColor: TemplateTheme.accent,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: isLocked
                    ? null
                    : (value) {
                        setState(() {
                          agree = value ?? false;
                          if (_checkboxError != null) {
                            _checkboxError = null;
                          }
                        });
                      },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "I agree to ",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(termsUrl);
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            _snack("Could not open Terms & Conditions");
                          }
                        },
                        child: Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TemplateTheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        " and ",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(privacyUrl);
                          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                            _snack("Could not open Privacy Policy");
                          }
                        },
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TemplateTheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_checkboxError != null && !widget.isEditMode) ...[
          const SizedBox(height: 4),
          Text(
            _checkboxError!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildActionButtons() {
    final buttonHeight = _compactButtonHeight(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _validateAndProceed("submit"),
                  style: TemplateTheme.softButtonStyle(padding: EdgeInsets.zero),
                  child: Text(
                    widget.isEditMode ? "Update" : "Submit",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _validateAndProceed("next"),
                  style: TemplateTheme.secondaryButtonStyle(
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    widget.isEditMode ? "Continue" : "Next",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (isLoading) ...[
          const SizedBox(height: 6),
          const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: TemplateTheme.border.withOpacity(0.9),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "OR SIGN UP WITH",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: TemplateTheme.textMuted,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: TemplateTheme.border.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Disabled for Closed Testing: Google Sign-Up UI entry point
            // GestureDetector(
            //   onTap: isLoading ? null : _signUpWithGoogle,
            //   child: _social("assets/icons/google.png"),
            // ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : signUpWithFacebook,
              child: _social("assets/icons/facebook.png"),
            ),
            const SizedBox(width: 8),
            // Temporarily disabled for Closed Testing:
            // GestureDetector(
            //   onTap: () {
            //     _snack("This feature is coming soon");
            //   },
            //   child: _social("assets/icons/instagram.png"),
            // ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Already have an account?",
              style: TextStyle(
                fontSize: 12,
                color: TemplateTheme.textMuted,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Login",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImagePicker() {
    final isLocked = _isEditAccountTypeLocked;
    
    return Center(
      child: GestureDetector(
        onTap: isLocked ? null : pickImage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [TemplateTheme.primary, TemplateTheme.accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TemplateTheme.primary.withOpacity(0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: image != null ? FileImage(image!) : null,
                    child: image == null
                        ? const Icon(
                            Icons.person_outline_rounded,
                            size: 24,
                            color: TemplateTheme.textMuted,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isLocked ? Colors.grey : TemplateTheme.night,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 12,
                      color: isLocked ? Colors.grey[400] : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Profile Image",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: TemplateTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isLocked ? "Image locked" : "Tap to upload",
              style: TextStyle(
                fontSize: 10,
                color: isLocked ? Colors.grey : TemplateTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggle(String value, IconData icon) {
    final selected = accountType == value;
    final isLocked = _isEditAccountTypeLocked;
    
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                accountType = value;
                
                // EXACT FIX 😤🔥 - Don't reset in edit mode
                if (value != "Company" && !widget.isEditMode) {
                  isEducationalInstitute = false;
                }
                
                // EXACT FIX 😤🔥 - Don't set to null in edit mode
                if (value == "Company") {
                  if (!widget.isEditMode) {
                    selectedRole = null;
                  }
                } 
                // EXACT FIX 3 😤🔥 - Only reset in non-edit mode
                else if (!widget.isEditMode && !roles.contains(selectedRole)) {
                  selectedRole = null;
                }
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? TemplateTheme.primary
              : Colors.white.withOpacity(isLocked ? 0.5 : 0.78),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? TemplateTheme.primary : TemplateTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? TemplateTheme.primary.withOpacity(0.16)
                  : TemplateTheme.night.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : TemplateTheme.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : TemplateTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _social(String asset) {
    return Container(
      height: 38,
      width: 38,
      decoration: TemplateTheme.softCard(
        color: Colors.white.withOpacity(0.94),
        radius: 12,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(asset),
      ),
    );
  }
}