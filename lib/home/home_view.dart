import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bg/custom_bg_of_home.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_animation/bottom_bar_animation1.dart';
import 'package:risala/custom/custom_list_items/custom_list/custom_list1.dart';
import 'package:risala/my_views/custom_notification/custom_notification_view/custom_notification.dart';
import 'package:risala/my_views/qibla/qibla_view/qibla_view.dart';
import 'package:risala/my_views/sabhuh/sabhuh_view/sabhuh_view.dart';

class HomeView extends StatefulWidget {
  const HomeView(
      {super.key,
      required this.keyBottomBarForTuorial1,
      required this.keyBottomBarForTuorial2,
      required this.keyBottomBarForTuorial3,
      required this.keyBottomBarForTuorial4,
      required this.onTutorialNext});

  final GlobalKey keyBottomBarForTuorial1;
  final GlobalKey keyBottomBarForTuorial2;
  final GlobalKey keyBottomBarForTuorial3;
  final GlobalKey keyBottomBarForTuorial4;
  final VoidCallback onTutorialNext;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  double showRightView = 0;
  double topBorderRadius = 10;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomBg(
          topMargin: 0,
          topBorderRadius: topBorderRadius,
          child: showRightView == 0
              ? const CustomList()
              : showRightView == 1
                  ? const QiblaView()
                  : showRightView == 2
                      ? const CustomNotification() //const AdhanView()
                      : showRightView == 3
                          ? const SabhuhView()
                          : const SizedBox(),
        ),
        Positioned(
          bottom: 8,
          width: MediaQuery.of(context).size.width,
          child: BottomBarAnimation1(
            keyBottomBarAnimation1: [
              widget.keyBottomBarForTuorial1,
              widget.keyBottomBarForTuorial2,
              widget.keyBottomBarForTuorial3,
              widget.keyBottomBarForTuorial4
            ],
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
              widget.onTutorialNext();
            },
            icons: const [
              Icons.menu_book_sharp,
              Icons.track_changes_rounded,
              Icons.edit_notifications,
              Icons.spa_sharp,
            ],
          ),
        )
      ],
    );
  }
}
