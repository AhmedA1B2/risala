import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/bottom_bar_itme2.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/icon_bar_itme.dart';
import 'package:risala/vars/colors.dart';

class BottomBarAnimation2 extends StatefulWidget {
  const BottomBarAnimation2({
    super.key,
    required this.icons,
    required this.onIconTap,
    this.positionsOfMusic,
    this.sizeoficonOfMusic,
  });

  final List<IconData> icons;

  final Future<void> Function(int index) onIconTap;

  final double? positionsOfMusic;
  final double? sizeoficonOfMusic;

  @override
  State<BottomBarAnimation2> createState() =>
      _BottomBarAnimation2State();
}

class _BottomBarAnimation2State
    extends State<BottomBarAnimation2> {

  int? currentIndex;

  late List<double> sizeoficon;
  late List<double> positions;

  @override
  void initState() {
    super.initState();

    sizeoficon =
        List.filled(widget.icons.length, 42);

    positions =
        List.filled(widget.icons.length, 0);
  }

  @override
  void didUpdateWidget(
    covariant BottomBarAnimation2 oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.positionsOfMusic == null &&
        widget.sizeoficonOfMusic == null) {

      if (currentIndex != null) {

        setState(() {

          for (int i = 0;
              i < widget.icons.length;
              i++) {

            positions[i] = 0;
            sizeoficon[i] = 42;
          }

          currentIndex = null;
        });
      }
    }
  }

  Future<void> animateTo(int index) async {

    final isSelected =
        currentIndex == index;

    setState(() {

      for (int i = 0;
          i < widget.icons.length;
          i++) {

        positions[i] = 0;
        sizeoficon[i] = 42;
      }

      if (!isSelected) {

        positions[index] =
            widget.positionsOfMusic ?? -30;

        sizeoficon[index] =
            widget.sizeoficonOfMusic ?? 48;

        currentIndex = index;

      } else {

        currentIndex = null;
      }
    });

    await widget.onIconTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        const BottomBarItme2(),

        Padding(
          padding:
              const EdgeInsets.only(top: 5.0),

          child: Row(
            textDirection: TextDirection.rtl,

            mainAxisAlignment:
                MainAxisAlignment.spaceAround,

            children: List.generate(
              widget.icons.length,
              (i) {

                return AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 250),

                  curve: Curves.easeOut,

                  transform:
                      Matrix4.translationValues(
                    0,
                    positions[i],
                    0,
                  ),

                  child: AnimatedScale(
                    scale: sizeoficon[i] / 42,

                    duration:
                        const Duration(milliseconds: 250),

                    curve: Curves.easeOut,

                    child: Container(
                      decoration: BoxDecoration(
                        color: scandColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: blackColor,
                        ),
                      ),

                      child: IconBarItme(
                        size: 42,

                        iconbar:
                            widget.icons[i],

                        onPressed: () =>
                            animateTo(i),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}