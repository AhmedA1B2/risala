import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class CustomTextTitleForTheme extends StatefulWidget {
  const CustomTextTitleForTheme(
      {super.key, required this.text, required this.sizeOfFont});

  final String text;
  final int sizeOfFont;

  @override
  State<CustomTextTitleForTheme> createState() =>
      _CustomTextTitleForThemeState();
}

class _CustomTextTitleForThemeState extends State<CustomTextTitleForTheme> {
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
            fontSize: widget.sizeOfFont == 2
                ? mytitlefontSize / widget.sizeOfFont + 10
                : widget.sizeOfFont == 3
                    ? mytitlefontSize / widget.sizeOfFont + 8
                    : mytitlefontSize,
            color: scandColor,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
