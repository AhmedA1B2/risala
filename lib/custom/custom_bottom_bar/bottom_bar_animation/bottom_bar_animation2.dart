import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/bottom_bar_itme2.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_itme/icon_bar_itme.dart';
import 'package:risala/vars/colors.dart';

class BottomBarAnimation2 extends StatefulWidget {
  const BottomBarAnimation2({
    super.key,
    required this.icons,
    required this.onIconTap,
    this.oldeOnIconTap,
    this.positionsOfMusic,
    this.sizeoficonOfMusic, // ✅ أضفنا callback
  });

  final List<IconData> icons;
  final Function(int index) onIconTap; // ✅ هذا بيرجع index الأيقونة المضغوطة
  final Function(int index)? oldeOnIconTap;
  final double? positionsOfMusic;
  final double? sizeoficonOfMusic;

  @override
  State<BottomBarAnimation2> createState() => _BottomBarAnimation2State();
}

class _BottomBarAnimation2State extends State<BottomBarAnimation2> {
  @override
  void didUpdateWidget(covariant BottomBarAnimation2 oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.positionsOfMusic == null && widget.sizeoficonOfMusic == null) {
      if (currentIndex != null) {
        setState(() {
          positions[currentIndex!] = 0;
          sizeoficon[currentIndex!] = 42;
          currentIndex = null;
        });
      }
    }
  }

  int? currentIndex;
  late List<double> sizeoficon;
  late List<double> positions;

  @override
  void initState() {
    super.initState();
    sizeoficon = List.filled(widget.icons.length, 42);
    positions = List.filled(widget.icons.length, 0);
  }

  void animateTo(int index) {
    if (currentIndex == index) {
      // إعادة القيم إلى الطبيعية
      setState(() {
        positions[index] = 0;
        sizeoficon[index] = 42;
        widget.oldeOnIconTap?.call(currentIndex!);
        currentIndex = null;
      });
      return;
    }

    if (currentIndex != null) {
      setState(() {
        positions[currentIndex!] = 0;
        sizeoficon[currentIndex!] = 42;
        widget.oldeOnIconTap?.call(currentIndex!);
      });
    }

    setState(() {
      positions[index] =
          widget.positionsOfMusic ?? -30; // هذه ستأخذ القيمة الجديدة من parent
      sizeoficon[index] = widget.sizeoficonOfMusic ?? 48; // هذه أيضًا
      currentIndex = index;
    });

    widget.onIconTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BottomBarItme2(),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.icons.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                transform: Matrix4.translationValues(0, positions[i], 0),
                decoration: BoxDecoration(
                  color: scandColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: blackColor),
                ),
                child: IconBarItme(
                  size: sizeoficon[i],
                  iconbar: widget.icons[i],
                  onPressed: () => animateTo(i),
                ),
              );
            }),
          ),
        )
      ],
    );
  }
}
