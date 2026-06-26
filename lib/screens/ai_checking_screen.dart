import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pina/credit/toolmanagerscreen.dart';
import 'package:pina/screens/constants.dart';
import 'package:pina/services/session_service.dart';
import '../../services/role_guard.dart';
import 'package:pina/ui_template/utils/template_theme.dart';

// ============================================
// MODERN COLOR PALETTE - REMOVED, USING TEMPLATE THEME
// ============================================
const Color _lowRiskColor = Color(0xFF16A34A);
const Color _mediumRiskColor = Color(0xFFF59E0B);
const Color _highRiskColor = Color(0xFFDC2626);

// ============================================
// ENUMS
// ============================================
enum DeepfakeStatus { idle, loading, completed }

// ============================================
// HELPER FUNCTIONS
// ============================================
(String riskLevel, Color color, IconData statusIcon) getRiskLevel(double score) {
  if (score > 0.8) {
    return ('HIGH', _highRiskColor, Icons.cancel_outlined);
  } else if (score >= 0.5) {
    return ('MEDIUM', _mediumRiskColor, Icons.warning_amber_outlined);
  } else {
    return ('LOW', _lowRiskColor, Icons.check_circle_outline);
  }
}

String getStatusText(double score) {
  if (score > 0.8) {
    return 'Deepfake Detected';
  } else if (score >= 0.5) {
    return 'Suspicious Manipulation';
  } else {
    return 'Authentic Content';
  }
}

String getDetectionCategory(double score) {
  if (score > 0.8) {
    return 'Synthetic Media';
  } else if (score >= 0.5) {
    return 'AI Assisted';
  } else {
    return 'Authentic';
  }
}

String getDeepfakeTypeText(double score) {
  if (score > 0.8) {
    return 'Audio/Visual Manipulation';
  } else if (score >= 0.5) {
    return 'AI Generated';
  } else {
    return 'Original Content';
  }
}

String getExplanationText(double score) {
  if (score > 0.8) {
    return 'High probability of synthetic manipulation. Our AI has detected multiple inconsistencies in patterns, frequencies, and artifacts consistent with deepfake generation.';
  } else if (score >= 0.5) {
    return 'Content shows moderate signs of manipulation. Some artifacts and inconsistencies were detected, suggesting possible AI intervention.';
  } else {
    return 'Media appears authentic. No significant signs of manipulation or synthetic generation were detected in our analysis.';
  }
}

// ============================================
// MAIN SCREEN
// ============================================
class AiCheckingScreen extends StatefulWidget {
  final String userId;
  const AiCheckingScreen({super.key, required this.userId});

  @override
  State<AiCheckingScreen> createState() => _AiCheckingScreenState();
}

class _AiCheckingScreenState extends State<AiCheckingScreen> {
  final GlobalKey<ToolManagerScreenState> toolManagerKey = GlobalKey<ToolManagerScreenState>();

  // Media
  File? _selectedMedia;
  String? _mediaType; // 'image', 'video', or 'audio'
  String? _fileName;

  // Status
  DeepfakeStatus _status = DeepfakeStatus.idle;

  // Result
  double? _deepfakeScore;
  String? _resultMessage;
  String? _explanation;

  final ImagePicker _imagePicker = ImagePicker();

  // ============================================
  // MEDIA PICKING - UPDATED FOR AUDIO
  // ============================================
  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ModernMediaPickerSheet(
        onImageTap: () => _pickImage(),
        onVideoTap: () => _pickVideo(),
        onAudioTap: () => _pickAudio(),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _mediaType = 'image';
        _fileName = pickedFile.name;
        _status = DeepfakeStatus.idle;
        _deepfakeScore = null;
        _resultMessage = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _mediaType = 'video';
        _fileName = pickedFile.name;
        _status = DeepfakeStatus.idle;
        _deepfakeScore = null;
        _resultMessage = null;
      });
    }
  }

  Future<void> _pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
      );

      print("🎧 AUDIO RESULT: $result");

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedMedia = File(result.files.single.path!);
          _mediaType = 'audio';
          _fileName = result.files.single.name;
          _status = DeepfakeStatus.idle;
          _deepfakeScore = null;
          _resultMessage = null;
        });
      } else {
        print("❌ No audio selected");
      }
    } catch (e) {
      print("🔥 AUDIO PICK ERROR: $e");
    }
  }

  // ============================================
  // API CALLS (UNCHANGED - Only UI redesigned)
  // ============================================
  String _mapError(String rawError) {
    debugPrint("REAL ERROR: $rawError");
    if (rawError.toLowerCase().contains('timeout') || rawError.toLowerCase().contains('network')) {
      return "Connection seems slow. Please try again.";
    } else if (rawError.toLowerCase().contains('limit')) {
      return "Monthly limit reached. Please upgrade or wait.";
    }
    return "Oops! Something went wrong. Please try again.";
  }

  Future<Map<String, dynamic>?> _checkWithBackend() async {
    try {
      final headers = await SessionService.authHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'error': 'unauthorized',
          'message': 'Please login again.',
        };
      }

      var uri = Uri.parse("${ApiConstants.authUrl}/api/deepfake/check");
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath('media', _selectedMedia!.path),
      );
      if (_mediaType != null) {
          request.fields['mediaType'] = _mediaType!;
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        debugPrint("Backend Response: $data");
        return data;
      } else if (response.statusCode == 402) {
        var data = jsonDecode(response.body);
        debugPrint("Insufficient balance: ${data['message']}");
        return {
          'error': 'INSUFFICIENT_BALANCE',
          'message': data['message'],
        };
      } else if (response.statusCode == 429) {
        var data = jsonDecode(response.body);
        debugPrint("Monthly limit reached: ${data['error']}");
        return {'error': 'monthly_limit', 'message': data['error']};
      } else if (response.statusCode == 400) {
        var data = jsonDecode(response.body);
        debugPrint("Bad request: ${data['error']}");
        return {'error': 'bad_request', 'message': data['error']};
      } else if (response.statusCode == 502) {
        var data = jsonDecode(response.body);
        debugPrint("API error: ${data['error']}");
        return {'error': 'api_error', 'message': data['error']};
      } else {
        debugPrint("Backend Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Backend Connection Error: $e");
      return null;
    }
  }

  Future<void> _startProcess() async {
    if (_selectedMedia == null) return;
    if (_status == DeepfakeStatus.loading) return;

    setState(() {
      _status = DeepfakeStatus.loading;
    });

    final result = await _checkWithBackend();

    if (result != null && result['error'] == 'INSUFFICIENT_BALANCE') {
      setState(() {
        _status = DeepfakeStatus.idle;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insufficient Balance! Please buy credits."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (result != null && result['success'] == true) {
      toolManagerKey.currentState?.fetchBalance();
      double score = 0.0;
      if (result['probability'] != null) {
        score = double.tryParse(result['probability'].toString()) ?? 0.0;
        score = score / 100;
      }

      setState(() {
        _deepfakeScore = score;
        _resultMessage = result['detectedType'] ?? getDeepfakeTypeText(score);
        _explanation = result['explanation'];
        
        _status = DeepfakeStatus.completed;
      });
    } else if (result != null && result['success'] == false) {
      String rawError = result['error'] ?? "Something went wrong";
      String friendlyMsg = _mapError(rawError);

      setState(() {
        _status = DeepfakeStatus.idle;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyMsg),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      debugPrint("REAL ERROR: $rawError");
    } else {
      setState(() {
        _status = DeepfakeStatus.idle;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to analyze media. Please try again."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetToIdle() {
    setState(() {
      _status = DeepfakeStatus.idle;
      _selectedMedia = null;
      _mediaType = null;
      _fileName = null;
      _deepfakeScore = null;
      _resultMessage = null;
    });
  }

  // ============================================
  // BUILD METHODS
  // ============================================
  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      feature: 'DEEPFAKE',
      child: TemplateBackdrop(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildModernAppBar(),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ToolManagerScreen(key: toolManagerKey, requiredCredits: 3),
                  const SizedBox(height: 20),
                  _buildContentByState(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: TemplateTheme.primary,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      title: const Text(
        "Deepfake Detection",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history_outlined, size: 22),
            tooltip: "History",
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentByState() {
    switch (_status) {
      case DeepfakeStatus.idle:
        return _buildIdleState();
      case DeepfakeStatus.loading:
        return _buildLoadingState();
      case DeepfakeStatus.completed:
        return _buildResultState();
    }
  }

  // ============================================
  // IDLE STATE
  // ============================================
  Widget _buildIdleState() {
    if (_selectedMedia == null) {
      return _buildModernUploadCard();
    } else {
      return _buildModernMediaPreview();
    }
  }

  Widget _buildModernUploadCard() {
    return Column(
      children: [
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickMedia,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: TemplateTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: TemplateTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Upload Image, Video or Audio",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: TemplateTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Drag and drop or tap to browse",
                        style: TextStyle(
                          fontSize: 14,
                          color: TemplateTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "JPG, PNG, MP4, MP3, WAV, AAC",
                          style: TextStyle(
                            fontSize: 12,
                            color: TemplateTheme.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _pickMedia,
            style: ElevatedButton.styleFrom(
              backgroundColor: TemplateTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 20),
                SizedBox(width: 8),
                Text(
                  "Browse Files",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with file info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TemplateTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMediaIcon(),
                  size: 20,
                  color: TemplateTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getMediaTypeLabel(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.textPrimary,
                      ),
                    ),
                    Text(
                      _fileName ?? 'Media file',
                      style: TextStyle(
                        fontSize: 12,
                        color: TemplateTheme.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Media preview with proper aspect ratio
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: _buildPreviewContent(),
          ),
        ),
        const SizedBox(height: 24),
        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pickMedia,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TemplateTheme.textMuted,
                  side: BorderSide(color: TemplateTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Change Media"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _startProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TemplateTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics_outlined, size: 18),
                    SizedBox(width: 8),
                    Text("Analyze with AI"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getMediaIcon() {
    switch (_mediaType) {
      case 'image':
        return Icons.image_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.image_outlined;
    }
  }

  String _getMediaTypeLabel() {
    switch (_mediaType) {
      case 'image':
        return 'Selected Image';
      case 'video':
        return 'Selected Video';
      case 'audio':
        return 'Selected Audio';
      default:
        return 'Selected Media';
    }
  }

  Widget _buildPreviewContent() {
    if (_mediaType == 'image') {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.file(
          _selectedMedia!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (_mediaType == 'video') {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.grey.shade900),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Audio preview - visual representation
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TemplateTheme.primary.withValues(alpha: 0.1),
              TemplateTheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TemplateTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.audiotrack,
                size: 56,
                color: TemplateTheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fileName ?? 'Audio File',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TemplateTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Audio File Ready for Analysis",
                style: TextStyle(
                  fontSize: 12,
                  color: TemplateTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ============================================
  // LOADING STATE
  // ============================================
  Widget _buildLoadingState() {
    return Column(
      children: [
        // Media preview shimmer
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: _mediaType == 'audio' ? 180 : 200,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const _ShimmerEffect(),
          ),
        ),
        const SizedBox(height: 32),
        // Animated loader
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: TemplateTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Analyzing with AI...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: TemplateTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildStepIndicator(),
              const SizedBox(height: 16),
              Text(
                "This may take a few seconds",
                style: TextStyle(
                  fontSize: 13,
                  color: TemplateTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        _buildStepItem(0, "Checking patterns", true),
        const SizedBox(height: 12),
        _buildStepItem(1, "Detecting anomalies", false),
        const SizedBox(height: 12),
        _buildStepItem(2, "Finalizing result", false),
      ],
    );
  }

  Widget _buildStepItem(int index, String text, bool isActive) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? TemplateTheme.primary : Colors.grey.shade200,
          ),
          child: isActive
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? TemplateTheme.textPrimary : TemplateTheme.textMuted,
          ),
        ),
      ],
    );
  }

  // ============================================
  // RESULT STATE
  // ============================================
  Widget _buildResultState() {
    final score = _deepfakeScore ?? 0.0;
    final (riskLevel, riskColor, statusIcon) = getRiskLevel(score);
    final statusText = getStatusText(score);
    final detectionCategory = getDetectionCategory(score);
    final deepfakeType = _resultMessage ?? getDeepfakeTypeText(score);
    final explanation = _explanation ?? getExplanationText(score);
    final percentage = (score * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media preview thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _buildResultPreviewContent(),
        ),
        const SizedBox(height: 20),
        // Modern Result Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: TemplateTheme.border, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TemplateTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: TemplateTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Analysis Report",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TemplateTheme.textPrimary,
                            ),
                          ),
                          Text(
                            "AI Forensic Scan Completed",
                            style: TextStyle(
                              fontSize: 12,
                              color: TemplateTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Status Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: riskColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, color: riskColor, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: riskColor,
                                  ),
                                ),
                                Text(
                                  "Risk Level: $riskLevel",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: riskColor.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Confidence Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip("Detection Type", deepfakeType),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoChip("Category", detectionCategory),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Confidence Score and Progress Bar
                    const Text(
                      "Confidence Score",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$percentage%",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _getConfidenceLevel(score),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: riskColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 8,
                        color: Colors.grey.shade200,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: score.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: riskColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Explanation Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: TemplateTheme.textMuted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              explanation,
                              style: TextStyle(
                                fontSize: 13,
                                color: TemplateTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Analysis Details
                    const Text(
                      "Analysis Details",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TemplateTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisDetails(score),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _resetToIdle,
                style: OutlinedButton.styleFrom(
                  foregroundColor: TemplateTheme.textPrimary,
                  side: BorderSide(color: TemplateTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Check Another Media"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Share report functionality (optional)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Report feature coming soon"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text("Share Report"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TemplateTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultPreviewContent() {
    if (_mediaType == 'image') {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.file(
          _selectedMedia!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (_mediaType == 'video') {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.grey.shade900),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Audio result preview
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TemplateTheme.primary.withValues(alpha: 0.15),
              TemplateTheme.primary.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: TemplateTheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.audiotrack,
                size: 40,
                color: TemplateTheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileName ?? 'Audio File',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TemplateTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Audio Forensics Complete",
                    style: TextStyle(
                      fontSize: 12,
                      color: TemplateTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      );
    }
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: TemplateTheme.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: TemplateTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _getConfidenceLevel(double score) {
    if (score < 0.3) return "Low";
    if (score < 0.7) return "Moderate";
    return "High";
  }

  Widget _buildAnalysisDetails(double score) {
    final items = [
      {"icon": Icons.face_retouching_natural, "text": "Pattern consistency", "score": score},
      {"icon": Icons.pattern, "text": "Synthetic artifacts", "score": score},
      {"icon": Icons.graphic_eq, "text": "Frequency analysis", "score": score},
      {"icon": Icons.psychology, "text": "AI fingerprints", "score": score},
    ];

    return Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        final isDetected = (item["score"] as double) > 0.4;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                isDetected ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 18,
                color: isDetected ? _highRiskColor : _lowRiskColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item["text"] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TemplateTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDetected ? _highRiskColor.withValues(alpha: 0.1) : _lowRiskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isDetected ? "Detected" : "Clean",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDetected ? _highRiskColor : _lowRiskColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================
// MODERN MEDIA PICKER SHEET - UPDATED WITH AUDIO
// ============================================
class _ModernMediaPickerSheet extends StatelessWidget {
  final VoidCallback onImageTap;
  final VoidCallback onVideoTap;
  final VoidCallback onAudioTap;

  const _ModernMediaPickerSheet({
    required this.onImageTap,
    required this.onVideoTap,
    required this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Media Type",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TemplateTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choose an image, video, or audio to analyze",
                style: TextStyle(
                  fontSize: 14,
                  color: TemplateTheme.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerOption(
                      context: context,
                      icon: Icons.image_outlined,
                      label: "Image",
                      gradientColors: [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
                      onTap: onImageTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerOption(
                      context: context,
                      icon: Icons.videocam_outlined,
                      label: "Video",
                      gradientColors: [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
                      onTap: onVideoTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPickerOption(
                      context: context,
                      icon: Icons.audiotrack,
                      label: "Audio",
                      gradientColors: [const Color(0xFF10B981), const Color(0xFF059669)],
                      onTap: onAudioTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: TemplateTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
        onTap();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SHIMMER EFFECT WIDGET
// ============================================
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-0.5 + 2.0 * _controller.value, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }
}