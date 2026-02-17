import 'package:flutter/material.dart';
import 'package:risala/models/sura.dart';
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
  // سنخزن هنا الآيات مع نسخة "نظيفة" للبحث لضمان السرعة
  List<Map<String, dynamic>> quranVerses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  // 🔹 دالة توحيد النص (تحل مشكلة الهمزات والدقة)
  String normalizeText(String text) {
    if (text.isEmpty) return "";

    // 1. إزالة التشكيل (حتى لو الملف غير مشكل، قد يكتب المستخدم بتشكيل)
    String normalized = text.replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]'), '');

    // 2. توحيد الألفات (أ، إ، آ) إلى (ا)
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');

    // 3. توحيد الياء والألف المقصورة والتاء المربوطة (اختياري لزيادة الدقة)
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ة', 'ه');

    return normalized.trim();
  }

  // 🔹 تحميل البيانات ومعالجتها مسبقاً (حل مشكلة اللاج)
  Future<void> loadAllData() async {
    try {
      final String surahsResponse =
          await rootBundle.loadString('assets/json/surahs.json');
      final List<dynamic> surahsData = json.decode(surahsResponse);

      final String quranResponse = await rootBundle
          .loadString('assets/json/quran/quran_for_search.json');
      final List<dynamic> quranData = json.decode(quranResponse);

      // هنا قمنا بحل مشكلة الـ Casting وتجهيز النص للبحث
      final List<Map<String, dynamic>> processedQuran = quranData.map((item) {
        final Map<String, dynamic> verseMap = Map<String, dynamic>.from(item);
        return {
          ...verseMap,
          'search_content': normalizeText(verseMap['content'] ?? ""),
        };
      }).toList();

      setState(() {
        surahs = surahsData.map((e) => Surah.fromMap(e)).toList();
        quranVerses = processedQuran;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading JSON: $e");
      setState(() => isLoading = false);
    }
  }

  void searchQuran() {
    String query = textEditingController.text.trim();
    if (query.isEmpty || isLoading) {
      widget.onResults?.call(null);
      return;
    }

    final normalizedQuery = normalizeText(query);

    if (selectedValue == "آية") {
      // البحث الآن يعتمد على search_content المجهز مسبقاً (سريع جداً)
      final results = quranVerses.where((verse) {
        final String searchContent = verse['search_content'] ?? "";
        return searchContent.contains(normalizedQuery);
      }).toList();

      widget.onResults?.call(results);
    } else {
      final results = surahs.where((s) {
        final name = normalizeText(s.name);
        return name.contains(normalizedQuery) ||
            s.englishName.toLowerCase().contains(normalizedQuery.toLowerCase());
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
        Expanded(
          // أفضل لتجنب الـ Overflow
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onTap: widget.onSearchBarTap,
              onChanged: (val) {
                widget.onSearchBarChanged?.call(val);
                // تفعيل البحث الفوري لأن اللاج انتهى
                if (val.isEmpty) {
                  widget.onResults?.call(null);
                } else if (val.length > 2) {
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
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.22,
          decoration: BoxDecoration(
              color: mainColor, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              borderRadius: BorderRadius.circular(8),
              dropdownColor: mainColor,
              value: selectedValue == "آية" ? widget.aya : widget.surah,
              iconEnabledColor: blackColor,
              items: [widget.aya, widget.surah]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Center(
                            child: Text(e,
                                style: const TextStyle(
                                    color: blackColor, fontSize: 13))),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = (value == widget.aya) ? "آية" : "سورة";
                });
                searchQuran();
              },
            ),
          ),
        )
      ],
    );
  }
}
