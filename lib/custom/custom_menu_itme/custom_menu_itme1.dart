import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class CustomMenuItme extends StatefulWidget {
  const CustomMenuItme(
      {super.key,
      required this.textItme,
      required this.iconItme,
      this.onPressed});

  final String textItme;
  final IconData iconItme;
  final void Function()? onPressed;

  @override
  State<CustomMenuItme> createState() => _CustomMenuItmeState();
}

class _CustomMenuItmeState extends State<CustomMenuItme> {
  double animationScale = 0;

  animation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return; // ✅ الحل هنا
      animationScale = 1;
      setState(() {});
    });
  }

  @override
  void initState() {
    animation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: animationScale,
      duration: const Duration(milliseconds: 300),
      child: TextButton(
        onPressed: widget.onPressed,
        child: Container(
          width: 200,
          decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: blackColor, width: 1),
                  right: BorderSide(color: blackColor, width: 1)),
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  topLeft: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  offset: Offset(-2, -2),
                  blurRadius: 30,
                  blurStyle: BlurStyle.inner,
                  color: whiteColor,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    widget.iconItme,
                    color: blackColor,
                  ),
                  Text(
                    widget.textItme,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: blackColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri',
                    ),
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
