import 'package:flutter/material.dart';
import 'package:risala/menu/custom/custom_item/custom_text_title_for_theme.dart';
import 'package:risala/vars/colors.dart';

class CustomTextBarForTheme3 extends StatelessWidget {
  const CustomTextBarForTheme3(
      {super.key,
      required this.surah,
      required this.aya,
      required this.where,
      required this.number,
      required this.main,
      required this.sizeOfFont});

  final String surah;
  final String aya;
  final String where;
  final String number;
  final Color main;
  final int sizeOfFont;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          color: main,
          border: const Border(
            left: BorderSide(color: blackColor, width: 2),
            right: BorderSide(color: blackColor, width: 2),
            top: BorderSide(color: blackColor, width: 2),
            bottom: BorderSide(color: blackColor, width: 2),
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10), bottom: Radius.circular(10)),
          boxShadow: const [
            BoxShadow(
              blurRadius: 8,
              color: blackColor,
              spreadRadius: 0.1,
              offset: Offset(0, 6),
            ),
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Wrap(
              textDirection: TextDirection.rtl,
              children: [
                CustomTextTitleForTheme(
                  text: number,
                  sizeOfFont: sizeOfFont,
                ),
                CustomTextTitleForTheme(
                  text: surah,
                  sizeOfFont: sizeOfFont,
                ),
                CustomTextTitleForTheme(
                  text: aya,
                  sizeOfFont: sizeOfFont,
                ),
              ],
            ),
            CustomTextTitleForTheme(
              text: where,
              sizeOfFont: sizeOfFont,
            ),
          ],
        ),
      ),
    );
  }
}
