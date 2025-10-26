import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_item1.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/main.dart';

import 'package:risala/models/sura.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/quran_view/quran_view.dart';
import 'package:risala/translation/translation.dart';

class CustomList extends StatefulWidget {
  const CustomList({super.key});

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  int? openedIndex; // هنا نخزن العنصر المفتوح

  Future<List<Surah>> loadSurahs() async {
    // تحميل النص من ملف JSON
    String jsonString = await rootBundle.loadString('assets/json/surahs.json');

    // تحويله إلى List
    List<dynamic> jsonData = json.decode(jsonString);

    // تحويله إلى قائمة سور
    return jsonData.map((item) => Surah.fromMap(item)).toList();
  }

  void toggleItem(int index) {
    setState(() {
      if (openedIndex == index) {
        openedIndex = null; // لو ضغطت نفس العنصر → يقفل
      } else {
        openedIndex = index; // يفتح العنصر الجديد ويقفل البقية
      }
    });
  }

  //////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
  }

  Translation? translation;

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(
        sharedPref.getString("selectedValue")); // هذا يرجع قائمة من Translation
    setState(() {
      translation = list.first; // أو اختر حسب اللغة
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: FutureBuilder<List<Surah>>(
          future: loadSurahs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomLoadingScreen2();
            } else if (snapshot.hasError) {
              print('خطأ: ${snapshot.error}');
              return Text('خطأ: ${snapshot.error}');
            } else {
              final surahs = snapshot.data!;
              return ListView.builder(
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return Padding(
                    padding:
                        EdgeInsets.only(bottom: surah.number == 114 ? 200 : 0),
                    child: CustomItem(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuranView(
                                    surahNumber: surah.number,
                                    x: 0,
                                  )),
                        );
                      },
                      number: '-${surah.number}',
                      onToggle: toggleItem,
                      surah: sharedPref.getString("selectedValue") != "ar"
                          ? surah.englishName
                          : surah.name,
                      aya:
                          '${translation!.numberOfVerses.isNotEmpty ? translation!.numberOfVerses : "عدد الآيات"} ${surah.numberOfAyahs}',
                      where: sharedPref.getString("selectedValue") != "ar"
                          ? surah.revelationType
                          : surah.revelationType == "Medinan"
                              ? "مدنية"
                              : "مكية",
                      intextbar: Text(surah.englishNameTranslation),
                    ),
                  );
                },
              );
            }
          },
        ));
  }
}
