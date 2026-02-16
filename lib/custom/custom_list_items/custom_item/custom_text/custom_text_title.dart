import 'package:flutter/material.dart';
import 'package:risala/main.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class CustomTextTitle extends StatefulWidget {
  const CustomTextTitle({super.key, required this.text});

  final String text;

  @override
  State<CustomTextTitle> createState() => _CustomTextTitleState();
}

class _CustomTextTitleState extends State<CustomTextTitle> {
  int sizeOfTextBar = sharedPref.getInt("sizeOfTextBar") ?? 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: mytitlefontSize,
            color: scandColor,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
