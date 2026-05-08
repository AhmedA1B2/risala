import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen1.dart';
import 'package:risala/custom/custom_menu_animation/custom_menu_animation5.dart';
import 'package:risala/custom/custom_menu_button/custom_menu_button1.dart';
import 'package:risala/custom/custom_search_bar/custom_search_bar.dart';
import 'package:risala/custom/custom_snack_bar/custom_snack_bar.dart';
import 'package:risala/custom/custom_tutorial/tutorial_overlay.dart';
import 'package:risala/home/home_view.dart';
import 'package:risala/main.dart';
import 'package:risala/menu/menu.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/quran_view/quran_view.dart';
import 'package:risala/streak/video/my_video_player.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';
import 'package:vibration/vibration.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with RouteAware {
  final GlobalKey<CustomMenuAnimation5State> menuKey = GlobalKey();
  final GlobalKey<CustomMenuButton1State> buttonMenuKey = GlobalKey();

  final GlobalKey keyBottomBarForTuorial1 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial2 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial3 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial4 = GlobalKey();

  late TutorialOverlay tutorial;

  bool isMenuOpen = false;
  bool isVisible = false;

  List<Map<String, dynamic>>? searchResults;
  Translation? translation;

  int streakCount = sharedPref.getInt("streakCount") ?? 0;

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
    _requestNotificationPermission();
    _reloadFontSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => isVisible = true;

  @override
  void didPopNext() => isVisible = true;

  @override
  void didPushNext() => isVisible = false;

  @override
  void didPop() => isVisible = false;

  void _reloadFontSettings() {
    quranfontSize = sharedPref.getDouble("valueOfSize2") ?? 36;
    mytitlefontSize = sharedPref.getDouble("valueOfSize") ?? 26;
    quranfontFamily = sharedPref.getString("selectedValue2") ?? "Amiri";
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (list.isNotEmpty) {
      setState(() {
        translation = list.first;
      });

      if (sharedPref.getBool("oldUser") != true) {
        _initTutorial();
      }
    }
  }

  void _initTutorial() {
    tutorial = TutorialOverlay(
      context: context,
      steps: [
        TutorialStep(
            key: keyBottomBarForTuorial4, text: translation!.tutorialTasbih),
        TutorialStep(
            key: keyBottomBarForTuorial3,
            text: translation!.tutorialNotifications),
        TutorialStep(
            key: keyBottomBarForTuorial2, text: translation!.tutorialCompass),
        TutorialStep(
            key: keyBottomBarForTuorial1, text: translation!.tutorialHome),
        TutorialStep(key: buttonMenuKey, text: translation!.tutorialMenu),
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => tutorial.start());
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  String getStreakVideoPath() {
    if (streakCount <= 9) return "assets/images/streak/animation/1.mp4";
    if (streakCount <= 29) return "assets/images/streak/animation/2.mp4";
    if (streakCount <= 49) return "assets/images/streak/animation/3.mp4";
    if (streakCount <= 99) return "assets/images/streak/animation/4.mp4";
    return "assets/images/streak/animation/5.mp4";
  }

  void _handleVideoFinished() {
    sharedPref.setBool("isVideoWatched", true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isGoalCompletedNotifier.value = false;
    });
  }

  Future<void> _openQuranViewSaved() async {
    final surah = sharedPref.getInt('surahsaved');
    final name = sharedPref.getString('namesaved');

    if (surah != null && name != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuranView(
            surahNumber: surah,
            x: 1,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomSnackBar(text: translation!.dontSaved),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  Widget _buildMainContent() {
    return CustomMenuAnimation5(
      key: menuKey,
      title: translation!.theQuran,
      onMenuChanged: (value) {
        setState(() => isMenuOpen = value);
      },
      buttonMenuKey: buttonMenuKey,
      mainView: Stack(
        children: [
          searchResults == null
              ? HomeView(
                  onTutorialNext: () {
                    if (sharedPref.getBool("oldUser") != true) {
                      tutorial.next();
                    }
                  },
                  onPressedCustomIconButtonBookmark: _openQuranViewSaved,
                  keyBottomBarForTuorial1: keyBottomBarForTuorial1,
                  keyBottomBarForTuorial2: keyBottomBarForTuorial2,
                  keyBottomBarForTuorial3: keyBottomBarForTuorial3,
                  keyBottomBarForTuorial4: keyBottomBarForTuorial4,
                )
              : ListView.builder(
                  itemCount: searchResults!.length,
                  itemBuilder: (_, index) {
                    final verse = searchResults![index];
                    return ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuranView(
                              surahNumber: verse['surah_number'],
                              searchedVerse: verse['verse_number'],
                              x: 2,
                            ),
                          ),
                        );
                      },
                      title: Text(
                        verse['content'],
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
          if (isMenuOpen)
            GestureDetector(
              onTap: () {
                menuKey.currentState?.closeMenu();
                buttonMenuKey.currentState?.closeButtonMenu();
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 5),
                child: Container(
                  color: blackColor.withOpacity(0.15),
                ),
              ),
            ),
        ],
      ),
      menu: Menu(
        explanatoryTextForTitle: translation!.explanatoryTextForTitle,
        explanatoryTextForAya: translation!.explanatoryTextForAya,
        saveText: translation!.save,
      ),
      searchWidget: CustomSearchBar(
        onResults: (results) {
          setState(() => searchResults = results);
        },
        aya: translation!.verse,
        surah: translation!.surah,
        hintText: translation!.searchHintText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (translation == null) {
      return const Scaffold(
        body: Center(child: CustomLoadingScreen1()),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: isGoalCompletedNotifier,
      builder: (context, isGoalCompleted, _) {
        final isVideoWatched = sharedPref.getBool("isVideoWatched") ?? false;

        final shouldPlayVideo = isVisible && isGoalCompleted && !isVideoWatched;

        if (shouldPlayVideo) {
          return MyVideoPlayer(
            video: getStreakVideoPath(),
            onFinished: () {
              Vibration.vibrate(duration: 200);
              _handleVideoFinished();
            },
          );
        }

        return _buildMainContent();
      },
    );
  }
}
