import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/icon_bar_itme.dart';
import 'package:risala/menu/custom/bottom_bar_itme_for_theme.dart';
import 'package:risala/vars/colors.dart';

class BottomBarAnimationForTheme extends StatefulWidget {
  const BottomBarAnimationForTheme({
    super.key,
    required this.icons,
    required this.onIconTap,
    required this.scand,
    required this.main,
    required this.theme,
  });

  /// مرر أي عدد من الأيقونات
  final List<IconData> icons;
  final Function(int index) onIconTap;
  final Color main;
  final Color scand;
  final bool theme;

  @override
  State<BottomBarAnimationForTheme> createState() =>
      _BottomBarAnimationForThemeState();
}

class _BottomBarAnimationForThemeState extends State<BottomBarAnimationForTheme>
    with TickerProviderStateMixin {
  int currentIndex = 0;
  late List<double> sizeoficon;
  late List<double> positions;

  @override
  void initState() {
    super.initState();
    // أول أيقونة ظاهرة (0)، الباقي مخفية (150 مثلاً)
    positions = List.generate(widget.icons.length, (i) => i == 0 ? 0 : 150);
    sizeoficon = List.generate(widget.icons.length, (i) => i == 0 ? 42 : 32);
  }

  void animateTo(int index) {
    if (index == currentIndex) return;

    setState(() {
      positions[currentIndex] = 150;
      sizeoficon[currentIndex] = 32;

      positions[index] = 0;
      sizeoficon[index] = 42;
      currentIndex = index;
    });

    widget.onIconTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return BottomBarItmeForTheme(
      theme: widget.theme,
      children: List.generate(widget.icons.length, (i) {
        return IconBarItme(
          isitTheme: true,
          size: sizeoficon[i],
          iconbar: widget.icons[i],
          isonpress: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            transform: Matrix4.translationValues(0, positions[i], 0),
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: widget.scand,
              border: Border.all(
                color: whiteColor,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 2.5,
                  color: blackColor,
                  offset: Offset(0, 2),
                  spreadRadius: 1.0,
                ),
              ],
            ),
          ),
          onPressed: () => animateTo(i),
        );
      }),
    );
  }
}
