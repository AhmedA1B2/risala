import 'package:flutter/material.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_text_bar/custom_text_bar.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_text_bar/custom_text_bar2.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_text_bar/custom_text_bar3.dart';

class CustomItem extends StatelessWidget {
  const CustomItem({
    super.key,
    required this.surah,
    required this.aya,
    required this.where,
    required this.onToggle,
    this.intextbar,
    required this.number,
    required this.onTap,
    required this.sizeOfTextBar,
  });

  final String surah;
  final String aya;
  final String where;
  final String number;
  final void Function(int) onToggle;
  final Widget? intextbar;
  final void Function()? onTap;
  final int sizeOfTextBar;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: sizeOfTextBar == 1
            ? CustomTextBar(
                number: number,
                surah: surah,
                aya: aya,
                where: where,
              )
            : sizeOfTextBar == 2
                ? CustomTextBar2(
                    number: number,
                    surah: surah,
                    aya: aya,
                    where: where,
                  )
                : sizeOfTextBar == 3
                    ? CustomTextBar3(
                        number: number,
                        surah: surah,
                        aya: aya,
                        where: where,
                      )
                    : const SizedBox(),
      ),
    );
  }
}
