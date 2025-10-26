import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomBg extends StatelessWidget {
  const CustomBg(
      {super.key, required this.topMargin, required this.topBorderRadius});

  final double topMargin;
  final double topBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          color: scandColor,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.only(top: topMargin),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(topBorderRadius)),
            border: const Border.fromBorderSide(
              BorderSide(color: blackColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
