import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen1.dart';
import 'package:risala/custom/custom_menu_animation/custom_menu_animation5.dart';
import 'package:risala/custom/custom_menu_button/custom_menu_button1.dart';
import 'package:risala/custom/custom_search_bar/custom_search_bar.dart';
import 'package:risala/home/home_view.dart';
import 'package:risala/main.dart';
import 'package:risala/menu/menu.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/quran_view/quran_view.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

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

  int? surahsaved = sharedPref.getInt('surahsaved');
  String? namesaved = sharedPref.getString('namesaved');

  bool isMenuOpen = false;

  List<Map<String, dynamic>>? searchResults;
  Translation? translation;

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    setState(() {
      translation = list.first;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  Future<void> _openQuranViewSaved() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (translation == null) {
      return const Center(child: CustomLoadingScreen1());
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
      },
      buttonMenuKey: buttonMenuKey,
      mainView: Stack(
        children: [
          searchResults == null
              ? const HomeView()
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
