import 'dart:async';
import 'package:flutter/material.dart';
import 'package:risala/custom/custom_loading/custom_loading_itme/custom_loading_circle_for_animation2.dart';
import 'package:risala/vars/colors.dart';

class CustomLoadingScreen2 extends StatefulWidget {
  const CustomLoadingScreen2({super.key});

  @override
  State<CustomLoadingScreen2> createState() => _CustomLoadingScreen2State();
}

class _CustomLoadingScreen2State extends State<CustomLoadingScreen2>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final Animation<double> _animation1;
  late final Animation<double> _animation2;

  final Curve _curve = Curves.linearToEaseOut;

  final double _begin1 = 60;
  final double _end1 = -20;
  final double _begin2 = -60;
  final double _end2 = 20;

  Timer? _timer2;

  @override
  void initState() {
    super.initState();

    // تهيئة الكونترولرات
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // تهيئة الحركات
    _animation1 = Tween<double>(begin: _begin1, end: _end1)
        .animate(CurvedAnimation(parent: _controller1, curve: _curve));

    _animation2 = Tween<double>(begin: _begin2, end: _end2)
        .animate(CurvedAnimation(parent: _controller2, curve: _curve));

    // تشغيل متدرج مع حماية من الأخطاء
    _controller1.repeat(reverse: true);

    _timer2 = Timer(const Duration(milliseconds: 200), () {
      if (mounted) _controller2.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _timer2?.cancel();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام AnimatedBuilder لتقليل استهلاك setState()
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) => Transform.translate(
              offset: Offset(_animation1.value, 0),
              child: child,
            ),
            child: CustomLoadingCircleForAnimation2(color: mainColor),
          ),
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) => Transform.translate(
              offset: Offset(_animation2.value, 0),
              child: child,
            ),
            child: CustomLoadingCircleForAnimation2(color: scandColor),
          ),
        ],
      ),
    );
  }
}
