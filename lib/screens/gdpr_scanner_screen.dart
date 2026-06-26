import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pina/credit/toolmanagerscreen.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import '../../services/role_guard.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class GDPRScannerScreen extends StatefulWidget {
  const GDPRScannerScreen({super.key});

  @override
  State<GDPRScannerScreen> createState() => _GDPRScannerScreenState();
}

class _GDPRScannerScreenState extends State<GDPRScannerScreen> {
  final GlobalKey<ToolManagerScreenState> toolManagerKey =
      GlobalKey<ToolManagerScreenState>();

  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = await SessionService.getUserId();
    if (!mounted) return;
    setState(() {
      _currentUserId = userId;
    });
  }

  Future<void> _checkCompliance() async {
    String url = _urlController.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      if (await SessionService.getUserId() == null) {
        throw Exception("User not logged in");
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.authUrl}/api/gdpr/scan'),
        headers: await SessionService.authHeaders(includeJsonContentType: true),
        body: jsonEncode({
          'url': url,
        }),
      );

      if (response.statusCode == 402) {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? "Insufficient balance";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insufficient Balance! Please buy credits."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = (data['data'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

        setState(() {
          _result = {
            "url": result['url'],
            "score": result['score'] ?? 0,
            "ssl": result['sslSecure'] ?? false,
            "privacy_policy": result['privacyPolicyFound'] ?? false,
            "cookie_banner": result['cookieBannerFound'] ?? false,
            "source": "Backend Scan",
          };
        });
        toolManagerKey.currentState?.fetchBalance();
      } else {
        setState(() {
          _errorMessage = "Server error occurred. Please try again.";
        });
      }
    } catch (e) {
      String friendly = "Connection seems slow. Please try again.";
      if (e.toString().contains('SocketException')) {
        friendly = "No internet connection.";
      }
      setState(() {
        _errorMessage = friendly;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      feature: 'GDPR',
      child: TemplateBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "GDPR Compliance Checker",
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: TemplateTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ToolManagerScreen(key: toolManagerKey, requiredCredits: 2),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: "Enter Website URL",
                      hintText: "example.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: Icon(
                        Icons.language,
                        color: TemplateTheme.primary,
                      ),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          (_isLoading || _currentUserId == null) ? null : _checkCompliance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TemplateTheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Check Compliance"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_result != null) _buildResultCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final int score = (_result!['score'] as num).toInt();
    final bool isSafe = score >= 70;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: TemplateTheme.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Compliance Score",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSafe ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$score/100",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildCheckItem("SSL Secure Connection", _result!['ssl'] == true),
            _buildCheckItem(
              "Privacy Policy Found",
              _result!['privacy_policy'] == true,
            ),
            _buildCheckItem(
              "Cookie Consent Banner",
              _result!['cookie_banner'] == true,
            ),
            const SizedBox(height: 10),
            Text(
              "Source: ${_result!['source']}",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}