import 'dart:async';
import 'package:flutter/material.dart';
import 'package:risala/custom/custom_loading/custom_loading_itme/custom_loading_circle_for_animation1.dart';
import 'package:risala/vars/colors.dart';

class CustomLoadingScreen1 extends StatefulWidget {
  const CustomLoadingScreen1({super.key});

  @override
  State<CustomLoadingScreen1> createState() => _CustomLoadingScreen1State();
}

class _CustomLoadingScreen1State extends State<CustomLoadingScreen1>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;
  late final Animation<double> _animation1;
  late final Animation<double> _animation2;
  late final Animation<double> _animation3;

  final Curve _curve = Curves.decelerate;
  final double _begin = 50;
  final double _end = -20;

  Timer? _timer2;
  Timer? _timer3;

  @override
  void initState() {
    super.initState();

    // إنشاء الكونترولرات
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // إعداد الحركات
    _animation1 = Tween<double>(begin: _begin, end: _end)
        .animate(CurvedAnimation(parent: _controller1, curve: _curve));
    _animation2 = Tween<double>(begin: _begin, end: _end)
        .animate(CurvedAnimation(parent: _controller2, curve: _curve));
    _animation3 = Tween<double>(begin: _begin, end: _end)
        .animate(CurvedAnimation(parent: _controller3, curve: _curve));

    // تشغيل الأنيميشن بشكل متدرّج
    _controller1.repeat(reverse: true);

    _timer2 = Timer(const Duration(milliseconds: 200), () {
      if (mounted) _controller2.repeat(reverse: true);
    });

    _timer3 = Timer(const Duration(milliseconds: 250), () {
      if (mounted) _controller3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    // إيقاف التايمرز إذا لم تُنفذ بعد
    _timer2?.cancel();
    _timer3?.cancel();

    // التخلص من الكونترولرات
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomLoadingCircle(animation: _animation1, child: _buildBall()),
            CustomLoadingCircle(animation: _animation2, child: _buildBall()),
            CustomLoadingCircle(animation: _animation3, child: _buildBall()),
          ],
        ),
      ),
    );
  }

  Widget _buildBall() {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        color: mainColor,
        shape: BoxShape.circle,
        border: Border.all(color: blackColor, width: 1.5),
      ),
    );
  }
}
