import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomCopysaveButton extends StatelessWidget {
  const CustomCopysaveButton(
      {super.key, required this.bottom, required this.icon, this.onTap});

  final double bottom;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: bottom,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scandColor,
            border: Border.all(color: mainColor, width: 2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 28,
            color: mainColor,
          ),
        ),
      ),
    );
  }
}
