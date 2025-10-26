import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class CustomSnackBar extends StatelessWidget {
  const CustomSnackBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: blackColor, width: 2),
        borderRadius: BorderRadius.circular(20),
        color: scandColor,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: mainColor,
          fontSize: quranfontSize,
        ),
      ),
    );
  }
}
