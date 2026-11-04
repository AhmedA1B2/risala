import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomMinecraftNightBg extends StatefulWidget {
  const CustomMinecraftNightBg({super.key, required this.child});
  final Widget child;
  @override
  State<CustomMinecraftNightBg> createState() => _CustomMinecraftNightBgState();
}

class _CustomMinecraftNightBgState extends State<CustomMinecraftNightBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _MinecraftNightPainter(_controller),
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

class _Star {
  final double x;
  final double y;
  final double radius;
  final double phase;

  const _Star(this.x, this.y, this.radius, this.phase);
}

class _Firefly {
  final double x;
  final double y;
  final double phase;
  final double speed;

  const _Firefly(this.x, this.y, this.phase, this.speed);
}

class _GrassMark {
  final double x;
  final double y;
  final double height;

  const _GrassMark(this.x, this.y, this.height);
}

// ================================================
// Painter
// ================================================

class _MinecraftNightPainter extends CustomPainter {
  final Animation<double> animation;

  _MinecraftNightPainter(this.animation)
      : stars = _createStars(),
        fireflies = _createFireflies(),
        grassMarks = _createGrassMarks(),
        super(repaint: animation);

  final List<_Star> stars;
  final List<_Firefly> fireflies;
  final List<_GrassMark> grassMarks;

  // ==============================================
  // Generate objects only once
  // ==============================================

  static List<_Star> _createStars() {
    final random = math.Random(15);

    return List.generate(
      30,
      (_) => _Star(
        random.nextDouble(),
        random.nextDouble() * 0.52,
        0.4 + random.nextDouble() * 0.8,
        random.nextDouble() * math.pi * 2,
      ),
    );
  }

  static List<_Firefly> _createFireflies() {
    final random = math.Random(25);

    return List.generate(
      5,
      (_) => _Firefly(
        0.12 + random.nextDouble() * 0.76,
        0.62 + random.nextDouble() * 0.22,
        random.nextDouble() * math.pi * 2,
        0.6 + random.nextDouble() * 0.8,
      ),
    );
  }

  static List<_GrassMark> _createGrassMarks() {
    final random = math.Random(35);

    return List.generate(
      22,
      (_) => _GrassMark(
        random.nextDouble(),
        0.79 + random.nextDouble() * 0.20,
        3 + random.nextDouble() * 8,
      ),
    );
  }

  // ==============================================
  // Main Paint
  // ==============================================

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    _drawSky(canvas, size);
    _drawStars(canvas, size, t);
    _drawMoon(canvas, size);
    _drawMountains(canvas, size);
    _drawGround(canvas, size);

    // Distant trees
    _drawSmallTree(
      canvas,
      size,
      size.width * 0.13,
      size.height * 0.77,
      0.43,
    );

    _drawSmallTree(
      canvas,
      size,
      size.width * 0.88,
      size.height * 0.77,
      0.55,
    );

    // Main Minecraft tree
    _drawMainTree(canvas, size, t);

    // Tiny grass details
    _drawGrassDetails(canvas, size);

    // Animated fireflies
    _drawFireflies(canvas, size, t);

    // Dark foreground
    _drawVignette(canvas, size);
  }

  // ==============================================
  // Night Sky
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
            Color(0xFF020609),
            Color(0xFF06100A),
            Color(0xFF0A1A0C),
            Color(0xFF0B200D),
          ],
          stops: [0.0, 0.45, 0.75, 1.0],
        ).createShader(rect),
    );
  }

  // ==============================================
  // Stars
  // ==============================================

  void _drawStars(Canvas canvas, Size size, double t) {
    for (final star in stars) {
      final brightness =
          0.45 + 0.55 * ((math.sin(t * math.pi * 2 + star.phase) + 1) / 2);

      canvas.drawCircle(
        Offset(
          star.x * size.width,
          star.y * size.height,
        ),
        star.radius,
        Paint()
          ..color = Color.fromARGB(
            (brightness * 190).round(),
            192,
            213,
            185,
          ),
      );
    }
  }

  // ==============================================
  // Pixel Moon
  // ==============================================

  void _drawMoon(Canvas canvas, Size size) {
    final unit = size.shortestSide * 0.018;

    final x = size.width * 0.78;
    final y = size.height * 0.16;

    // Soft ambient light without blur filters
    canvas.drawCircle(
      Offset(x + unit * 2, y + unit * 2),
      unit * 5,
      Paint()..color = const Color(0x105F8B52),
    );

    final blocks = [
      [2, 0],
      [3, 0],
      [1, 1],
      [2, 1],
      [3, 1],
      [0, 2],
      [1, 2],
      [2, 2],
      [0, 3],
      [1, 3],
      [2, 3],
      [1, 4],
      [2, 4],
    ];

    for (final block in blocks) {
      canvas.drawRect(
        Rect.fromLTWH(
          x + block[0] * unit,
          y + block[1] * unit,
          unit,
          unit,
        ),
        Paint()..color = const Color(0xFFC6D7AC),
      );
    }
  }

  // ==============================================
  // Mountains / Distant Landscape
  // ==============================================

  void _drawMountains(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.68)
      ..lineTo(size.width * 0.18, size.height * 0.59)
      ..lineTo(size.width * 0.32, size.height * 0.68)
      ..lineTo(size.width * 0.49, size.height * 0.56)
      ..lineTo(size.width * 0.68, size.height * 0.67)
      ..lineTo(size.width * 0.83, size.height * 0.60)
      ..lineTo(size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF07130A),
    );
  }

  // ==============================================
  // Ground
  // ==============================================

  void _drawGround(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      size.height * 0.68,
      size.width,
      size.height * 0.32,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF102512),
            Color(0xFF0B1B0C),
            Color(0xFF061008),
          ],
        ).createShader(rect),
    );

    // A subtle grassy horizon
    final horizon = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.72,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      horizon,
      Paint()..color = const Color(0xFF0B1D0C),
    );
  }

  // ==============================================
  // Small Distant Block Trees
  // ==============================================

  void _drawSmallTree(
    Canvas canvas,
    Size size,
    double x,
    double groundY,
    double scale,
  ) {
    final s = size.shortestSide * 0.026 * scale;

    // Trunk
    canvas.drawRect(
      Rect.fromLTWH(
        x - s * 0.35,
        groundY - s * 2.5,
        s * 0.7,
        s * 2.5,
      ),
      Paint()..color = const Color(0xFF211A0D),
    );

    // Cubic foliage
    final leaves = [
      Rect.fromLTWH(x - s * 1.5, groundY - s * 5.2, s * 3, s * 1.6),
      Rect.fromLTWH(x - s * 2, groundY - s * 4.1, s * 4, s * 1.7),
      Rect.fromLTWH(x - s * 1.5, groundY - s * 3.0, s * 3, s * 1.5),
    ];

    for (int i = 0; i < leaves.length; i++) {
      canvas.drawRect(
        leaves[i],
        Paint()
          ..color =
              i.isEven ? const Color(0xFF0B260F) : const Color(0xFF103014),
      );
    }
  }

  // ==============================================
  // Main Minecraft Tree
  // ==============================================

  void _drawMainTree(
    Canvas canvas,
    Size size,
    double t,
  ) {
    final cx = size.width * 0.5;
    final groundY = size.height * 0.785;

    final treeW = size.width * 0.46;
    final treeH = size.height * 0.42;

    final top = groundY - treeH;

    final trunkW = size.width * 0.075;
    final trunkTop = top + treeH * 0.43;

    // Ground shadow beneath the tree
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY + 3),
        width: treeW * 0.72,
        height: size.height * 0.025,
      ),
      Paint()..color = const Color(0xFF040B05),
    );

    // Trunk
    canvas.drawRect(
      Rect.fromLTWH(
        cx - trunkW / 2,
        trunkTop,
        trunkW,
        groundY - trunkTop,
      ),
      Paint()..color = const Color(0xFF302311),
    );

    // Trunk shading
    canvas.drawRect(
      Rect.fromLTWH(
        cx - trunkW / 2,
        trunkTop,
        trunkW * 0.32,
        groundY - trunkTop,
      ),
      Paint()..color = const Color(0xFF1F180D),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        cx + trunkW * 0.20,
        trunkTop + treeH * 0.13,
        trunkW * 0.23,
        treeH * 0.14,
      ),
      Paint()..color = const Color(0xFF543A1C),
    );

    // Branches
    final branchPaint = Paint()..color = const Color(0xFF302311);

    canvas.drawRect(
      Rect.fromLTWH(
        cx - treeW * 0.29,
        top + treeH * 0.48,
        treeW * 0.29,
        trunkW * 0.55,
      ),
      branchPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        cx,
        top + treeH * 0.49,
        treeW * 0.29,
        trunkW * 0.55,
      ),
      branchPaint,
    );

    // Gentle wind
    final wind = math.sin(t * math.pi * 2) * 1.8;

    canvas.save();
    canvas.translate(wind, 0);

    // Pixelated leaf blocks
    final leafBlocks = [
      Rect.fromLTWH(
        cx - treeW * 0.14,
        top,
        treeW * 0.28,
        treeH * 0.17,
      ),
      Rect.fromLTWH(
        cx - treeW * 0.30,
        top + treeH * 0.13,
        treeW * 0.29,
        treeH * 0.18,
      ),
      Rect.fromLTWH(
        cx - treeW * 0.15,
        top + treeH * 0.15,
        treeW * 0.30,
        treeH * 0.20,
      ),
      Rect.fromLTWH(
        cx + treeW * 0.01,
        top + treeH * 0.13,
        treeW * 0.29,
        treeH * 0.18,
      ),
      Rect.fromLTWH(
        cx - treeW * 0.39,
        top + treeH * 0.29,
        treeW * 0.31,
        treeH * 0.17,
      ),
      Rect.fromLTWH(
        cx - treeW * 0.23,
        top + treeH * 0.30,
        treeW * 0.46,
        treeH * 0.19,
      ),
      Rect.fromLTWH(
        cx + treeW * 0.08,
        top + treeH * 0.29,
        treeW * 0.31,
        treeH * 0.17,
      ),
      Rect.fromLTWH(
        cx - treeW * 0.27,
        top + treeH * 0.44,
        treeW * 0.25,
        treeH * 0.14,
      ),
      Rect.fromLTWH(
        cx + treeW * 0.02,
        top + treeH * 0.44,
        treeW * 0.25,
        treeH * 0.14,
      ),
      Rect.fromLTWH(
        cx - treeW * 0.12,
        top + treeH * 0.46,
        treeW * 0.24,
        treeH * 0.15,
      ),
    ];

    const leafColors = [
      Color(0xFF102F16),
      Color(0xFF17401C),
      Color(0xFF1A4920),
      Color(0xFF123618),
      Color(0xFF0D2911),
      Color(0xFF204D25),
      Color(0xFF143B19),
      Color(0xFF0F3015),
      Color(0xFF17421D),
      Color(0xFF1B451F),
    ];

    for (int i = 0; i < leafBlocks.length; i++) {
      canvas.drawRect(
        leafBlocks[i],
        Paint()..color = leafColors[i],
      );
    }

    // Pixel details on leaves
    final u = treeW * 0.055;

    final details = [
      [cx - treeW * 0.20, top + treeH * 0.20],
      [cx + treeW * 0.12, top + treeH * 0.23],
      [cx - treeW * 0.29, top + treeH * 0.37],
      [cx + treeW * 0.27, top + treeH * 0.37],
      [cx - treeW * 0.08, top + treeH * 0.38],
      [cx + treeW * 0.08, top + treeH * 0.51],
    ];

    for (int i = 0; i < details.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          details[i][0],
          details[i][1],
          u,
          u,
        ),
        Paint()
          ..color =
              i.isEven ? const Color(0xFF28552B) : const Color(0xFF0A2510),
      );
    }

    canvas.restore();
  }

  // ==============================================
  // Small Grass Details
  // ==============================================

  void _drawGrassDetails(Canvas canvas, Size size) {
    for (final mark in grassMarks) {
      final x = mark.x * size.width;
      final y = mark.y * size.height;

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          y - mark.height,
          1.3,
          mark.height,
        ),
        Paint()..color = const Color(0xFF18391B),
      );

      canvas.drawRect(
        Rect.fromLTWH(
          x + 2,
          y - mark.height * 0.6,
          1.2,
          mark.height * 0.6,
        ),
        Paint()..color = const Color(0xFF234724),
      );
    }
  }

  // ==============================================
  // Animated Fireflies
  // ==============================================

  void _drawFireflies(
    Canvas canvas,
    Size size,
    double t,
  ) {
    for (final fly in fireflies) {
      final angle = t * math.pi * 2 * fly.speed + fly.phase;

      final x = fly.x * size.width + math.sin(angle) * size.width * 0.012;

      final y = fly.y * size.height + math.cos(angle) * size.height * 0.009;

      final brightness = (math.sin(angle * 1.5) + 1) / 2;

      final alpha = (brightness * 180).round();

      final center = Offset(x, y);

      // Small glow
      canvas.drawCircle(
        center,
        3.5,
        Paint()
          ..color = Color.fromARGB(
            (alpha * 0.20).round(),
            155,
            230,
            92,
          ),
      );

      // Bright pixel
      canvas.drawRect(
        Rect.fromCenter(
          center: center,
          width: 2.0,
          height: 2.0,
        ),
        Paint()
          ..color = Color.fromARGB(
            alpha,
            205,
            255,
            130,
          ),
      );
    }
  }

  // ==============================================
  // Dark Screen Edges
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
            Color(0x44000000),
            Color(0x99000000),
          ],
          stops: [0.45, 0.78, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(
    covariant _MinecraftNightPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}
