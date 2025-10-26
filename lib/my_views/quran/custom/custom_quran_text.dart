// verse_chip.dart
import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class CustomQuranText extends StatelessWidget {
  const CustomQuranText({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? dilutionamberColor : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          // لا تحدد width: double.infinity هنا
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          constraints: BoxConstraints(
            // حد أقصى للعرض: لو الآية طويلة ستلتف داخل نفس العنصر
            maxWidth: MediaQuery.of(context).size.width * 0.98,
          ),
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            softWrap: true,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: mytitlefontSize,
              color: scandColor,
              height: 2,
            ),
          ),
        ),
      ),
    );
  }
}
