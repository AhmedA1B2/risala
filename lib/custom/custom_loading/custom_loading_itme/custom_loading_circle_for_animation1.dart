import 'package:flutter/material.dart';

class CustomLoadingCircle extends StatelessWidget {
  const CustomLoadingCircle({super.key, required this.animation, this.child});

  final Animation<double> animation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value), // ✅ نستخدم القيمة هنا
          child: child,
        );
      },
      child: child,
    );
  }
}
