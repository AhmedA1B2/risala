import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class CustomTextTitle extends StatelessWidget {
  const CustomTextTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: mytitlefontSize,
          color: scandColor,
          fontFamily: 'Amiri',
        ),
      ),
    );
  }
}
