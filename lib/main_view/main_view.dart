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
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final GlobalKey<CustomMenuAnimation5State> menuKey =
      GlobalKey<CustomMenuAnimation5State>();
  final GlobalKey<CustomMenuButton1State> buttonMenuKey =
      GlobalKey<CustomMenuButton1State>();

  // Tutorial Keys
  final GlobalKey keyBottomBarForTuorial1 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial2 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial3 = GlobalKey();
  final GlobalKey keyBottomBarForTuorial4 = GlobalKey();

  late TutorialOverlay tutorial;

  int? surahsaved = sharedPref.getInt('surahsaved');
  String? namesaved = sharedPref.getString('namesaved');

  bool isMenuOpen = false;
  List<Map<String, dynamic>>? searchResults;
  Translation? translation;
//
  void _reloadFontSettings() {
    quranfontSize = sharedPref.getDouble("valueOfSize2") ?? 36;
    mytitlefontSize = sharedPref.getDouble("valueOfSize") ?? 26;
    quranfontFamily = sharedPref.getString("selectedValue2") ?? "Amiri";
  }

//
  @override
  void initState() {
    super.initState();
    // نبدأ بتحميل البيانات أولاً
    loadAllTranslations();
    _requestNotificationPermission();
    _reloadFontSettings();
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (list.isNotEmpty) {
      setState(() {
        translation = list.first;
      });

      // بعد التأكد من أن الترجمة جاهزة، نقوم بتهيئة التوجيه
      if (sharedPref.getBool("oldUser") != true) {
        _initTutorial();
      }
    }
  }

  void _initTutorial() {
    // هذه الدالة لا تُستدعى إلا و translation مؤكد وجوده
    tutorial = TutorialOverlay(
      context: context,
      steps: [
        TutorialStep(
            key: keyBottomBarForTuorial4,
            text: translation!.tutorialTasbih.isNotEmpty
                ? translation!.tutorialTasbih
                : "هنا السبحة توجد فيها بعض الأذكار وستكون هناك المزيد من الأذكار مستقبلا"),
        TutorialStep(
            key: keyBottomBarForTuorial3,
            text: translation!.tutorialNotifications.isNotEmpty
                ? translation!.tutorialNotifications
                : "هنا تعرض إشعاراتك المخصصة، ومن هنا يمكنك إضافة إشعارات جديدة."),
        TutorialStep(
            key: keyBottomBarForTuorial2,
            text: translation!.tutorialCompass.isNotEmpty
                ? translation!.tutorialCompass
                : "هنا توجد البوصلة التي تشير إلى القبلة. قد لا تكون الاتجاهات دقيقة في بعض الشبكات وفي بعض الأجهزة."),
        TutorialStep(
            key: keyBottomBarForTuorial1,
            text: translation!.tutorialHome.isNotEmpty
                ? translation!.tutorialHome
                : "هنا الصفحة الرئيسية حيث يوجد القرآن الكريم وتعرض السور هنا "),
        TutorialStep(
            key: buttonMenuKey,
            text: translation!.tutorialMenu.isNotEmpty
                ? translation!.tutorialMenu
                : "هذه القائمة يمكنك تحكم منها ببعض الإعدادات وتغيير اللغة متى شئت."),
      ],
    );

    // تشغيل التوجيه بعد بناء الواجهة مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) => tutorial.start());
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _openQuranViewSaved() async {
    surahsaved = sharedPref.getInt('surahsaved');
    namesaved = sharedPref.getString('namesaved');
    if (surahsaved != null && namesaved != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuranView(
            surahNumber: surahsaved!,
            x: 1,
          ),
        ),
      );

      setState(() {
        surahsaved = sharedPref.getInt('surahsaved');
        namesaved = sharedPref.getString('namesaved');
      });
    } else {
      if (translation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomSnackBar(
              text: translation!.dontSaved.isNotEmpty
                  ? translation!.dontSaved
                  : "لم يتم حفظ أي اية",
            ),
            backgroundColor: const Color.fromARGB(0, 255, 193, 7),
            elevation: 0,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (translation == null) {
      return const Scaffold(
        body: Center(child: CustomLoadingScreen1()),
      );
    }

    return CustomMenuAnimation5(
      key: menuKey,
      title: translation!.theQuran.isNotEmpty
          ? translation!.theQuran
          : "ٱلْقُرْآنُ",
      onPressedBookMark: _openQuranViewSaved,
      onMenuChanged: (value) {
        setState(() {
          isMenuOpen = value;
        });
        if (sharedPref.getBool("oldUser") != true) {
          tutorial.next();
        }
      },
      buttonMenuKey: buttonMenuKey,
      mainView: Stack(
        children: [
          searchResults == null
              ? HomeView(
                  keyBottomBarForTuorial1: keyBottomBarForTuorial1,
                  keyBottomBarForTuorial2: keyBottomBarForTuorial2,
                  keyBottomBarForTuorial3: keyBottomBarForTuorial3,
                  keyBottomBarForTuorial4: keyBottomBarForTuorial4,
                  onTutorialNext: () {
                    if (sharedPref.getBool("oldUser") != true) {
                      tutorial.next();
                    }
                  },
                )
              : ListView.builder(
                  itemCount: searchResults!.length,
                  itemBuilder: (context, index) {
                    final verse = searchResults![index];
                    return ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuranView(
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
                      subtitle: Text(
                        "${translation!.surah} ${verse['surah_number']} - ${translation!.verse} ${verse['verse_number']}",
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
        onSearchBarTap: () {
          menuKey.currentState?.closeMenu();
          buttonMenuKey.currentState?.closeButtonMenu();
        },
        onSearchBarChanged: (value) {
          menuKey.currentState?.closeMenu();
          buttonMenuKey.currentState?.closeButtonMenu();
        },
        onResults: (results) {
          setState(() {
            searchResults = results;
          });
        },
        aya: translation!.verse,
        surah: translation!.surah,
        hintText: translation!.searchHintText,
      ),
    );
  }
}
