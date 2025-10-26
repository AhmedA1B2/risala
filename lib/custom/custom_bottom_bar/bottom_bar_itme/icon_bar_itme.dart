import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class IconBarItme extends StatefulWidget {
  const IconBarItme(
      {super.key,
      required this.iconbar,
      this.isonpress,
      this.onPressed,
      required this.size});

  final IconData iconbar;
  final Widget? isonpress;
  final void Function()? onPressed;
  final double size;

  @override
  State<IconBarItme> createState() => _IconBarItmeState();
}

class _IconBarItmeState extends State<IconBarItme> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.isonpress ?? const SizedBox.shrink(),
        IconButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: widget.onPressed,
          icon: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                widget.iconbar,
                size: widget.size * 1.06,
                shadows: const [
                  Shadow(blurRadius: 5),
                ],
                color: blackColor,
              ),
              Icon(
                widget.iconbar,
                size: widget.size,
                color: mainColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
