import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomButtonText extends StatelessWidget {
  const CustomButtonText(
      {super.key, this.onPressed, required this.text, required this.color});
  final String text;
  final void Function()? onPressed;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shadowColor: blackColor,
      elevation: 2,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: blackColor),
        ),
      ),
    );
  }
}
