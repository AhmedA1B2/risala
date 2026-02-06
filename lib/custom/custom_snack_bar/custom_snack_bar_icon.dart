import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomSnackBarIcon extends StatelessWidget {
  const CustomSnackBarIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: blackColor, width: 2),
          shape: BoxShape.circle,
          color: scandColor,
        ),
        child: Icon(
          icon,
          size: 80,
          color: whiteColor,
        ));
  }
}
