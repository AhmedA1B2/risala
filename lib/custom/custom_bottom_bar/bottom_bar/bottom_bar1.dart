import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/bottom_bar_itme1.dart';

class BottomBar1 extends StatelessWidget {
  const BottomBar1({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BottomBarItme1(children: children);
  }
}
