import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomTitle extends StatelessWidget {
  const CustomTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 32,
        color: mainColor,
        fontFamily: 'Amiri',
      ),
    );
  }
}
