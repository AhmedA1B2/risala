import 'package:flutter/material.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_text/custom_text_title.dart';
import 'package:risala/vars/colors.dart';

class CustomTextBar extends StatelessWidget {
  const CustomTextBar(
      {super.key,
      required this.surah,
      required this.aya,
      required this.where,
      required this.number});

  final String surah;
  final String aya;
  final String where;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          color: mainColor,
          border: const Border(
            left: BorderSide(color: blackColor, width: 2),
            right: BorderSide(color: blackColor, width: 2),
            top: BorderSide(color: blackColor, width: 2),
            bottom: BorderSide(color: blackColor, width: 2),
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20), bottom: Radius.circular(10)),
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
                CustomTextTitle(text: number),
                CustomTextTitle(text: surah),
                CustomTextTitle(text: aya),
              ],
            ),
            CustomTextTitle(text: where),
          ],
        ),
      ),
    );
  }
}
