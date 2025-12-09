import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomButtonIcon extends StatelessWidget {
  const CustomButtonIcon({
    super.key,
    this.iconData,
    this.onPressed,
    required this.iconColor,
    this.size,
  });
  final IconData? iconData;
  final void Function()? onPressed;
  final Color iconColor;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: whiteColor,
      shadowColor: blackColor,
      elevation: 2,
      child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            iconData,
            color: iconColor,
            size: size,
          )),
    );
  }
}
