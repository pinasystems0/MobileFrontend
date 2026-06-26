import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pina/screens/constants.dart'; // Assuming ApiConstants is here
import 'package:pina/credit/toolmanagerscreen.dart';
import 'package:pina/services/session_service.dart';
import '../../services/role_guard.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

class ExplicitContentCheckScreen extends StatefulWidget {
  const ExplicitContentCheckScreen({super.key});

  @override
  State<ExplicitContentCheckScreen> createState() =>
      _ExplicitContentCheckScreenState();
}

class _ExplicitContentCheckScreenState
    extends State<ExplicitContentCheckScreen> {
  final GlobalKey<ToolManagerScreenState> toolManagerKey = GlobalKey<ToolManagerScreenState>();

  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _results;
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  String _mapError(String rawError) {
    debugPrint("REAL ERROR: $rawError");
    if (rawError.toLowerCase().contains('timeout')) {
      return "Connection seems slow. Please try again.";
    } else if (rawError.toLowerCase().contains('network')) {
      return "No internet connection. Please check your network.";
    }
    return "Oops! Something went wrong. Please try again.";
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _results = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _checkContent() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = null;
    });

    try {
      final headers = await SessionService.authHeaders();
      if (!headers.containsKey('Authorization')) {
        throw Exception("User not logged in");
      }

      final uri = Uri.parse('${ApiConstants.authUrl}/api/explicit/check');

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedImage!.path),
      );

      print("Sending request to Backend...");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 402) {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? "Insufficient balance";
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insufficient Balance! Please buy credits."),
            backgroundColor: Colors.red,
          ),
        );
        
        return;
      }

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        setState(() {
          _results = (jsonResponse['data'] as Map?)?.cast<String, dynamic>();
        });
        toolManagerKey.currentState?.fetchBalance();
      } else {
        String rawError = jsonResponse['error'] ?? "Unknown Server Error";
        String friendly = _mapError(rawError);
        setState(() {
          _errorMessage = friendly;
        });
        debugPrint("REAL ERROR: $rawError");
        return;
      }
    } catch (e) {
      String rawError = e.toString();
      String friendly = _mapError(rawError);
      setState(() {
        _errorMessage = friendly;
      });
      debugPrint("REAL ERROR: $rawError");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getScoreColor(double score, bool isSafeCategory) {
    if (isSafeCategory) {
      return score > 80
          ? Colors.green
          : (score > 50 ? Colors.orange : Colors.red);
    } else {
      return score < 20
          ? Colors.green
          : (score < 50 ? Colors.orange : Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      feature: 'EXPLICIT',
      child: TemplateBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "Explicit Content Check",
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: TemplateTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ToolManagerScreen(key: toolManagerKey, requiredCredits: 10),
                      const SizedBox(height: 20),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImage!, fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_search,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 10),
                                    Text("Select an image to analyze"),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text("Gallery"),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Camera"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: (_selectedImage != null && !_isLoading)
                            ? _checkContent
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemplateTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Analyze Image"),
                      ),
                      const SizedBox(height: 30),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_results != null)
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            const Text(
                              "Analysis Results:",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 15),
                            _buildResultTile(
                              "Safe Content",
                              _results!['safe'] ?? 0,
                              Icons.check_circle_outline,
                              true,
                            ),
                            const SizedBox(height: 10),
                            _buildResultTile(
                              "Partial Nudity",
                              _results!['partial'] ?? 0,
                              Icons.warning_amber_rounded,
                              false,
                            ),
                            const SizedBox(height: 10),
                            _buildResultTile(
                              "Explicit / Raw",
                              _results!['raw'] ?? 0,
                              Icons.block,
                              false,
                            ),
                            // ✅ Safe highlight message
                            if ((_results!['safe'] ?? 0) > 80)
                              const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  "✅ This content looks safe",
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile(
    String title,
    num score,
    IconData icon,
    bool isSafeCategory,
  ) {
    double value = score.toDouble();
    String percentage = "${value.toStringAsFixed(1)}%";
    Color color = _getScoreColor(value, isSafeCategory);

    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          percentage,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}