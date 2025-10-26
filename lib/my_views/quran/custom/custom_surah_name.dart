import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomSurahName extends StatefulWidget {
  const CustomSurahName({super.key, required this.surahName});

  final String surahName;

  @override
  State<CustomSurahName> createState() => _CustomSurahNameState();
}

class _CustomSurahNameState extends State<CustomSurahName> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/surahBg.png",
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              widget.surahName,
              style: TextStyle(
                fontSize: 26,
                color: scandColor,
                fontFamily: 'Amiri',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
