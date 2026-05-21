import 'dart:math';
import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class IslamicAnimatedBackground extends StatefulWidget {
  const IslamicAnimatedBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<IslamicAnimatedBackground> createState() =>
      _IslamicAnimatedBackgroundState();
}

class _IslamicAnimatedBackgroundState extends State<IslamicAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🎨 1. الخلفية الأساسية باللون البني الخاص بك
        Container(color: whiteColor),

        // 🌟 2. الـ Glow الناعم
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    mainColor,
                    scandColor,
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🖼️ 3. النقوش المتحركة (تم حصر الـ AnimatedBuilder هنا ليعيد بناء نفسه فقط دون التأثير على التطبيق)
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return _ImagePattern(animationValue: _controller.value);
              },
            ),
          ),
        ),

        // 📦 4. محتوى الصفحات الحالية (خارج الـ AnimatedBuilder تماماً لضمان أداء خارق)
        widget.child,
      ],
    );
  }
}

// قمنا بإعادة الـ Widget الأصلي الخاص بك لأنه سليم ومضمون العرض
class _ImagePattern extends StatelessWidget {
  final double animationValue;

  const _ImagePattern({required this.animationValue});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // حماية إضافية: لمنع أي حسابات خاطئة أو قيم صفرية أثناء بدء تشغيل التطبيق
        final maxWidth =
            constraints.maxWidth > 0 ? constraints.maxWidth : 100.0;
        final maxHeight =
            constraints.maxHeight > 0 ? constraints.maxHeight : 100.0;

        return Stack(
          children: List.generate(60, (index) {
            final x = (index * 80.0) % maxWidth;
            final y = (index * 140.0) % maxHeight;

            final offsetX = sin(animationValue * 2 + index) * 10;
            final offsetY = cos(animationValue * 2 + index) * 10;

            return Positioned(
              left: x + offsetX,
              top: y + offsetY,
              child: Transform.rotate(
                angle: index % 2 == 0 ? 0.4 : -0.4,
                child: Image.asset(
                  "assets/images/islamicDecoration.png",
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
