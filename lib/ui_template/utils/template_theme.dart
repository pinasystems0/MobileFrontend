import 'package:flutter/material.dart';

class TemplateTheme {
  static const Color night = Color(0xFF121826);
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF8EA7FF);
  static const Color accent = Color(0xFFF77D8E);
  static const Color surface = Color(0xFFF7F8FE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A2033);
  static const Color textMuted = Color(0xFF6B738A);
  static const Color border = Color(0xFFDCE1F5);

  static const double radiusXl = 32;
  static const double radiusLg = 24;
  static const double radiusMd = 18;

  static final LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEEF2FF),
      Color(0xFFFDF7FB),
      Color(0xFFF3F7FF),
    ],
  );

  static BoxDecoration glassPanel({
    Color color = Colors.white,
    double opacity = 0.5,
    double radius = radiusXl,
    Color borderColor = const Color(0x66FFFFFF),
  }) {
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: night.withOpacity(0.08),
          blurRadius: 40,
          offset: const Offset(0, 24),
        ),
      ],
    );
  }

  static BoxDecoration softCard({
    Color color = card,
    Color borderColor = border,
    double radius = radiusLg,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: night.withOpacity(0.05),
          blurRadius: 22,
          offset: const Offset(0, 14),
        ),
      ],
    );
  }

  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      labelStyle: const TextStyle(
        color: textMuted,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static ButtonStyle primaryButtonStyle({
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle({
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: night,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  static ButtonStyle softButtonStyle({
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: textPrimary,
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(color: border),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

class TemplateBackdrop extends StatelessWidget {
  const TemplateBackdrop({
    super.key,
    required this.child,
    this.showRive = true,
  });

  final Widget child;
  final bool showRive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final topSplineWidth = width < 480 ? width * 0.78 : 320.0;
        final bottomSplineWidth = width < 480 ? width * 0.84 : 340.0;

        return Container(
          decoration: BoxDecoration(gradient: TemplateTheme.heroGradient),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              IgnorePointer(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -topSplineWidth * 0.24,
                      right: -topSplineWidth * 0.34,
                      child: Image.asset(
                        'assets/template/Backgrounds/Spline.png',
                        width: topSplineWidth,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: -bottomSplineWidth * 0.34,
                      left: -bottomSplineWidth * 0.26,
                      child: Opacity(
                        opacity: 0.88,
                        child: Image.asset(
                          'assets/template/Backgrounds/Spline.png',
                          width: bottomSplineWidth,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(child: child),
            ],
          ),
        );
      },
    );
  }
}
