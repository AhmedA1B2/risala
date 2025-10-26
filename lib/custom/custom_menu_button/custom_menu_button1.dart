import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomMenuButton1 extends StatefulWidget {
  const CustomMenuButton1({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<CustomMenuButton1> createState() => _CustomMenuButton1State();
}

class _CustomMenuButton1State extends State<CustomMenuButton1>
    with TickerProviderStateMixin {
  double turns = 0.0;
  bool isClicked = false;
  late AnimationController _controller;

  animation() {
    if (isClicked) {
      turns -= 1 / 4;
      _controller.reverse();
    } else {
      turns += 1 / 4;
      _controller.forward();
    }
    isClicked = !isClicked;
    setState(() {});
  }

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turns,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutExpo,
      child: GestureDetector(
        onTap: () {
          animation();
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedContainer(
          curve: Curves.easeOutExpo,
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: mainColor,
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  Image.asset(
                    'assets/images/bgOfAyaNumber.png',
                  ),
                  AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _controller,
                    size: 30,
                    color: blackColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
