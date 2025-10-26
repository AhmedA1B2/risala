import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomTextFoDirections extends StatelessWidget {
  const CustomTextFoDirections(
      {super.key,
      required this.text,
      this.left,
      this.top,
      this.right,
      this.bottom});

  final String text;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Column(children: [
        Text(text,
            style:
                const TextStyle(color: whiteColor, fontWeight: FontWeight.bold))
      ]),
    );
  }
}
