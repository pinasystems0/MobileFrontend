import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pina/screens/ai_checking_screen.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/conversion/shared/conversion_router.dart';
import 'package:pina/screens/registration/registration.dart';
import 'package:pina/screens/registration/affiliate_library_profile.dart';
import 'package:pina/screens/registration/affiliate_final_profile.dart';
import 'package:pina/screens/trial.dart';
import 'package:pina/services/session_service.dart';
import 'package:pina/ui_template/utils/template_layout.dart';
import 'package:pina/ui_template/utils/template_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/role_service.dart';

class LoginScreen extends StatefulWidget {
  final bool redirectToDeepfake;

  const LoginScreen({
    super.key,
    this.redirectToDeepfake = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId:
        "30121480557-c265oqagifsq6gl43ittkmnsve8cri16.apps.googleusercontent.com",
    serverClientId:
        "30121480557-ktvjufrttg368vsmro4lc1lgdi760hvb.apps.googleusercontent.com",
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ===================== SAVE SESSION =====================
  Future<void> _saveUserSession(
    String userId,
    String name,
    String email,
    String token,
    String role,
    String userType, {
    bool completedStep1 = true,
    bool completedStep2 = true,
    bool completedStep3 = true,
  }
  ) async {
    await SessionService.saveSession(
      userId: userId,
      userName: name,
      userEmail: email,
      authToken: token,
      userRole: role,
      userType: userType,
      completedStep1: completedStep1,
      completedStep2: completedStep2,
      completedStep3: completedStep3,
    );
  }

  bool _isAffiliateRole(String? role) {
    return const {
      'Library',
      'Stationary',
      'Photo Copy & Printer',
      'School Uniform',
      'School Uniform / Bag / Bus',
    }.contains(role);
  }

  Map<String, bool> _resolveOnboardingProgress(
    Map<String, dynamic> user, {
    Map<String, dynamic>? data,
  }
  ) {
    final onboarding = user['onboarding'] ?? data?['onboarding'];
    if (onboarding is Map) {
      final step1 = onboarding['step1Completed'] == true;
      final step2 =
          onboarding['libraryProfileCompleted'] == true;
      final step3 =
          onboarding['finalProfileCompleted'] == true;

      return {
        'completedStep1': step1,
        'completedStep2': step2,
        'completedStep3': step3,
      };
    }

    return const {
      'completedStep1': true,
      'completedStep2': true,
      'completedStep3': true,
    };
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

  String? _resolveUserId(Map<String, dynamic> data) {
    return SessionService.resolveMongoUserId(
      data,
      user: _userPayloadFromResponse(data),
    );
  }

  // ===================== REDIRECT AFTER LOGIN =====================
  Future<void> _redirectAfterLogin({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    if (widget.redirectToDeepfake == true) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => AiCheckingScreen(userId: userId),
        ),
        (route) => false,
      );
      return;
    }


    final prefs = await SharedPreferences.getInstance();
    final String? role = await SessionService.getUserRole();
    final bool completedStep1 =
        prefs.getBool('completedStep1') ?? false;
    final bool completedStep2 =
        prefs.getBool('completedStep2') ?? false;
    final bool completedStep3 =
        prefs.getBool('completedStep3') ?? false;

    if (_isAffiliateRole(role)) {
      if (!completedStep1) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Registration(),
          ),
        );
        return;
      }

      if (!completedStep2 && role == 'Library') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AffiliateLibraryProfile(),
          ),
        );
        return;
      }

      if (!completedStep3) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AffiliateFinalProfile(),
          ),
        );
        return;
      }
    }

    final String? feature = prefs.getString("postLoginFeature");

    if (feature != null) {
      await prefs.remove("postLoginFeature");

      final conversionScreen = buildConversionScreen(
        optionTitle: feature,
        userId: userId.toString(),
        userEmail: userEmail,
      );

      if (conversionScreen != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => conversionScreen),
        );
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Trial(
            userEmail: userEmail,
            userName: userName,
          ),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Trial(
            userEmail: userEmail,
            userName: userName,
          ),
        ),
      );
    }
  }

  // ===================== MANUAL LOGIN =====================
  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage("Enter email & password");
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("${ApiConstants.authUrl}/api/auth/login");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(_requestTimeout);

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        final user = _userPayloadFromResponse(data);
        final String userName = (user['name'] ?? '').toString();
        final String userEmail = (user['email'] ?? '').toString();
        final String userId = _resolveUserId(data) ?? '';
        final String token = data['token'];
        final String role = data['user']['category'] ?? 'Student';
        final String userType = (user['userType'] ?? 'free').toString();
        final onboardingProgress =
            _resolveOnboardingProgress(
              user,
              data: data,
            );

        if (userId.isEmpty || token.isEmpty) {
          showMessage("Login response was incomplete");
          return;
        }

        await _saveUserSession(
          userId,
          userName,
          userEmail,
          token,
          role,
          userType,
          completedStep1:
              onboardingProgress['completedStep1']!,
          completedStep2:
              onboardingProgress['completedStep2']!,
          completedStep3:
              onboardingProgress['completedStep3']!,
        );

        await RoleService.init();


        await _redirectAfterLogin(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        );
      } else {
        showMessage(data["toastMessage"] ?? "Invalid credentials");
      }
    } on TimeoutException {
      showMessage("Server timeout. Check backend at ${ApiConstants.authUrl}");
    } on SocketException {
      showMessage(
        "Cannot reach server at ${ApiConstants.authUrl}. Check network/backend/firewall.",
      );
    } catch (e) {
      showMessage("Server error");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ===================== GOOGLE LOGIN =====================
  Future<void> signInWithGoogle() async {
    setState(() => loading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        showMessage("Google token error");
        return;
      }

      final url = Uri.parse("${ApiConstants.authUrl}/api/auth/google-auth");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      ).timeout(_requestTimeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        final user = _userPayloadFromResponse(data);
        final String userName =
            (user['name'] ?? googleUser.displayName ?? 'Unknown').toString();
        final String userEmail =
            (user['email'] ?? googleUser.email).toString();
        final String userId = _resolveUserId(data) ?? '';
        final String token = (data['token'] ?? '').toString();
        final String role = (user['category'] ?? 'Student').toString();
        final String userType = (user['userType'] ?? 'free').toString();
        final onboardingProgress =
            _resolveOnboardingProgress(
              user,
              data: data,
            );

        if (userId.isEmpty || token.isEmpty) {
          showMessage("Google login response was incomplete");
          return;
        }

        await _saveUserSession(
          userId,
          userName,
          userEmail,
          token,
          role,
          userType,
          completedStep1:
              onboardingProgress['completedStep1']!,
          completedStep2:
              onboardingProgress['completedStep2']!,
          completedStep3:
              onboardingProgress['completedStep3']!,
        );

        await RoleService.init();


        await _redirectAfterLogin(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        );
      } else {
        showMessage(data["message"] ?? "Google login failed");
      }

      await _googleSignIn.signOut();
    } on TimeoutException {
      showMessage("Server timeout. Check backend at ${ApiConstants.authUrl}");
    } on SocketException {
      showMessage(
        "Cannot reach server at ${ApiConstants.authUrl}. Check network/backend/firewall.",
      );
    } catch (e) {
      showMessage("Google Sign-In error");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> signInWithFacebook() async {
    print("👉 Facebook login started");
    setState(() => loading = true);

    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      print("📊 Facebook login status: ${result.status}");
      print("📊 Facebook login message: ${result.message}");

      if (result.status == LoginStatus.cancelled) {
        showMessage("Facebook login cancelled");
        return;
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        showMessage(result.message ?? "Facebook login failed");
        return;
      }

      final accessToken = result.accessToken!.token;
      final userData = await FacebookAuth.instance.getUserData();
      print("✅ Facebook login user data: $userData");

      final url = Uri.parse("${ApiConstants.authUrl}/api/auth/facebook-auth");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"accessToken": accessToken}),
      ).timeout(_requestTimeout);

      print("🔥 Facebook login API status: ${response.statusCode}");
      print("🔥 Facebook login API response: ${response.body}");

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        final user = _userPayloadFromResponse(data);
        final String userName =
            (user['name'] ?? userData['name'] ?? 'Unknown').toString();
        final String userEmail =
            (user['email'] ?? userData['email'] ?? '').toString();
        final String userId = _resolveUserId(data) ?? '';
        final String token = (data['token'] ?? '').toString();
        final String role = (user['category'] ?? 'Student').toString();
        final String userType = (user['userType'] ?? 'free').toString();
        final onboardingProgress =
            _resolveOnboardingProgress(
              user,
              data: data,
            );

        if (userId.isEmpty || token.isEmpty) {
          showMessage("Facebook login response was incomplete");
          return;
        }

        await _saveUserSession(
          userId,
          userName,
          userEmail,
          token,
          role,
          userType,
          completedStep1:
              onboardingProgress['completedStep1']!,
          completedStep2:
              onboardingProgress['completedStep2']!,
          completedStep3:
              onboardingProgress['completedStep3']!,
        );

        await RoleService.init();

        await _redirectAfterLogin(
          userId: userId,
          userName: userName,
          userEmail: userEmail,
        );
      } else {
        showMessage(data["message"] ?? "Facebook login failed");
      }
    } on TimeoutException {
      showMessage("Server timeout. Check backend at ${ApiConstants.authUrl}");
    } on SocketException {
      showMessage(
        "Cannot reach server at ${ApiConstants.authUrl}. Check network/backend/firewall.",
      );
    } catch (e) {
      print("💥 Facebook Login Error: $e");
      showMessage("Facebook Sign-In error");
    } finally {
      try {
        await FacebookAuth.instance.logOut();
      } catch (logoutError) {
        print("ℹ️ Facebook logout skipped: $logoutError");
      }

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ===================== UI HELPERS =====================
  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget socialIcon(String assetPath) {
    return Container(
      height: 54,
      width: 54,
      decoration: TemplateTheme.softCard(
        color: Colors.white.withOpacity(0.92),
        radius: 18,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🔥 LoginScreen BUILD START");
    print("🔥 TemplateLayout called");
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: TemplateTheme.surface,
      body: TemplateLayout(
       brandTitle: "Arthum Ai",
        brandSubtitle: "Sign in to continue with your AI workspace.",
        // Clean UI - no section title/subtitle
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 4,
            right: 4,
            top: 2,
            bottom: media.padding.bottom + 12,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: media.size.height - media.padding.top - 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: TemplateTheme.glassPanel(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: TemplateTheme.inputDecoration(
                          label: "Email",
                          hint: "you@example.com",
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            color: TemplateTheme.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: TemplateTheme.inputDecoration(
                          label: "Password",
                          hint: "Enter your password",
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: TemplateTheme.textMuted,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : loginUser,
                          style: TemplateTheme.primaryButtonStyle(),
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text("Login"),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const Registration(),
                                    ),
                                  );
                                },
                          style: TemplateTheme.softButtonStyle(),
                          child: const Text("Create account"),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "OR CONTINUE WITH",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: TemplateTheme.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Disabled for Closed Testing: Google Sign-In UI entry point
                          // GestureDetector(
                          //   onTap: loading ? null : signInWithGoogle,
                          //   child: socialIcon("assets/icons/google.png"),
                          // ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: loading ? null : signInWithFacebook,
                            child: socialIcon("assets/icons/facebook.png"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(18),
                  decoration: TemplateTheme.softCard(
                    color: Colors.white.withOpacity(0.74),
                    radius: 22,
                  ),
                  child: const Text(
                    "Existing login, Google auth, feature redirects, and session persistence remain unchanged.",
                    style: TextStyle(
                      fontSize: 13,
                      color: TemplateTheme.textMuted,
                      height: 1.45,
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
