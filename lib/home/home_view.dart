import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bg/custom_bg_of_home.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_animation/bottom_bar_animation1.dart';
import 'package:risala/custom/custom_list_items/custom_list/custom_list1.dart';
import 'package:risala/my_views/adhan/adhan_view/adhan_view.dart';
import 'package:risala/my_views/qibla/qibla_view/qibla_view.dart';
import 'package:risala/my_views/sabhuh/sabhuh_view/sabhuh_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

double showRightView = 0;
double topBorderRadius = 10;

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomBg(topMargin: 0, topBorderRadius: topBorderRadius),
        showRightView == 0
            ? const CustomList()
            : showRightView == 1
                ? const QiblaView()
                : showRightView == 2
                    ? const AdhanView()
                    : showRightView == 3
                        ? const SabhuhView()
                        : const SizedBox(),
        Positioned(
          bottom: 8,
          width: MediaQuery.of(context).size.width,
          child: BottomBarAnimation1(
            onIconTap: (index) {
              if (index == 0) {
                setState(() {
                  showRightView = 0;
                  topBorderRadius = 10;
                });
              } else if (index == 1) {
                setState(() {
                  showRightView = 1;
                  topBorderRadius = 500;
                });
              } else if (index == 2) {
                setState(() {
                  showRightView = 2;
                  topBorderRadius = 50;
                });
              } else if (index == 3) {
                setState(() {
                  topBorderRadius = 100;
                  showRightView = 3;
                });
              }
            },
            icons: const [
              Icons.menu_book_sharp,
              Icons.track_changes_rounded,
              Icons.mosque_rounded,
              Icons.spa_sharp,
            ],
          ),
        )
      ],
    );
  }
}
