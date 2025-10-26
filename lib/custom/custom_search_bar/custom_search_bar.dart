import 'package:flutter/material.dart';
import 'package:risala/models/sura.dart';
import 'package:risala/my_views/quran/quran_text/quran_text_normal.dart';
import 'package:risala/vars/colors.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CustomSearchBar extends StatefulWidget {
  final void Function(List<Map<String, dynamic>>? results)? onResults;
  final String aya;
  final String surah;
  final String hintText;

  const CustomSearchBar(
      {super.key,
      this.onResults,
      required this.aya,
      required this.surah,
      required this.hintText});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String? selectedValue;
  TextEditingController textEditingController = TextEditingController();

  List<Surah> surahs = [];

  @override
  void initState() {
    super.initState();
    loadSurahs();
  }

  // 🔹 تحميل بيانات السور من ملف JSON
  Future<void> loadSurahs() async {
    final String response =
        await rootBundle.loadString('assets/json/surahs.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      surahs = data.map((e) => Surah.fromMap(e)).toList();
    });
  }

  // 🔹 دالة إزالة التشكيل من النص العربي
  String removeDiacritics(String input) {
    const diacriticsPattern =
        r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]'; // نطاق الحركات
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

    for (int i = 0; i <= len1; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        int cost = (s1[i - 1] == s2[j - 1]) ? 0 : 1;
        dp[i][j] = [dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
    }

    int distance = dp[len1][len2];
    double maxLen = len1 > len2 ? len1.toDouble() : len2.toDouble();
    return 1.0 - (distance / maxLen);
  }

  void searchQuran() {
    String query = textEditingController.text.trim();
    if (query.isEmpty) {
      widget.onResults?.call(null); // ← هذا التعديل
      return;
    }

    final normalizedQuery = removeDiacritics(query);

    if (selectedValue == "آية") {
      final results = quranTextNormal.where((verse) {
        final content = removeDiacritics(verse['content'] as String);
        if (content.contains(normalizedQuery)) return true;
        double sim = similarity(content, normalizedQuery);
        return sim > 0.7;
      }).toList();

      widget.onResults?.call(results);
    } else {
      final results = surahs.where((s) {
        final name = removeDiacritics(s.name);
        final queryName = removeDiacritics(query);
        if (name.contains(queryName) ||
            s.englishName.toLowerCase().contains(queryName.toLowerCase())) {
          return true;
        }
        double sim = similarity(name, queryName);
        return sim > 0.7;
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
          onPressed: searchQuran,
          icon: const Icon(Icons.search),
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
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: widget.hintText,
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
            items: [
              widget.aya,
              widget.surah,
            ]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(color: blackColor),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                value == widget.aya
                    ? selectedValue = "آية"
                    : selectedValue = "سورة";
              });
            },
          ),
        )
      ],
    );
  }
}
