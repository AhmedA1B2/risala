import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class ChooseIcon extends StatelessWidget {
  const ChooseIcon(
      {super.key, required this.color, this.onTap, required this.icon});

  final Color color;
  final void Function()? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        shadows: const [
          Shadow(offset: Offset(0, 0), color: blackColor, blurRadius: 12),
        ],
        color: color,
        icon,
        size: 32,
      ),
    );
  }
}
