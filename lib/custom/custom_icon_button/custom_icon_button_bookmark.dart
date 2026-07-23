import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomIconButtonBookmark extends StatelessWidget {
  const CustomIconButtonBookmark({super.key, this.onPressed});
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        Icons.bookmark,
        color: mainColor,
        size: 36,
      ),
    );
  }
}
