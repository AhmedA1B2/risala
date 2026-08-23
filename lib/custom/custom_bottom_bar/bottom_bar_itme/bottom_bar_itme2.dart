import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class BottomBarItme2 extends StatelessWidget {
  const BottomBarItme2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: whiteColor,
          border: Border.all(
            color: blackColor,
          ),
          borderRadius: BorderRadius.circular(20)),
      height: 75,
    );
  }
}
