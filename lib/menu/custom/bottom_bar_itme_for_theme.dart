import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:risala/vars/colors.dart';

class BottomBarItmeForTheme extends StatefulWidget {
  const BottomBarItmeForTheme({super.key, required this.children, required this.theme});

  final List<Widget> children;
  final bool theme;

  @override
  State<BottomBarItmeForTheme> createState() => _BottomBarItmeForThemeState();
}

class _BottomBarItmeForThemeState extends State<BottomBarItmeForTheme> {
  

  @override
  Widget build(BuildContext context) {
    return widget.theme == false
        ? Container(
            margin: const EdgeInsets.all(8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 0,
                      color: blackColor,
                      offset: Offset(0, 3))
                ],
                color: whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: blackColor,
                  width: 2,
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              textDirection: TextDirection.rtl,
              children: widget.children,
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 15, sigmaY: 15), // تأثير الزجاج
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: whiteColor.withOpacity(0.15), // شفافية الزجاج
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: whiteColor.withOpacity(0.35), // لمعان طرف الزجاج
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blackColor.withOpacity(0.12),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    textDirection: TextDirection.rtl,
                    children: widget.children,
                  ),
                ),
              ),
            ),
          );
  }
}
