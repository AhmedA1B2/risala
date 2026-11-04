import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CustomNightSkyBg extends StatefulWidget {
  const CustomNightSkyBg({
    super.key,
    this.showMoon = true,
    required this.child,
  });

  final bool showMoon;
  final Widget child;

  @override
  State<CustomNightSkyBg> createState() => _CustomNightSkyBgState();
}

class _CustomNightSkyBgState extends State<CustomNightSkyBg>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _NightSkyPainter(
          _controller,
          showMoon: widget.showMoon,
        ),
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

// --------------------------------------------------
// Star model
// --------------------------------------------------

class _Star {
  final double x;
  final double y;
  final double radius;
  final double phase;
  final double speed;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}

// --------------------------------------------------
// Meteor model
// --------------------------------------------------

class _Meteor {
  final double phase;
  final double x;
  final double y;
  final double dx;
  final double dy;

  const _Meteor({
    required this.phase,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
  });
}

// --------------------------------------------------
// Night sky painter
// --------------------------------------------------

class _NightSkyPainter extends CustomPainter {
  final Animation<double> animation;
  final bool showMoon;

  _NightSkyPainter(
    this.animation, {
    required this.showMoon,
  })  : stars = _generateStars(),
        super(repaint: animation);

  final List<_Star> stars;

  static const List<_Meteor> meteors = [
    _Meteor(
      phase: 0.06,
      x: 0.90,
      y: 0.12,
      dx: -0.42,
      dy: 0.28,
    ),
    _Meteor(
      phase: 0.30,
      x: 0.65,
      y: 0.08,
      dx: -0.34,
      dy: 0.24,
    ),
    _Meteor(
      phase: 0.54,
      x: 0.98,
      y: 0.35,
      dx: -0.38,
      dy: 0.25,
    ),
    _Meteor(
      phase: 0.78,
      x: 0.22,
      y: 0.20,
      dx: 0.38,
      dy: 0.27,
    ),
  ];

  static List<_Star> _generateStars() {
    final random = math.Random(42);

    return List.generate(170, (index) {
      return _Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.85,
        radius: 0.35 + random.nextDouble() * 1.0,
        phase: random.nextDouble() * math.pi * 2,
        speed: 0.5 + random.nextDouble() * 2.5,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final rect = Offset.zero & size;

    // Background gradient
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF020611),
            Color(0xFF07152D),
            Color(0xFF0C2140),
            Color(0xFF071426),
          ],
          stops: [0.0, 0.40, 0.80, 1.0],
        ).createShader(rect),
    );

    // Subtle blue atmospheric glow
    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.85),
      radius: size.width * 0.85,
    );

    canvas.drawCircle(
      glowRect.center,
      glowRect.width / 2,
      Paint()
        ..shader = ui.Gradient.radial(
          glowRect.center,
          glowRect.width / 2,
          [
            const Color(0x182B659F),
            const Color(0x00000000),
          ],
        ),
    );

    // Moon
    if (showMoon) {
      _drawMoon(canvas, size);
    }

    // Stars
    _drawStars(canvas, size, t);

    // Moving clouds
    _drawCloudBank(
      canvas,
      size,
      t,
      0.12,
      0.70,
      0.9,
      1.0,
      18,
    );

    _drawCloudBank(
      canvas,
      size,
      t,
      0.55,
      0.83,
      1.1,
      0.8,
      22,
    );

    _drawCloudBank(
      canvas,
      size,
      t,
      0.20,
      0.94,
      1.3,
      1.2,
      24,
    );

    // Shooting stars
    _drawMeteors(canvas, size, t);
  }

  // ------------------------------------------------
  // Moon
  // ------------------------------------------------

  void _drawMoon(Canvas canvas, Size size) {
    final center = Offset(
      size.width * 0.80,
      size.height * 0.19,
    );

    const radius = 19.0;

    canvas.drawCircle(
      center,
      radius * 3.0,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius * 3.0,
          [
            const Color(0x28D7E8FF),
            const Color(0x00D7E8FF),
          ],
        ),
    );

    final moon = Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: radius),
      );

    final shadow = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(-radius * 0.43, -radius * 0.10),
          radius: radius * 0.92,
        ),
      );

    final crescent = Path.combine(
      PathOperation.difference,
      moon,
      shadow,
    );

    canvas.drawPath(
      crescent,
      Paint()
        ..shader = ui.Gradient.linear(
          center.translate(-radius, -radius),
          center.translate(radius, radius),
          const [
            Color(0xFFB9CBE8),
            Color(0xFFFFFFFF),
          ],
        ),
    );
  }

  // ------------------------------------------------
  // Stars with twinkling effect
  // ------------------------------------------------

  void _drawStars(Canvas canvas, Size size, double t) {
    for (final star in stars) {
      final twinkle =
          (math.sin(t * math.pi * 2 * star.speed + star.phase) + 1) / 2;

      final opacity = 0.25 + twinkle * 0.75;

      final center = Offset(
        star.x * size.width,
        star.y * size.height,
      );

      final color = Color.fromARGB(
        (opacity * 255).round(),
        220,
        233,
        255,
      );

      canvas.drawCircle(
        center,
        star.radius,
        Paint()..color = color,
      );

      // Small light cross on some brighter stars
      if (star.radius > 1.05) {
        final flarePaint = Paint()
          ..color = Color.fromARGB(
            (opacity * 85).round(),
            190,
            215,
            255,
          )
          ..strokeWidth = 0.6;

        canvas.drawLine(
          center.translate(-3, 0),
          center.translate(3, 0),
          flarePaint,
        );

        canvas.drawLine(
          center.translate(0, -3),
          center.translate(0, 3),
          flarePaint,
        );
      }
    }
  }

  // ------------------------------------------------
  // Moving clouds
  // ------------------------------------------------

  void _drawCloudBank(
    Canvas canvas,
    Size size,
    double t,
    double baseX,
    double baseY,
    double scale,
    double speed,
    int alpha,
  ) {
    final drift = baseX + math.sin(t * math.pi * 2 * speed + baseX * 7) * 0.025;

    final verticalMovement = math.sin(t * math.pi * 2 + baseX * 8) * 0.008;

    const puffs = [
      [0.0, 0.0, 0.32, 0.05],
      [0.12, -0.025, 0.25, 0.075],
      [-0.12, 0.015, 0.25, 0.065],
      [0.02, 0.025, 0.38, 0.045],
      [0.22, 0.01, 0.20, 0.04],
    ];

    for (int i = 0; i < puffs.length; i++) {
      final puff = puffs[i];

      final center = Offset(
        (drift + puff[0] * scale) * size.width,
        (baseY + verticalMovement + puff[1] * scale) * size.height,
      );

      final cloudRect = Rect.fromCenter(
        center: center,
        width: size.width * puff[2] * scale,
        height: size.height * puff[3] * scale,
      );

      canvas.drawOval(
        cloudRect,
        Paint()
          ..color = Color.fromARGB(
            alpha,
            140,
            160,
            190,
          )
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            22 * scale,
          ),
      );
    }
  }

  // ------------------------------------------------
  // Shooting stars
  // ------------------------------------------------

  void _drawMeteors(Canvas canvas, Size size, double t) {
    const meteorDuration = 0.045;

    for (final meteor in meteors) {
      final elapsed = (t - meteor.phase + 1.0) % 1.0;

      if (elapsed >= meteorDuration) continue;

      final progress = elapsed / meteorDuration;

      final opacity = math.sin(progress * math.pi).clamp(0.0, 1.0).toDouble();

      final head = Offset(
        (meteor.x + meteor.dx * progress) * size.width,
        (meteor.y + meteor.dy * progress) * size.height,
      );

      final direction = Offset(
        meteor.dx * size.width,
        meteor.dy * size.height,
      );

      final length = math.sqrt(
        direction.dx * direction.dx + direction.dy * direction.dy,
      );

      final unit = Offset(
        direction.dx / length,
        direction.dy / length,
      );

      final tailLength = math.max(85.0, size.width * 0.20);

      final tail = head - unit * tailLength;

      // Outer glow
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..color = Color.fromARGB(
            (opacity * 100).round(),
            180,
            210,
            255,
          )
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            6,
          ),
      );

      // Bright meteor trail
      canvas.drawLine(
        tail,
        head,
        Paint()
          ..shader = ui.Gradient.linear(
            tail,
            head,
            [
              const Color(0x00DCEBFF),
              Color.fromARGB(
                (opacity * 255).round(),
                230,
                242,
                255,
              ),
            ],
          )
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );

      // Bright head
      canvas.drawCircle(
        head,
        2.2,
        Paint()
          ..color = Color.fromARGB(
            (opacity * 255).round(),
            255,
            255,
            255,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.showMoon != showMoon;
  }
}
