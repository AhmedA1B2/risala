import 'package:flutter/material.dart';
import 'package:risala/models/sura.dart';
// تم حذف import ملف الـ dart القديم هنا
import 'package:risala/vars/colors.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CustomSearchBar extends StatefulWidget {
  final void Function(List<Map<String, dynamic>>? results)? onResults;
  final String aya;
  final String surah;
  final String hintText;
  final void Function()? onSearchBarTap;
  final void Function(String)? onSearchBarChanged;

  const CustomSearchBar({
    super.key,
    this.onResults,
    required this.aya,
    required this.surah,
    required this.hintText,
    this.onSearchBarChanged,
    this.onSearchBarTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String? selectedValue;
  TextEditingController textEditingController = TextEditingController();

  List<Surah> surahs = [];
  List<dynamic> quranVerses = []; // قائمة لتخزين آيات القرآن من الـ JSON
  bool isLoading = true; // لمتابعة حالة التحميل

  @override
  void initState() {
    super.initState();
    loadAllData(); // تحميل البيانات عند بدء التشغيل
  }

  // 🔹 تحميل بيانات السور والآيات معاً
  Future<void> loadAllData() async {
    try {
      // تحميل ملف السور
      final String surahsResponse =
          await rootBundle.loadString('assets/json/surahs.json');
      final List<dynamic> surahsData = json.decode(surahsResponse);

      // تحميل ملف القرآن الكامل (الذي أنشأناه بالبايثون)
      final String quranResponse = await rootBundle
          .loadString('assets/json/quran/quran_for_search.json');
      final List<dynamic> quranData = json.decode(quranResponse);

      setState(() {
        surahs = surahsData.map((e) => Surah.fromMap(e)).toList();
        quranVerses = quranData;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading JSON: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔹 دالة إزالة التشكيل
  String removeDiacritics(String input) {
    const diacriticsPattern = r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]';
    return input.replaceAll(RegExp(diacriticsPattern), '');
  }

  // 🔹 دالة حساب التشابه (Levenshtein Distance)
  double similarity(String s1, String s2) {
    s1 = s1.trim();
    s2 = s2.trim();
    if (s1.isEmpty || s2.isEmpty) return 0;
    final int len1 = s1.length;
    final int len2 = s2.length;
    List<List<int>> dp =
        List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));
    for (int i = 0; i <= len1; i++) dp[i][0] = i;
    for (int j = 0; j <= len2; j++) dp[0][j] = j;
    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
    }
    return 1.0 - (dp[len1][len2] / (len1 > len2 ? len1 : len2));
  }

  void searchQuran() {
    String query = textEditingController.text.trim();
    if (query.isEmpty || isLoading) {
      widget.onResults?.call(null);
      return;
    }

    final normalizedQuery = removeDiacritics(query);

    if (selectedValue == "آية") {
      // البحث في قائمة quranVerses التي تم تحميلها من الـ JSON
      final results = quranVerses
          .where((verse) {
            final content = removeDiacritics(verse['content'] as String);
            if (content.contains(normalizedQuery)) return true;
            return similarity(content, normalizedQuery) > 0.7;
          })
          .map((v) => Map<String, dynamic>.from(v))
          .toList();

      widget.onResults?.call(results);
    } else {
      // البحث في السور
      final results = surahs.where((s) {
        final name = removeDiacritics(s.name);
        if (name.contains(normalizedQuery) ||
            s.englishName
                .toLowerCase()
                .contains(normalizedQuery.toLowerCase())) {
          return true;
        }
        return similarity(name, normalizedQuery) > 0.7;
      }).map((s) {
        return {
          'content': s.name,
          'surah_number': s.number,
          'verse_number': 0,
        };
      }).toList();

      widget.onResults?.call(results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: isLoading ? null : searchQuran,
          icon: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.search),
          color: mainColor,
          iconSize: 38,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.60,
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            onTap: widget.onSearchBarTap,
            onChanged: (val) {
              widget.onSearchBarChanged?.call(val);
              if (val.isEmpty || val == "" || val == " ") {
                searchQuran();
              }
            },
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: isLoading ? "جاري التحميل..." : widget.hintText,
              border: InputBorder.none,
            ),
            textAlign: TextAlign.right,
            onSubmitted: (_) => searchQuran(),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.20,
          decoration: BoxDecoration(
              color: mainColor, borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<String>(
            borderRadius: BorderRadius.circular(8),
            dropdownColor: mainColor,
            value: selectedValue == "آية" ? widget.aya : widget.surah,
            iconEnabledColor: blackColor,
            items: [widget.aya, widget.surah]
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: const TextStyle(color: blackColor)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = (value == widget.aya) ? "آية" : "سورة";
              });
              searchQuran();
            },
          ),
        )
      ],
    );
  }
}
