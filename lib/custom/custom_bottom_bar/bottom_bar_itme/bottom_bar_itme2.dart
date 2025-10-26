import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class BottomBarItme2 extends StatelessWidget {
  const BottomBarItme2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: whiteColor,
          border: Border(
            top: BorderSide(
              color: blackColor,
            ),
          )),
      height: 75,
    );
  }
}
