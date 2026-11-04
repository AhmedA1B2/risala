import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomOceanRainBg extends StatefulWidget {
  const CustomOceanRainBg({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<CustomOceanRainBg> createState() => _CustomOceanRainBgState();
}

class _CustomOceanRainBgState extends State<CustomOceanRainBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _OceanPainter(_controller),
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ================================================
// Models
// ================================================

class _RainDrop {
  final double x;
  final double y;
  final double speed;
  final double length;
  final double opacity;

  const _RainDrop(
    this.x,
    this.y,
    this.speed,
    this.length,
    this.opacity,
  );
}

class _WaveMark {
  final double x;
  final double y;
  final double width;
  final double phase;

  const _WaveMark(
    this.x,
    this.y,
    this.width,
    this.phase,
  );
}

// ================================================
// Painter
// ================================================

class _OceanPainter extends CustomPainter {
  final Animation<double> animation;

  _OceanPainter(this.animation)
      : rain = _generateRain(),
        waveMarks = _generateWaveMarks(),
        super(repaint: animation);

  final List<_RainDrop> rain;
  final List<_WaveMark> waveMarks;

  static const double horizon = 0.65;

  // ==============================================
  // Generate Rain
  // ==============================================

  static List<_RainDrop> _generateRain() {
    final random = math.Random(42);

    return List.generate(95, (_) {
      return _RainDrop(
        random.nextDouble(),
        random.nextDouble(),
        0.55 + random.nextDouble() * 0.65,
        4 + random.nextDouble() * 5,
        0.18 + random.nextDouble() * 0.27,
      );
    });
  }

  // ==============================================
  // Generate Ocean Details
  // ==============================================

  static List<_WaveMark> _generateWaveMarks() {
    final random = math.Random(75);

    return List.generate(35, (_) {
      return _WaveMark(
        random.nextDouble(),
        horizon + random.nextDouble() * 0.47,
        5 + random.nextDouble() * 25,
        random.nextDouble() * math.pi * 2,
      );
    });
  }

  // ==============================================
  // Main Paint
  // ==============================================

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    _drawSky(canvas, size);
    _drawClouds(canvas, size, t);
    _drawOcean(canvas, size);
    _drawHorizon(canvas, size);
    _drawWaves(canvas, size, t);

    // Rain and water interaction
    _drawRainAndImpacts(canvas, size, t);

    _drawVignette(canvas, size);

    canvas.restore();
  }

  // ==============================================
  // Sky
  // ==============================================

  void _drawSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF010204),
            Color(0xFF101F2C),
            Color(0xFF1B303D),
            Color(0xFF263D49),
          ],
          stops: [0.0, 0.35, 0.75, 1.0],
        ).createShader(rect),
    );
  }

  // ==============================================
  // Clouds
  // ==============================================

  void _drawClouds(
    Canvas canvas,
    Size size,
    double t,
  ) {
    final movement = math.sin(t * math.pi * 2) * size.width * 0.012;

    _drawCloud(
      canvas,
      size,
      movement,
      0.17,
      0.40,
      const Color(0xFF101C27),
    );

    _drawCloud(
      canvas,
      size,
      -movement * 1.5,
      0.33,
      0.33,
      const Color(0xFF172631),
    );

    _drawCloud(
      canvas,
      size,
      movement * 0.6,
      0.43,
      0.22,
      const Color(0xFF1B2D38),
    );
  }

  void _drawCloud(
    Canvas canvas,
    Size size,
    double movement,
    double y,
    double height,
    Color color,
  ) {
    final x = size.width * 0.5 + movement;

    final rect = Rect.fromLTWH(
      -size.width * 0.1,
      size.height * y,
      size.width * 1.2,
      size.height * height,
    );

    final path = Path()
      ..moveTo(rect.left, rect.top + rect.height * 0.5)
      ..cubicTo(
        rect.left + rect.width * 0.18,
        rect.top - rect.height * 0.05,
        x - rect.width * 0.13,
        rect.top + rect.height * 0.22,
        x,
        rect.top + rect.height * 0.35,
      )
      ..cubicTo(
        x + rect.width * 0.20,
        rect.top - rect.height * 0.12,
        rect.right - rect.width * 0.12,
        rect.top + rect.height * 0.15,
        rect.right,
        rect.top + rect.height * 0.55,
      )
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = color,
    );
  }

  // ==============================================
  // Ocean
  // ==============================================

  void _drawOcean(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      size.height * horizon,
      size.width,
      size.height * (1 - horizon),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF142B37),
            Color(0xFF0D2431),
            Color(0xFF091B27),
            Color(0xFF06131F),
          ],
          stops: [0.0, 0.35, 0.72, 1.0],
        ).createShader(rect),
    );
  }

  // ==============================================
  // Horizon
  // ==============================================

  void _drawHorizon(Canvas canvas, Size size) {
    final y = size.height * horizon;

    canvas.drawRect(
      Rect.fromLTWH(0, y, size.width, 1.2),
      Paint()..color = const Color(0x334F7181),
    );
  }

  // ==============================================
  // Ocean Waves
  // ==============================================

  void _drawWaves(
    Canvas canvas,
    Size size,
    double t,
  ) {
    final waterTop = size.height * horizon;

    // Gentle moving waves
    for (int i = 0; i < 10; i++) {
      final depth = i / 10;

      final y = waterTop + size.height * (0.025 + depth * 0.42);

      final amplitude = 1.2 + depth * 3.5;

      final path = Path();

      for (int j = 0; j <= 14; j++) {
        final x = size.width * j / 14;

        final wave = math.sin(
          j * 0.85 + t * math.pi * 2 + i,
        );

        final vertical = y + wave * amplitude;

        if (j == 0) {
          path.moveTo(x, vertical);
        } else {
          path.lineTo(x, vertical);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = Color.fromARGB(
            (15 + depth * 35).round(),
            158,
            193,
            204,
          )
          ..strokeWidth = 0.7
          ..style = PaintingStyle.stroke,
      );
    }

    // Horizontal reflections
    for (final mark in waveMarks) {
      final movement = math.sin(
            t * math.pi * 2 + mark.phase,
          ) *
          0.008;

      final x = (mark.x + movement) % 1.0;

      canvas.drawLine(
        Offset(
          x * size.width,
          mark.y * size.height,
        ),
        Offset(
          x * size.width + mark.width,
          mark.y * size.height + 0.5,
        ),
        Paint()
          ..color = const Color(0x336E99A9)
          ..strokeWidth = 0.8,
      );
    }
  }

  // ==============================================
  // Rain + Actual Water Impact
  // ==============================================

  void _drawRainAndImpacts(
    Canvas canvas,
    Size size,
    double t,
  ) {
    final waterY = size.height * horizon;

    // Rain is clipped above the ocean.
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        waterY,
      ),
    );

    for (int i = 0; i < rain.length; i++) {
      final drop = rain[i];

      // Position of the drop
      final progress = (drop.y + t * drop.speed * 1.25) % 1.0;

      final x = (drop.x * size.width + t * size.width * 0.018) % size.width;

      final y = progress * size.height;

      // Very slight wind direction
      final windOffset = drop.length * 0.09;

      // Short, thin rain streak
      canvas.drawLine(
        Offset(x, y),
        Offset(
          x - windOffset,
          y + drop.length,
        ),
        Paint()
          ..color = Color.fromARGB(
            (drop.opacity * 255).round(),
            190,
            215,
            226,
          )
          ..strokeWidth = 0.55
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.restore();

    // ==========================================
    // Rain hitting the ocean
    // ==========================================

    for (int i = 0; i < rain.length; i += 2) {
      final drop = rain[i];

      final progress = (drop.y + t * drop.speed * 1.25) % 1.0;

      // Impact happens when the drop reaches the horizon.
      final impactAge = progress - horizon;

      if (impactAge < 0 || impactAge > 0.10) {
        continue;
      }

      // Ripple expands and fades after impact.
      final rippleProgress = impactAge / 0.10;

      final opacity = (math.sin(rippleProgress * math.pi) * 95).round();

      if (opacity <= 0) continue;

      final x = (drop.x * size.width + t * size.width * 0.018) % size.width;

      final center = Offset(
        x,
        waterY + 1.5,
      );

      final rippleWidth = 2.0 + rippleProgress * 12.0;
      final rippleHeight = 1.0 + rippleProgress * 2.5;

      // Small expanding water ring
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: rippleWidth,
          height: rippleHeight,
        ),
        Paint()
          ..color = Color.fromARGB(
            opacity,
            166,
            207,
            222,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.65,
      );

      // Tiny splash at the exact impact point
      if (rippleProgress < 0.22) {
        canvas.drawCircle(
          center,
          0.7,
          Paint()
            ..color = Color.fromARGB(
              (opacity * 0.8).round(),
              195,
              222,
              230,
            ),
        );
      }
    }
  }

  // ==============================================
  // Dark Edges
  // ==============================================

  void _drawVignette(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [
            Color(0x00000000),
            Color(0x33000000),
            Color(0x77000000),
          ],
          stops: [0.4, 0.78, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(
    covariant _OceanPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}
