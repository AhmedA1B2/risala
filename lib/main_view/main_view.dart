import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:risala/custom/custom_bg/custom_bg_of_home.dart';
import 'package:risala/custom/custom_bg/custom_minecraft_night_bg.dart';
import 'package:risala/custom/custom_bg/custom_night_sky_bg.dart';
import 'package:risala/custom/custom_bg/custom_ocean_rain_bg.dart';
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

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with RouteAware {
  static const String _themeDialogSeenKey = 'hasSeenThemeDialogV2';

  final GlobalKey<CustomMenuAnimation5State> menuKey = GlobalKey();
  final GlobalKey<CustomMenuButton1State> buttonMenuKey = GlobalKey();

  final GlobalKey keyBottomBarForTuorial0 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial1 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial2 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial3 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial4 = GlobalKey();

  final GlobalKey<CustomSearchBarState> searchBarKey = GlobalKey();

  TutorialOverlay? tutorial;

  bool isMenuOpen = false;
  bool isVisible = false;
  bool _isShowingThemeDialog = false;

  List<Map<String, dynamic>>? searchResults;
  Translation? translation;

  int streakCount = sharedPref.getInt('streakCount') ?? 0;

  @override
  void initState() {
    super.initState();

    // Keep the global theme value in sync with the saved preference.
    themeIndex = _safeThemeIndex(sharedPref.getInt('myTheme') ?? themeIndex);

    loadAllTranslations();
    _requestNotificationPermission();
    _reloadFontSettings();
  }

  int _safeThemeIndex(int index) {
    if (index < 0 || index >= themes.length) return 0;
    return index;
  }

  bool get _isArabic {
    final language =
        (sharedPref.getString('selectedValue') ?? 'ar').toLowerCase();
    return language == 'ar' || language.startsWith('ar-');
  }

  String _localized(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    return value;
  }

  String _themeName(int index) {
    final t = translation;
    switch (index) {
      case 0:
        return _localized(t?.themeGoldName, 'الذهبي');
      case 1:
        return _localized(t?.themeNightSkyName, 'سماء الليل');
      case 2:
        return _localized(t?.themeMinecraftNightName, 'ليل ماينكرافت');
      case 3:
        return _localized(t?.themeOceanRainName, 'مطر المحيط');
      default:
        return _localized(t?.themeGoldName, 'الذهبي');
    }
  }

  // Apply the selected animated background to any page content.
  // This helper is shared by the theme dialog and the main application page
  // so both places always use exactly the same background for each theme.
  Widget _buildThemeBackground(
    int index, {
    required Widget child,
  }) {
    switch (index) {
      case 0:
        return CustomBg(
          topBorderRadius: 0,
          topMargin: 0,
          child: child,
        );
      case 1:
        return CustomNightSkyBg(child: child);
      case 2:
        return CustomMinecraftNightBg(child: child);
      case 3:
      default:
        return CustomOceanRainBg(child: child);
    }
  }

  // Background preview used by the theme-introduction dialog.
  Widget _buildThemeDialogBackground(int index) {
    return _buildThemeBackground(
      index,
      child: const SizedBox.expand(),
    );
  }

  Future<void> _showThemeSelectionDialog() async {
    if (!mounted || _isShowingThemeDialog) return;
    _isShowingThemeDialog = true;

    final initialTheme = _safeThemeIndex(
      sharedPref.getInt('myTheme') ?? themeIndex,
    );

    int? selectedTheme;

    try {
      selectedTheme = await showDialog<int>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          int temporaryTheme = initialTheme;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              final selectedColors = themes[temporaryTheme];
              final Color accentColor = selectedColors['main']!;

              return Directionality(
                textDirection:
                    _isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 22,
                  ),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 430),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: accentColor.withOpacity(0.5),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Smoothly switch the real animated app backgrounds.
                          Positioned.fill(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    for (final previous in previousChildren)
                                      TickerMode(
                                        enabled: false,
                                        child: previous,
                                      ),
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey<int>(temporaryTheme),
                                child: _buildThemeDialogBackground(
                                  temporaryTheme,
                                ),
                              ),
                            ),
                          ),

                          // Dark translucent overlay keeps the text readable.
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.56),
                                    Colors.black.withOpacity(0.43),
                                    Colors.black.withOpacity(0.68),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: accentColor.withOpacity(0.16),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        Icons.palette_rounded,
                                        color: accentColor,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _localized(
                                              translation?.themeDialogTitle,
                                              'ثيمات جديدة!',
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _localized(
                                              translation?.themeDialogSubtitle,
                                              'اختر المظهر الذي يناسبك',
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 17),
                                Text(
                                  _localized(
                                    translation?.themeDialogDescription,
                                    'أضفنا ثيمات جديدة لتخصيص مظهر تطبيق رسالة. اختر الثيم الذي يعجبك، ويمكنك تغييره في أي وقت لاحقًا.',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    height: 1.6,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 13,
                                  runSpacing: 20,
                                  children: List.generate(
                                    themes.length,
                                    (index) => SizedBox(
                                      width: 100,
                                      child: _buildThemeOption(
                                        index: index,
                                        isSelected: temporaryTheme == index,
                                        onTap: () {
                                          setDialogState(() {
                                            temporaryTheme = index;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      child: Text(
                                        _localized(
                                          translation?.later,
                                          'لاحقًا',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                          temporaryTheme,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentColor,
                                        foregroundColor: Colors.black,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.check_rounded,
                                        size: 19,
                                      ),
                                      label: Text(
                                        _localized(
                                          translation?.applyTheme,
                                          'تطبيق الثيم',
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (selectedTheme != null) {
        final safeIndex = _safeThemeIndex(selectedTheme);

        // حفظ الثيم المختار.
        await sharedPref.setInt('myTheme', safeIndex);

        // إرسال إشعار لجميع الواجهات التي تستمع لتغيّر الثيم.
        themeIndex = safeIndex;
      }

      // Mark as seen after Apply, Later, or barrier dismissal.
      // If displaying the dialog throws an exception, this line is not reached.
      await sharedPref.setBool(_themeDialogSeenKey, true);
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const MainView()),
      );
    } finally {
      _isShowingThemeDialog = false;
    }
  }

  Widget _buildThemeOption({
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = themes[index];
    final Color backgroundColor = theme['scand']!;
    final Color accentColor = theme['main']!;
    final Color secondaryColor = theme['dilution']!;

    const icons = <IconData>[
      Icons.wb_sunny_rounded,
      Icons.nightlight_round,
      Icons.park_rounded,
      Icons.waves_rounded,
    ];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? accentColor : Colors.white.withOpacity(0.28),
                width: isSelected ? 3 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.25),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : const [],
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          backgroundColor,
                          secondaryColor,
                          backgroundColor,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 14,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: accentColor.withOpacity(0.9),
                    ),
                  ),
                  Center(
                    child: Icon(
                      icons[index],
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 17,
                      color: secondaryColor.withOpacity(0.78),
                      alignment: Alignment.center,
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            _themeName(index),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? accentColor : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: isSelected ? 1 : 0,
            child: Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
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
    quranfontSize = sharedPref.getDouble('valueOfSize2') ?? 36;
    mytitlefontSize = sharedPref.getDouble('valueOfSize') ?? 26;
    quranfontFamily = sharedPref.getString('selectedValue2') ?? 'Amiri';
  }

  Future<void> loadAllTranslations() async {
    try {
      final list = await loadTranslation(
        sharedPref.getString('selectedValue'),
      );

      if (!mounted || list.isEmpty) return;

      setState(() {
        translation = list.first;
      });

      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      // A versioned key ensures existing users see this announcement after
      // installing the release that introduces the new theme backgrounds.
      if (sharedPref.getBool(_themeDialogSeenKey) != true) {
        await _showThemeSelectionDialog();
      }

      if (!mounted) return;

      if (sharedPref.getBool('oldUser') != true) {
        _initTutorial();
      }
    } catch (error, stackTrace) {
      debugPrint('MainView: failed to load translations: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _initTutorial() {
    final t = translation;
    if (t == null) return;

    tutorial = TutorialOverlay(
      context: context,
      steps: [
        TutorialStep(
          key: keyBottomBarForTuorial4,
          text: t.tutorialTasbih,
        ),
        TutorialStep(
          key: keyBottomBarForTuorial3,
          text: t.tutorialNotifications,
        ),
        TutorialStep(
          key: keyBottomBarForTuorial2,
          text: t.tutorialCompass,
        ),
        TutorialStep(
          key: keyBottomBarForTuorial1,
          text: t.tutorialHadith,
        ),
        TutorialStep(
          key: keyBottomBarForTuorial0,
          text: t.tutorialHome,
        ),
        TutorialStep(
          key: buttonMenuKey,
          text: t.tutorialMenu,
        ),
      ],
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) tutorial?.start();
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  String getStreakVideoPath() {
    final streak = sharedPref.getInt('streakCount') ?? 0;

    if (streak <= 9) {
      return 'assets/images/streak/animation/1.mp4';
    }
    if (streak <= 29) {
      return 'assets/images/streak/animation/2.mp4';
    }
    if (streak <= 49) {
      return 'assets/images/streak/animation/3.mp4';
    }
    if (streak <= 99) {
      return 'assets/images/streak/animation/4.mp4';
    }
    return 'assets/images/streak/animation/5.mp4';
  }

  void _handleVideoFinished() {
    sharedPref.setBool('isVideoWatched', true);
    showVideoNotifier.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isGoalCompletedNotifier.value = true;
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
      final t = translation;
      if (t == null) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomSnackBar(text: t.dontSaved),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    }
  }

  Widget _buildMainContent() {
    final t = translation!;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
        searchBarKey.currentState?.closeSearchBar();
      },
      child: CustomMenuAnimation5(
        key: menuKey,
        title: t.theQuran,
        onMenuChanged: (value) {
          if (sharedPref.getBool('oldUser') != true) {
            tutorial?.next();
          }
          setState(() => isMenuOpen = value);
        },
        buttonMenuKey: buttonMenuKey,
        mainView: Stack(
          children: [
            searchResults == null
                ? HomeView(
                    onTutorialNext: () {
                      if (sharedPref.getBool('oldUser') != true) {
                        tutorial?.next();
                      }
                    },
                    onPressedCustomIconButtonBookmark: _openQuranViewSaved,
                    keyBottomBarForTuorial0: keyBottomBarForTuorial0,
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
          explanatoryTextForTitle: t.explanatoryTextForTitle,
          explanatoryTextForAya: t.explanatoryTextForAya,
          saveText: t.save,
        ),
        searchWidget: CustomSearchBar(
          key: searchBarKey,
          onResults: (results) {
            setState(() => searchResults = results);
          },
          aya: t.verse,
          surah: t.surah,
          hintText: t.searchHintText,
        ),
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

    return ValueListenableBuilder<int>(
      valueListenable: themeNotifier,
      builder: (context, selectedTheme, child) {
        final int activeTheme = _safeThemeIndex(selectedTheme);

        return Scaffold(
          backgroundColor: themes[activeTheme]['scand']!,
          body: SafeArea(
            child: KeyedSubtree(
              key: ValueKey<int>(activeTheme),
              child: _buildThemeBackground(
                activeTheme,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: showVideoNotifier,
                      builder: (_, showVideo, __) {
                        if (showVideo && isVisible) {
                          return MyVideoPlayer(
                            video: getStreakVideoPath(),
                            onFinished: _handleVideoFinished,
                          );
                        }

                        return _buildMainContent();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
