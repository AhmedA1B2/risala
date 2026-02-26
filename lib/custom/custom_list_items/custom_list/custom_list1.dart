import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/custom/custom_icon_button/custom_icon_button_bookmark.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_item1.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/main.dart';
import 'package:risala/models/sura.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/quran_view/quran_view.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class CustomList extends StatefulWidget {
  const CustomList({super.key, this.onPressedCustomIconButtonBookmark});

  final void Function()? onPressedCustomIconButtonBookmark;

  @override
  State<CustomList> createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  int? openedIndex;
  int sizeOfTextBar = sharedPref.getInt("sizeOfTextBar") ?? 1;

  late Future<List<Surah>> surahsFuture;
  Translation? translation;

  @override
  void initState() {
    super.initState();
    surahsFuture = loadSurahs(); // تحميل مرة واحدة فقط
    loadAllTranslations();
  }

  Future<List<Surah>> loadSurahs() async {
    String jsonString = await rootBundle.loadString('assets/json/surahs.json');
    List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => Surah.fromMap(item)).toList();
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    if (list.isNotEmpty) {
      setState(() {
        translation = list.first;
      });
    }
  }

  void toggleItem(int index) {
    setState(() {
      openedIndex = openedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          FutureBuilder<List<Surah>>(
            future: surahsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomLoadingScreen2();
              }

              if (snapshot.hasError) {
                return Center(child: Text('خطأ: ${snapshot.error}'));
              }

              final surahs = snapshot.data!;

              return sizeOfTextBar == 1
                  ? buildListView(surahs)
                  : buildGridView(surahs);
            },
          ),
          Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15,
              right: 20,
              child: Card(
                elevation: 1,
                color: scandColor,
                child: CustomIconButtonBookmark(
                  onPressed: widget.onPressedCustomIconButtonBookmark,
                ),
              ))
        ],
      ),
    );
  }

  // ===========================
  // ListView
  // ===========================

  Widget buildListView(List<Surah> surahs) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 200),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        return buildItem(surahs[index]);
      },
    );
  }

  // ===========================
  // GridView
  // ===========================

  Widget buildGridView(List<Surah> surahs) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 200),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: sizeOfTextBar,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          return buildItem(surahs[index]);
        },
      ),
    );
  }

  // ===========================
  // عنصر مشترك
  // ===========================

  Widget buildItem(Surah surah) {
    final isArabic = sharedPref.getString("selectedValue") == "ar";

    return CustomItem(
      sizeOfTextBar: sizeOfTextBar,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuranView(
              surahNumber: surah.number,
              x: 0,
            ),
          ),
        );
      },
      number: '-${surah.number}',
      onToggle: toggleItem,
      surah: isArabic ? surah.name : surah.englishName,
      aya:
          '${translation?.numberOfVerses.isNotEmpty == true ? translation!.numberOfVerses : "عدد الآيات"} ${surah.numberOfAyahs}',
      where: isArabic
          ? (surah.revelationType == "Medinan" ? "مدنية" : "مكية")
          : surah.revelationType,
      intextbar: Text(surah.englishNameTranslation),
    );
  }
}
