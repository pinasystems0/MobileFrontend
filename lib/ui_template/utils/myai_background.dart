import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class MyAIBackground extends StatefulWidget {
  final Widget child;

  const MyAIBackground({
    super.key,
    required this.child,
  });

  @override
  State<MyAIBackground> createState() => _MyAIBackgroundState();
}

class _MyAIBackgroundState extends State<MyAIBackground>
    with TickerProviderStateMixin {
  late AnimationController _blobController;
  late AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();

    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    // Phase 1: keep stars exactly as before; do not freeze twinkling.
    // (Do not call repeat() here.)
    _blobController.value = 0;
  }

  @override
  void dispose() {
    _blobController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Minimal logging for Phase 1 diagnostic.
    debugPrint('MyAIBackground build');
    final size = MediaQuery.of(context).size;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Animated purple blob background
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _BgPainter(_blobController.value),
              );
            },
          ),

          // ── Twinkling stars on top
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _twinkleController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: StarPainter(
                    time: _twinkleController.value * math.pi * 2,
                    size: size,
                  ),
                );
              },
            ),
          ),

          // ── Child UI
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated Purple Background Painter
// ─────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final double t;

  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Base deep purple gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFF1A0533),
          Color(0xFF2D0B6B),
          Color(0xFF3B0FA8),
          Color(0xFF1A0533),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // Blob 1 — top left violet
    _drawBlob(
      canvas,
      Offset(
        size.width * (0.1 + 0.08 * math.sin(t * math.pi * 2)),
        size.height * (0.15 + 0.06 * math.cos(t * math.pi * 2)),
      ),
      size.width * 0.55,
      const Color(0xFF7B2FBE),
      0.55,
    );

    // Blob 2 — center right cyan
    _drawBlob(
      canvas,
      Offset(
        size.width * (0.75 + 0.06 * math.cos(t * math.pi * 2)),
        size.height * (0.35 + 0.08 * math.sin(t * math.pi * 2 + 1)),
      ),
      size.width * 0.45,
      const Color(0xFF4A90D9),
      0.40,
    );

    // Blob 3 — bottom center pink
    _drawBlob(
      canvas,
      Offset(
        size.width * (0.45 + 0.05 * math.sin(t * math.pi * 2 + 2)),
        size.height * (0.75 + 0.05 * math.cos(t * math.pi * 2 + 2)),
      ),
      size.width * 0.50,
      const Color(0xFFBB44FF),
      0.38,
    );

    // Subtle glass sheen overlay
    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.07),
          Colors.transparent,
          Colors.white.withOpacity(0.03),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      sheen,
    );
  }

  void _drawBlob(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double opacity,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BgPainter oldDelegate) =>
      oldDelegate.t != t;
}

// ─────────────────────────────────────────────
// Twinkling Stars Painter
// ─────────────────────────────────────────────
class StarPainter extends CustomPainter {
  final double time;
  final Size size;

  StarPainter({
    required this.time,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * this.size.width;
      final y = random.nextDouble() * this.size.height;

      final opacity = 0.2 + math.sin(time + i * 0.7) * 0.25;
      paint.color = Colors.white.withOpacity(opacity.clamp(0.05, 0.55));

      final radius = 0.8 + (i % 3) * 0.35;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) =>
      oldDelegate.time != time;
}