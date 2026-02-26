import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:risala/custom/custom_menu_button/custom_menu_button1.dart';
import 'package:risala/main.dart';
import 'package:risala/streak/streak.dart';
import 'package:risala/vars/colors.dart';

class CustomMenuAnimation5 extends StatefulWidget {
  const CustomMenuAnimation5({
    super.key,
    required this.mainView,
    required this.menu,
    required this.searchWidget,
    required this.title,
    required this.onMenuChanged,
    required this.buttonMenuKey,
  });

  final Widget mainView;
  final Widget menu;
  final Widget searchWidget;
  final String title;
  final GlobalKey<CustomMenuButton1State> buttonMenuKey;

  final ValueChanged<bool> onMenuChanged;

  @override
  CustomMenuAnimation5State createState() => CustomMenuAnimation5State();
}

class CustomMenuAnimation5State extends State<CustomMenuAnimation5> {
  int itView = 0;
  double animatedContainerWidth = 80;

  /// فتح / إغلاق المينيو بالأنيميشن
  void animation() async {
    if (itView == 0) {
      setState(() {
        itView = 1;
        animatedContainerWidth = 80;
      });

      widget.onMenuChanged(true);

      await Future.delayed(const Duration(milliseconds: 50));

      setState(() {
        animatedContainerWidth = 300;
      });
    } else {
      setState(() {
        animatedContainerWidth = 80;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        itView = 0;
      });

      widget.onMenuChanged(false);
    }
  }

  /// إغلاق المينيو من الخارج (Blur)
  void closeMenu() {
    if (itView != 0) {
      animation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: scandColor,
        toolbarHeight: MediaQuery.of(context).size.height * 0.2,
        actions: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomMenuButton1(
                        key: widget.buttonMenuKey,
                        onTap: animation,
                      ),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 32,
                        fontFamily: 'Amiri',
                      ),
                    ),

                    const Streak(),
                    // CustomIconButtonBookmark(
                    //   onPressed: widget.onPressedBookMark,
                    // ),
                  ],
                ),
                widget.searchWidget,
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          widget.mainView,
          if (itView != 0)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 220,
                        width: animatedContainerWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dilutionamberColor,
                          border: Border.all(color: blackColor, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: widget.menu,
                      ),
                    ),

                    // صورة يسار
                    Positioned(
                      left: 0,
                      top: -65,
                      child: Transform.translate(
                        offset: const Offset(-50, 0),
                        child: SizedBox(
                          width: 75,
                          child: Image.asset(
                            "assets/images/${sharedPref.getInt("myTheme") ?? 0}.png",
                          ),
                        ),
                      ),
                    ),

                    // صورة يمين
                    Positioned(
                      right: 0,
                      top: -65,
                      child: Transform.translate(
                        offset: const Offset(50, 0),
                        child: SizedBox(
                          width: 75,
                          child: Image.asset(
                            "assets/images/${sharedPref.getInt("myTheme") ?? 0}.png",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
