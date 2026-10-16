import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:risala/custom/custom_icon_button/custom_icon_button_bookmark.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_item1.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/main.dart';
import 'package:risala/my_views/hadith/hadith_view/bukhari_chapter_view.dart';
import 'package:risala/vars/colors.dart';

class CustomChapterList extends StatefulWidget {
  const CustomChapterList({
    super.key,
    this.onPressedCustomIconButtonBookmark,
    this.onChapterTap,
  });

  final void Function()? onPressedCustomIconButtonBookmark;

  // يستقبل ID الباب الحقيقي واسمه باللغة المختارة.
  final void Function(int chapterId, String chapterName)? onChapterTap;

  @override
  State<CustomChapterList> createState() => _CustomChapterListState();
}

class _CustomChapterListState extends State<CustomChapterList> {
  int? openedIndex;

  int sizeOfTextBar = sharedPref.getInt('sizeOfTextBar') ?? 1;

  static const String languagePreferenceKey = 'bukhariChapterLanguage';

  late String selectedLanguage;

  late Future<_ChapterListData> chaptersFuture;

  static const String chapterNamesPath =
      'assets/json/bukhari/names_of_chapters/chapter_names.json';

  @override
  void initState() {
    super.initState();

    final savedLanguage = sharedPref.getString(languagePreferenceKey);

    final appLanguage = sharedPref.getString('selectedValue');

    if (savedLanguage == 'ar' || savedLanguage == 'en') {
      selectedLanguage = savedLanguage!;
    } else {
      selectedLanguage = appLanguage == 'en' ? 'en' : 'ar';
    }

    chaptersFuture = loadChapterData();
  }

  // ==========================================
  // تحميل أسماء الأبواب وبيانات الكتاب
  // ==========================================

  Future<_ChapterListData> loadChapterData() async {
    final jsonString = await rootBundle.loadString(chapterNamesPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException(
        'يجب أن يحتوي ملف chapter_names.json على قائمة بالأبواب.',
      );
    }

    final chapters = decoded
        .whereType<Map>()
        .map(
          (item) => _ChapterInfo.fromMap(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    // قراءة عنوان الكتاب واسم المؤلف من الملف الأول.
    final metadataString = await rootBundle.loadString(
      'assets/json/bukhari/1.json',
    );

    final dynamic metadataJson = jsonDecode(metadataString);

    if (metadataJson is! Map) {
      throw const FormatException(
        'تنسيق ملف بيانات الكتاب غير صحيح.',
      );
    }

    final metadata = metadataJson['metadata'];

    if (metadata is! Map) {
      throw const FormatException(
        'لم يتم العثور على بيانات الكتاب.',
      );
    }

    final arabic = metadata['arabic'];
    final english = metadata['english'];

    if (arabic is! Map || english is! Map) {
      throw const FormatException(
        'بيانات الكتاب العربية أو الإنجليزية غير موجودة.',
      );
    }

    return _ChapterListData(
      chapters: chapters,
      arabicBookTitle: arabic['title']?.toString() ?? 'صحيح البخاري',
      englishBookTitle: english['title']?.toString() ?? 'Sahih al-Bukhari',
    );
  }

  // ==========================================
  // تغيير اللغة وحفظ الاختيار
  // ==========================================

  Future<void> changeLanguage(String? language) async {
    if (language == null ||
        (language != 'ar' && language != 'en') ||
        language == selectedLanguage) {
      return;
    }

    final previousLanguage = selectedLanguage;

    setState(() {
      selectedLanguage = language;
    });

    try {
      final saved = await sharedPref.setString(
        languagePreferenceKey,
        language,
      );

      if (!saved && mounted) {
        setState(() {
          selectedLanguage = previousLanguage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          selectedLanguage = previousLanguage;
        });
      }
    }
  }

  // ==========================================
  // فتح الباب
  // ==========================================

  void openChapter(_ChapterInfo chapter, int index) {
    final isArabic = selectedLanguage == 'ar';

    final chapterName = isArabic ? chapter.arabic : chapter.english;

    // يمكن استخدام هذا callback لتسجيل الاختيار أو تنفيذ إجراء إضافي.
    widget.onChapterTap?.call(chapter.id, chapterName);

    // فتح ملف الباب الذي يحمل ID نفسه.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BukhariChapterView(
          chapterId: chapter.id,
        ),
      ),
    );
  }

  // ==========================================
  // الواجهة الرئيسية
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Stack(
        children: [
          FutureBuilder<_ChapterListData>(
            future: chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CustomLoadingScreen2();
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      selectedLanguage == 'ar'
                          ? 'حدث خطأ أثناء تحميل البيانات:\n'
                              '${snapshot.error}'
                          : 'Error loading data:\n'
                              '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Text(
                    selectedLanguage == 'ar'
                        ? 'تعذر تحميل بيانات الكتاب.'
                        : 'Unable to load book data.',
                  ),
                );
              }

              final data = snapshot.data!;

              if (data.chapters.isEmpty) {
                return Center(
                  child: Text(
                    selectedLanguage == 'ar'
                        ? 'لا توجد أبواب لعرضها.'
                        : 'No chapters available.',
                  ),
                );
              }

              return Directionality(
                textDirection: selectedLanguage == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Column(
                  children: [
                    buildLanguageSelector(),
                    Expanded(
                      child: sizeOfTextBar == 1
                          ? buildListView(data)
                          : buildGridView(data),
                    ),
                  ],
                ),
              );
            },
          ),

          // زر العلامة المرجعية.
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            right: 20,
            child: Card(
              elevation: 1,
              color: scandColor,
              child: CustomIconButtonBookmark(
                onPressed: widget.onPressedCustomIconButtonBookmark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // اختيار اللغة
  // ==========================================

  Widget buildLanguageSelector() {
    final isArabic = selectedLanguage == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isArabic ? 'لغة العرض' : 'Display language',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLanguage,
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              items: const [
                DropdownMenuItem(
                  value: 'ar',
                  child: Text('العربية'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
              ],
              onChanged: changeLanguage,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ListView
  // ==========================================

  Widget buildListView(_ChapterListData data) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 200),
      itemCount: data.chapters.length,
      itemBuilder: (context, index) {
        return buildItem(data, index);
      },
    );
  }

  // ==========================================
  // GridView
  // ==========================================

  Widget buildGridView(_ChapterListData data) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 200),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sizeOfTextBar,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: data.chapters.length,
      itemBuilder: (context, index) {
        return buildItem(data, index);
      },
    );
  }

  // ==========================================
  // عنصر الباب باستخدام CustomItem
  // ==========================================

  Widget buildItem(_ChapterListData data, int index) {
    final chapter = data.chapters[index];
    final isArabic = selectedLanguage == 'ar';

    return CustomItem(
      sizeOfTextBar: sizeOfTextBar,

      surah: isArabic ? chapter.arabic : chapter.english,

      aya: "",

      where: isArabic ? data.arabicBookTitle : data.englishBookTitle,

      // استخدام ID الحقيقي بدل ترتيب العنصر.
      number: '-${chapter.id}',

      onToggle: toggleItem,

      onTap: () {
        openChapter(chapter, index);
      },
    );
  }

  void toggleItem(int index) {
    setState(() {
      openedIndex = openedIndex == index ? null : index;
    });
  }
}

// ==========================================
// نموذج بيانات الباب
// ==========================================

class _ChapterInfo {
  final int id;
  final String arabic;
  final String english;

  const _ChapterInfo({
    required this.id,
    required this.arabic,
    required this.english,
  });

  factory _ChapterInfo.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];

    final int? id =
        rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    if (id == null) {
      throw const FormatException(
        'أحد الأبواب لا يحتوي على ID صالح.',
      );
    }

    return _ChapterInfo(
      id: id,
      arabic: map['arabic']?.toString() ?? '',
      english: map['english']?.toString() ?? '',
    );
  }
}

// ==========================================
// بيانات القائمة والكتاب
// ==========================================

class _ChapterListData {
  final List<_ChapterInfo> chapters;

  final String arabicBookTitle;
  final String englishBookTitle;

  const _ChapterListData({
    required this.chapters,
    required this.arabicBookTitle,
    required this.englishBookTitle,
  });
}
