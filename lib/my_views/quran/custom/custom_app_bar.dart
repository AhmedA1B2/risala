import 'package:flutter/material.dart';
import 'package:risala/my_views/quran/custom/custom_title.dart';
import 'package:risala/vars/colors.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar(
      {super.key,
      required this.surahName,
      this.onPressed,
      required this.onOff,
      required this.iconData,
      required this.topButton});
  final String onOff;
  final String surahName;
  final IconData iconData;
  final void Function()? onPressed;
  final Widget topButton;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.14,
      width: double.infinity,
      decoration:  BoxDecoration(
        color: scandColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        border: const Border(
          bottom: BorderSide(color: blackColor, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        textDirection: TextDirection.rtl,
        children: [
          widget.topButton,
          CustomTitle(text: widget.surahName),
          GestureDetector(
            onTap: widget.onPressed,
            child: Row(
              children: [
                CustomTitle(text: widget.onOff),
                Icon(
                  widget.iconData,
                  color: mainColor,
                  size: 32,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
