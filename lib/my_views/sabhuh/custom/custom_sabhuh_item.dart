import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class CustomSabhuhItem extends StatelessWidget {
  const CustomSabhuhItem({super.key, required this.text, this.onTap});
  final String text;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: scandColor,
        margin: const EdgeInsets.all(20),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                  fontSize: mytitlefontSize),
            ),
          ),
        ),
      ),
    );
  }
}
