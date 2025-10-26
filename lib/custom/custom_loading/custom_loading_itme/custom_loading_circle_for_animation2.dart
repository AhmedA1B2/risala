import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomLoadingCircleForAnimation2 extends StatelessWidget {
  const CustomLoadingCircleForAnimation2({super.key, this.color});
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 40,
      width: 40,
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: blackColor, width: 3),
      ),
    );
  }
}
