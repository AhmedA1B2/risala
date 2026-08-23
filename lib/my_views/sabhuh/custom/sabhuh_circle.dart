import 'package:flutter/material.dart';

class SabhuhCircle extends StatelessWidget {
  const SabhuhCircle(
      {super.key, required this.inColor, required this.outColor});

  final Color inColor;
  final Color outColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
          color: inColor,
          border: Border.all(color: outColor, width: 3),
          shape: BoxShape.circle),
    );
  }
}
