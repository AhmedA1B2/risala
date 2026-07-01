import 'package:flutter/material.dart';
import 'package:risala/main.dart';
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
  // 🔹 تم تغيير الاسم ليصبح Public (بدون شرطة سفلية)
  State<CustomSearchBar> createState() => CustomSearchBarState();
}

class CustomSearchBarState extends State<CustomSearchBar> {
  String? selectedValue;
  TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  List<Surah> surahs = [];
  List<Map<String, dynamic>> quranVerses = [];
  bool isLoading = true;
  bool showSearchBar = false;

  @override
  void initState() {
    super.initState();
    loadAllData();
    // 🔹 تم حذف الـ listener الذي كان يسبب الانكماش الخاطئ
  }

  @override
  void dispose() {
    _focusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  // 🔹 دالة جديدة نتحكم بها من الخارج لإغلاق الشريط ومسح النص
  void closeSearchBar() {
    if (showSearchBar) {
      setState(() {
        showSearchBar = false;
        textEditingController.clear(); // حل المشكلة الأولى: مسح النص المكتوب
      });
      _focusNode.unfocus();
      widget.onResults?.call(null); // مسح نتائج البحث من الشاشة للعودة للصفحة الرئيسية
    }
  }

  String normalizeText(String text) {
    if (text.isEmpty) return "";
    String normalized = text.replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u06D6-\u06ED]'), '');
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll('ى', 'ي');
    normalized = normalized.replaceAll('ة', 'ه');
    return normalized.trim();
  }

  Future<void> loadAllData() async {
    // ... نفس الكود الخاص بك لتحميل البيانات ...
    try {
      final String surahsResponse =
          await rootBundle.loadString('assets/json/surahs.json');
      final List<dynamic> surahsData = json.decode(surahsResponse);

      final String quranResponse = riwoya == "hafs"
          ? await rootBundle
              .loadString('assets/json/quran/quran_for_search_hafs.json')
          : await rootBundle
              .loadString('assets/json/quran/quran_for_search_qaloun.json');
      final List<dynamic> quranData = json.decode(quranResponse);

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
    double screenWidth = MediaQuery.of(context).size.width;
    double searchBarTargetWidth = screenWidth * 0.70 - 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            if (!showSearchBar) {
              setState(() {
                showSearchBar = true;
              });
              _focusNode.requestFocus();
            } else {
              if (!isLoading) {
                searchQuran();
              }
            }
          },
          icon: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.search),
          color: mainColor,
          iconSize: 38,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: showSearchBar ? searchBarTargetWidth : 0,
          margin: showSearchBar ? const EdgeInsets.all(8) : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                width: searchBarTargetWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  focusNode: _focusNode,
                  onTap: widget.onSearchBarTap,
                  onChanged: (val) {
                    widget.onSearchBarChanged?.call(val);
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
                  onSubmitted: (_) {
                    searchQuran();
                    _focusNode.unfocus();
                  },
                ),
              ),
            ),
          ),
        ),
        Container(
          width: screenWidth * 0.22,
          decoration: BoxDecoration(
              color: mainColor, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              borderRadius: BorderRadius.circular(8),
              dropdownColor: mainColor,
              value: selectedValue == "آية" ? widget.aya : widget.surah,
              iconEnabledColor: Colors.black,
              items: [widget.aya, widget.surah]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Center(
                            child: Text(e,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13))),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = (value == widget.aya) ? "آية" : "سورة";
                });
                searchQuran();
                // 🔹 بعد اختيار القائمة المنسدلة، نعيد التركيز إلى حقل النص ليبقى الشريط ظاهراً
                _focusNode.requestFocus();
              },
            ),
          ),
        )
      ],
    );
  }
}