import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/bottom_bar_itme2.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/icon_bar_itme.dart';
import 'package:risala/vars/colors.dart';

class BottomBarAnimation3 extends StatefulWidget {
  const BottomBarAnimation3({super.key, required this.icons});

  final List<IconData> icons;

  @override
  State<BottomBarAnimation3> createState() => _BottomBarAnimation3State();
}

class _BottomBarAnimation3State extends State<BottomBarAnimation3> {
  int currentIndex = 0;
  late List<Color> bordercolor; // هنا نخزن إزاحة كل أيقونة

  @override
  void initState() {
    super.initState();
    // أول أيقونة ظاهرة (0)، الباقي مخفية (150 مثلاً)
    bordercolor = List.generate(
        widget.icons.length, (i) => i == 0 ? blackColor : whiteColor);
  }

  void animateTo(int index) async {
    if (index == currentIndex) return;

    setState(() {
      bordercolor[currentIndex] = whiteColor; // يخفي الحالي
    });

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      bordercolor[index] = blackColor; // يظهر الجديد
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BottomBarItme2(),
        Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(widget.icons.length, (i) {
            return AnimatedContainer(
              duration: const Duration(
                milliseconds: 100,
              ),
              decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: bordercolor[i], width: 1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: bordercolor[i],
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    )
                  ]),
              child: IconBarItme(
                size: 42,
                iconbar: widget.icons[i],
                onPressed: () => animateTo(i),
              ),
            );
          }),
        )
      ],
    );
  }
}
