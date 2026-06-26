import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central theme system for the Conversion Module
/// Provides a unified purple-pink electric AI style across all conversion screens
class ConversionTheme {
  // ==================== COLORS ====================
  
  /// Primary purple color
  static const Color primaryPurple = Color(0xFF6A5AE0);
  
  /// Electric pink color
  static const Color electricPink = Color(0xFFFF4DA6);
  
  /// Neon purple color
  static const Color neonPurple = Color(0xFFB845FF);
  
  /// Background color (light lavender)
  static const Color backgroundColor = Color(0xFFF5F3FF);
  
  /// White color for backgrounds
  static const Color whiteColor = Color(0xFFFFFFFF);
  
  /// Primary text color
  static const Color primaryText = Colors.black87;
  
  /// Secondary text color
  static const Color secondaryText = Color(0xFF757575);
  
  /// User bubble text color
  static const Color userBubbleText = Colors.white;
  
  /// AI bubble background color
  static const Color aiBubbleBackground = Color(0xFFF5F5F5);

  // ==================== GRADIENTS ====================
  
  /// Primary gradient (purple -> pink)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primaryPurple,
      neonPurple,
      electricPink,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      primaryPurple,
      neonPurple,
      electricPink,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  /// User bubble gradient
  static const LinearGradient bubbleGradient = LinearGradient(
    colors: [
      primaryPurple,
      neonPurple,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Screen background gradient
  static const LinearGradient screenBackgroundGradient = LinearGradient(
    colors: [
      backgroundColor,
      whiteColor,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ==================== BUBBLE DECORATIONS ====================
  
  /// User bubble decoration - right aligned with purple gradient
  static BoxDecoration get userBubbleDecoration => BoxDecoration(
    gradient: bubbleGradient,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  /// AI bubble decoration - left aligned with light grey/white background
  static BoxDecoration get aiBubbleDecoration => BoxDecoration(
    color: aiBubbleBackground,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.grey.shade300, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // ==================== INPUT FIELD STYLE ====================
  
  /// Input decoration for the prompt text field
  static InputDecoration inputDecoration({
    String hintText = "Enter prompt",
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: secondaryText),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
  
  /// Input decoration with soft shadow effect
  static BoxDecoration get inputContainerDecoration => BoxDecoration(
    color: whiteColor,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ==================== SEND BUTTON STYLE ====================
  
  /// Send button decoration with gradient background
  static BoxDecoration get sendButtonDecoration => BoxDecoration(
    gradient: buttonGradient,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withOpacity(0.4),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  /// Send button style (for use with ElevatedButton)
  static ButtonStyle get sendButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryPurple,
    foregroundColor: whiteColor,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    elevation: 4,
  );

  // ==================== PROVIDER BUTTON STYLE ====================
  
  /// Provider selector button (🤖) decoration with purple gradient and glow
  static BoxDecoration get providerButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withOpacity(0.5),
        blurRadius: 12,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: electricPink.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );

  // ==================== ICON BUTTON STYLES ====================
  
  /// Icon button for attachments
  static IconThemeData get attachmentIconTheme => const IconThemeData(
    color: primaryPurple,
    size: 24,
  );
  
  /// Icon button for microphone
  static IconThemeData get micIconTheme => const IconThemeData(
    color: primaryPurple,
    size: 24,
  );
  
  /// Icon button for provider selector
  static IconThemeData get providerIconTheme => const IconThemeData(
    color: whiteColor,
    size: 22,
  );

  // ==================== APP BAR STYLE ====================
  
  /// AppBar decoration with gradient
  static BoxDecoration get appBarDecoration => const BoxDecoration(
    gradient: primaryGradient,
  );
  
  /// AppBar text style
  static TextStyle get appBarTitleStyle => const TextStyle(
    color: whiteColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // ==================== MESSAGE ACTIONS ====================
  
  /// Copy message text to clipboard
  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("Copied to clipboard"),
            ],
          ),
          backgroundColor: primaryPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Show edit prompt dialog
  static Future<String?> showEditDialog(
    BuildContext context, 
    String currentText,
  ) async {
    final controller = TextEditingController(text: currentText);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: primaryPurple),
            SizedBox(width: 8),
            Text("Edit Prompt"),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Enter your prompt",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: whiteColor,
            ),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
  
  /// Show resend/regenerate confirmation
  static Future<bool> showResendConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: primaryPurple),
            SizedBox(width: 8),
            Text("Resend Prompt"),
          ],
        ),
        content: const Text("Do you want to resend this prompt?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: whiteColor,
            ),
            child: const Text("Resend"),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  /// Show regenerate confirmation
  static Future<bool> showRegenerateConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_fix_high, color: primaryPurple),
            SizedBox(width: 8),
            Text("Regenerate Response"),
          ],
        ),
        content: const Text("Do you want to regenerate this response?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: whiteColor,
            ),
            child: const Text("Regenerate"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ==================== EMPTY STATE ====================
  
  /// Empty state text style
  static TextStyle get emptyStateTextStyle => TextStyle(
    color: secondaryText,
    fontSize: 16,
  );
  
  /// Empty state icon
  static IconData get emptyStateIcon => Icons.chat_bubble_outline;

  // ==================== LOADING STATE ====================
  
  /// Loading indicator color
  static Color get loadingColor => primaryPurple;
  
  /// Loading text style
  static TextStyle get loadingTextStyle => TextStyle(
    color: secondaryText,
    fontStyle: FontStyle.italic,
  );

  // ==================== CONTAINER STYLES ====================
  
  /// Chat container decoration with border
  static BoxDecoration get chatContainerDecoration => BoxDecoration(
    color: whiteColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.shade200, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // ==================== ACTION BUTTONS ====================
  
  /// Get action button style for message actions
  static ButtonStyle get messageActionButtonStyle => IconButton.styleFrom(
    foregroundColor: primaryPurple,
    padding: const EdgeInsets.all(8),
  );
  
  /// Get action icon size
  static double get actionIconSize => 18;
  
  /// Get action button spacing
  static double get actionSpacing => 4;
}

/// Extension for convenient gradient usage on widgets
extension GradientDecoration on Widget {
  /// Wrap widget with primary gradient
  Widget withPrimaryGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: ConversionTheme.primaryGradient,
      ),
      child: this,
    );
  }
  
  /// Wrap widget with button gradient
  Widget withButtonGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: ConversionTheme.buttonGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ConversionTheme.primaryPurple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: this,
    );
  }
}

