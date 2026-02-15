import 'package:flutter/material.dart';

class CustomCircle extends StatelessWidget {
  const CustomCircle(
      {super.key,
      required this.outColor,
      required this.inColor,
      required this.borderColor,
      this.onTap});

  final Color borderColor;
  final Color outColor;
  final Color inColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: outColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2)),
        child: Container(
          margin: const EdgeInsets.all(12),
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: inColor, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
