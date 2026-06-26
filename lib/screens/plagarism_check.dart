import 'dart:convert';
import 'dart:io';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:pina/screens/constants.dart'; // Import Constants for URL
import 'package:pina/services/session_service.dart';
import '../../services/role_guard.dart';
import 'package:pina/credit/toolmanagerscreen.dart'; // ✅ 1️⃣ Import added
import 'package:pina/ui_template/utils/template_theme.dart';

void main() {
  runApp(
    const MaterialApp(
      home: CopyleaksScanScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class CopyleaksScanScreen extends StatefulWidget {
  const CopyleaksScanScreen({super.key});

  @override
  State<CopyleaksScanScreen> createState() => _CopyleaksScanScreenState();
}

class _CopyleaksScanScreenState extends State<CopyleaksScanScreen> {
  String get _myBackendUrl => ApiConstants.authUrl;

  String? _fileName;
  String? _fileContent;
  bool _isLoading = false;
  String? _resultMessage;
  double? _aiScore;

  // ✅ 2️⃣ GlobalKey for ToolManagerScreen
  final GlobalKey<ToolManagerScreenState> toolManagerKey =
      GlobalKey<ToolManagerScreenState>();

  // Unique Scan ID generator (timestamp based)
  String get _scanId => "scan-${DateTime.now().millisecondsSinceEpoch}";

  /// Step 1: Pick a file and read its content
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String filename = result.files.single.name;
        String extension = result.files.single.extension?.toLowerCase() ?? "";
        String extractedText = "";

        setState(() {
          _isLoading = true;
        });

        if (extension == 'txt') {
          extractedText = await file.readAsString();
        } else if (extension == 'pdf') {
          try {
            extractedText = await ReadPdfText.getPDFtext(file.path);
          } catch (e) {
            extractedText =
                "Error reading PDF: This might be an image-only PDF.";
          }
        } else if (extension == 'docx') {
          final bytes = await file.readAsBytes();
          extractedText = docxToText(bytes);
        }

        setState(() {
          _fileName = filename;
          _fileContent = extractedText;
          _resultMessage = null;
          _aiScore = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error reading file: $e")));
    }
  }

  /// Step 2: Save to DB and Scan via Backend
  Future<void> _scanDocument() async {
    if (_fileContent == null) return;

    setState(() {
      _isLoading = true;
      _resultMessage = "Preparing scan...";
    });

    try {
      if (await SessionService.getUserId() == null) {
        throw Exception("User not logged in.");
      }
      final headers = await SessionService.authHeaders(
        includeJsonContentType: true,
      );

      // 2. Save Input to MongoDB -> Get plagId
      int plagId = await _saveInputToMyDb(_fileContent!, headers);

      if (plagId == 0) {
        throw Exception("Failed to save input to database. Aborting scan.");
      }

      setState(() {
        _resultMessage = "Scanning content...";
      });

      // 3. Route through backend for AI detection (Copyleaks)
      // This keeps API keys secure in backend
      final scanUrl = Uri.parse("$_myBackendUrl/api/plagiarism/scan");
      final response = await http.post(
        scanUrl,
        headers: headers,
        body: jsonEncode({
          "text": _fileContent,
          "scanId": _scanId
        }),
      );

      if (response.statusCode == 402) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? "Insufficient balance");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double aiProb =
    (data['aiProbability'] ?? 0).toDouble();
        final double humanProb = 1.0 - aiProb;

        setState(() {
          _aiScore = aiProb;
          _resultMessage = "Scan Complete";
        });

        // ✅ 4️⃣ Refresh balance on successful scan
        toolManagerKey.currentState?.fetchBalance();

        // 4. Save Output to MongoDB using plagId
        await _saveOutputToMyDb(plagId, aiProb, humanProb);
      } else {
        throw Exception(
          "Scan failed: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      setState(() {
        _resultMessage = "Error: ${e.toString().replaceAll("Exception: ", "")}";
      });
      print("ERROR: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- API HELPER: Save Input ---
  Future<int> _saveInputToMyDb(
    String text,
    Map<String, String> headers,
  ) async {
    try {
      // Updated to the new route structure
      final url = Uri.parse("$_myBackendUrl/api/plagiarism/input");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({"inputDocument": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Input saved. ID: ${data['plagId']}");
        return data['plagId'];
      } else {
        print("❌ Failed to save input: ${response.body}");
        return 0;
      }
    } catch (e) {
      print("❌ Backend connection error (Input): $e");
      return 0;
    }
  }

  // --- API HELPER: Save Output ---
  Future<void> _saveOutputToMyDb(
    int plagId,
    double aiProb,
    double humanProb,
  ) async {
    try {
      // Updated to the new route structure
      final url = Uri.parse("$_myBackendUrl/api/plagiarism/output");
      final headers = await SessionService.authHeaders(
        includeJsonContentType: true,
      );

      await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          "plagId": plagId,
          "aiProbability": aiProb,
          "humanProbability": humanProb,
        }),
      );
      print("✅ Results saved to DB");
    } catch (e) {
      print("❌ Backend connection error (Output): $e");
    }
  }

  // NOTE: Copyleaks authentication is now handled by backend
  // All API keys are stored securely in backend/.env

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      feature: 'PLAGIARISM',
      child: TemplateBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "AI Content Scanner",
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: TemplateTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ✅ 3️⃣ ToolManagerScreen added at the top
                  ToolManagerScreen(
                    key: toolManagerKey,
                    requiredCredits: 2,
                  ),
                  const SizedBox(height: 20),

                  // 1. Upload Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: TemplateTheme.border),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 50,
                          color: TemplateTheme.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _fileName ?? "No file selected",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _pickFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TemplateTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Select Document"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Action Button
                  ElevatedButton(
                    onPressed: (_fileContent != null && !_isLoading)
                        ? _scanDocument
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: TemplateTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Scan for AI Content"),
                  ),

                  const SizedBox(height: 30),

                  // 3. Results Section
                  if (_aiScore != null) ...[
                    const Text(
                      "Scan Results",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildScoreCard("AI Probability", _aiScore!, Colors.redAccent),
                    const SizedBox(height: 10),
                    _buildScoreCard(
                      "Human Probability",
                      1.0 - _aiScore!,
                      Colors.green,
                    ),
                  ],

                  if (_resultMessage != null && _aiScore == null)
                    Text(
                      _resultMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, double score, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TemplateTheme.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            "${(score * 100).toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}