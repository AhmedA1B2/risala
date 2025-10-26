import 'package:flutter/material.dart';
import 'package:risala/custom/custom_icon_button/custom_icon_button_bookmark.dart';
import 'package:risala/custom/custom_menu_button/custom_menu_button1.dart';
import 'package:risala/main.dart';

import 'package:risala/vars/colors.dart';

class CustomMenuAnimation5 extends StatefulWidget {
  const CustomMenuAnimation5({
    super.key,
    required this.mainView,
    required this.menu,
    this.onPressedBookMark,
    required this.searchWidget,
    required this.title,
  });

  final Widget mainView;
  final Widget menu;
  final void Function()? onPressedBookMark;
  final Widget searchWidget;
  final String title;

  @override
  State<CustomMenuAnimation5> createState() => _CustomMenuAnimation5State();
}

class _CustomMenuAnimation5State extends State<CustomMenuAnimation5> {
  int itView = 0;
  double animatedContainerWidth = 80;

  void animation() async {
    if (itView == 0) {
      setState(() {
        itView = 1;
        animatedContainerWidth = 80;
      });
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
    }
  }

  //////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: scandColor,
        toolbarHeight: MediaQuery.of(context).size.height * 0.20,
        actions: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomMenuButton1(
                        onTap: animation,
                      ),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(
                          color: whiteColor, fontSize: 32, fontFamily: 'Amiri'),
                    ),
                    CustomIconButtonBookmark(
                      onPressed: widget.onPressedBookMark,
                    )
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
                        padding: const EdgeInsets.all(12),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 250,
                        width: animatedContainerWidth,
                        decoration: BoxDecoration(
                          color: dilutionamberColor,
                          border: Border.all(color: blackColor, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: widget.menu,
                      ),
                    ),
                    // صورة على اليسار
                    Positioned(
                      left: 0,
                      top: -50,
                      child: Transform.translate(
                        offset: const Offset(-50, 0),
                        child: SizedBox(
                          width: 75,
                          child: Image.asset(
                            "assets/images/${sharedPref.getInt("myTheme") ?? 0}.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // صورة على اليمين
                    Positioned(
                      right: 0,
                      top: -50,
                      child: Transform.translate(
                        offset: const Offset(50, 0),
                        child: SizedBox(
                          width: 75,
                          child: Image.asset(
                            "assets/images/${sharedPref.getInt("myTheme") ?? 0}.png",
                            fit: BoxFit.contain,
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
