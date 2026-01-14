import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomBlurBackground extends StatelessWidget {
  const CustomBlurBackground({super.key, required this.child, this.onTap});
  final Widget child;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 5),
        child: Container(
          color: blackColor.withOpacity(0.15),
          child: child,
        ),
      ),
    );
  }
}
