import 'package:flutter/material.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen1.dart';
import 'package:risala/custom/custom_menu_animation/custom_menu_animation5.dart';
import 'package:risala/custom/custom_search_bar/custom_search_bar.dart';
import 'package:risala/home/home_view.dart';
import 'package:risala/main.dart';
import 'package:risala/menu/menu.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/quran_view/quran_view.dart';
import 'package:risala/translation/translation.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int? surahsaved = sharedPref.getInt('surahsaved');
  String? namesaved = sharedPref.getString('namesaved');

  Future<void> _openQuranViewSaved() async {
    if (surahsaved != null && namesaved != null) {
      print("surahsaved! ===== ${surahsaved!}");
      print("surahsaved ===== $surahsaved");
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuranView(
            surahNumber: surahsaved!,
            x: 1,
          ),
        ),
      );

      print("2surahsaved! ===== ${surahsaved!}");
      print("2surahsaved ===== $surahsaved");

      // لما يرجع من صفحة QuranView يتم التحديث
      setState(() {
        surahsaved = sharedPref.getInt('surahsaved');
        namesaved = sharedPref.getString('namesaved');
      });
    }
  }

  List<Map<String, dynamic>>? searchResults;

  //////////////////////////////////////////////
  /////////////////////////////////////////////

  Translation? translation;

  String? surah;
  String? verse;

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(
        sharedPref.getString("selectedValue")); // هذا يرجع قائمة من Translation
    setState(() {
      translation = list.first; // أو اختر حسب اللغة
    });
  }

  @override
  void initState() {
    loadAllTranslations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return translation == null
        ? const Center(child: CustomLoadingScreen1())
        : CustomMenuAnimation5(
            title: translation!.theQuran.isNotEmpty
                ? translation!.theQuran
                : "ٱلْقُرْآنُ",
            onPressedBookMark: _openQuranViewSaved,
            mainView: searchResults == null
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
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          "${translation!.surah.isNotEmpty ? translation!.surah : "سورة"} ${verse['surah_number']} - ${translation!.verse.isNotEmpty ? translation!.verse : "آية"}  ${verse['verse_number']}",
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
            menu: Menu(
              explanatoryTextForTitle:
                  translation!.explanatoryTextForTitle.isNotEmpty
                      ? translation!.explanatoryTextForTitle
                      : "هذا هو شكل خط العناوين",
              explanatoryTextForAya:
                  translation!.explanatoryTextForAya.isNotEmpty
                      ? translation!.explanatoryTextForAya
                      : "هذا هو شكل خط الايات",
              saveText:
                  translation!.save.isNotEmpty ? translation!.save : "حفظ",
            ),
            searchWidget: CustomSearchBar(
              onResults: (results) {
                setState(() {
                  searchResults = results;
                });
              },
              aya: translation!.verse.isNotEmpty ? translation!.verse : "آية",
              surah:
                  translation!.surah.isNotEmpty ? translation!.surah : "سورة",
              hintText: translation!.searchHintText.isNotEmpty
                  ? translation!.searchHintText
                  : "ابحث عن آية أو سورة...",
            ),
          );
  }
}
