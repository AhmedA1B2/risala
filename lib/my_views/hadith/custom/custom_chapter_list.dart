import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/custom/custom_list_items/custom_item/custom_item1.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/main.dart';

class CustomChapterList extends StatefulWidget {
  const CustomChapterList({
    super.key,
    this.onPressedCustomIconButtonBookmark,
    this.onChapterTap,
  });

  final void Function()? onPressedCustomIconButtonBookmark;

  final void Function(int index, String chapterName)? onChapterTap;

  @override
  State<CustomChapterList> createState() => _CustomChapterListState();
}

class _CustomChapterListState extends State<CustomChapterList> {
  int? openedIndex;

  int sizeOfTextBar = sharedPref.getInt('sizeOfTextBar') ?? 1;

  late Future<_ChapterListData> chaptersFuture;

  // مسار ملف أسماء الأبواب.
  static const String chapterNamesPath =
      'assets/json/bukhari/names_of_chapters/chapter_names.json';

  // مسار أحد ملفات الأبواب الذي يحتوي على بيانات الكتاب والمؤلف.
  static const String metadataPath = 'assets/json/bukhari/1.json';

  @override
  void initState() {
    super.initState();

    // تحميل أسماء الأبواب وبيانات الكتاب مرة واحدة.
    chaptersFuture = loadChapterData();
  }

  // ===========================
  // تحميل أسماء الأبواب وبيانات الكتاب
  // ===========================

  Future<_ChapterListData> loadChapterData() async {
    final files = await Future.wait<String>([
      rootBundle.loadString(chapterNamesPath),
      rootBundle.loadString(metadataPath),
    ]);

    // قراءة أسماء الأبواب.
    final dynamic chaptersJson = jsonDecode(files[0]);

    if (chaptersJson is! List) {
      throw const FormatException(
        'يجب أن يحتوي ملف chapter_names.json على قائمة بأسماء الأبواب.',
      );
    }

    final List<String> chapters = chaptersJson
        .whereType<String>()
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    // قراءة بيانات الكتاب والمؤلف.
    final dynamic bookJson = jsonDecode(files[1]);

    if (bookJson is! Map<String, dynamic>) {
      throw const FormatException(
        'تنسيق ملف بيانات الكتاب غير صحيح.',
      );
    }

    final metadata = bookJson['metadata'];

    if (metadata is! Map<String, dynamic>) {
      throw const FormatException(
        'لم يتم العثور على metadata في ملف الكتاب.',
      );
    }

    final arabic = metadata['arabic'];

    if (arabic is! Map<String, dynamic>) {
      throw const FormatException(
        'لم يتم العثور على البيانات العربية للكتاب.',
      );
    }

    final title = arabic['title'];
    final author = arabic['author'];

    if (title is! String || author is! String) {
      throw const FormatException(
        'عنوان الكتاب أو اسم المؤلف غير موجود.',
      );
    }

    return _ChapterListData(
      chapters: chapters,
      bookTitle: title,
    );
  }

  // ===========================
  // فتح وإغلاق العنصر
  // ===========================

  void toggleItem(int index) {
    setState(() {
      openedIndex = openedIndex == index ? null : index;
    });
  }

  // ===========================
  // الواجهة الرئيسية
  // ===========================

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder<_ChapterListData>(
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
                  'حدث خطأ أثناء تحميل البيانات:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('تعذر تحميل بيانات الكتاب.'),
            );
          }

          final data = snapshot.data!;

          if (data.chapters.isEmpty) {
            return const Center(
              child: Text('لا توجد أبواب لعرضها.'),
            );
          }

          return sizeOfTextBar == 1 ? buildListView(data) : buildGridView(data);
        },
      ),
    );
  }

  // ===========================
  // ListView
  // ===========================

  Widget buildListView(_ChapterListData data) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 200),
        itemCount: data.chapters.length,
        itemBuilder: (context, index) {
          return buildItem(data, index);
        },
      ),
    );
  }

  // ===========================
  // GridView
  // ===========================

  Widget buildGridView(_ChapterListData data) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
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
      ),
    );
  }

  // ===========================
  // عنصر الباب باستخدام CustomItem
  // ===========================

  Widget buildItem(_ChapterListData data, int index) {
    final String chapterName = data.chapters[index];

    return CustomItem(
      sizeOfTextBar: sizeOfTextBar,

      // اسم الباب.
      surah: chapterName,

      // عنوان الكتاب مأخوذ من metadata.arabic.title.
      aya: "",

      // اسم المؤلف مأخوذ من metadata.arabic.author.
      where: data.bookTitle,

      // ترتيب الباب في القائمة.
      number: '-${index + 1}',

      onToggle: toggleItem,

      onTap: () {
        widget.onChapterTap?.call(index, chapterName);
      },
    );
  }
}

// ===========================
// نموذج بيانات قائمة الأبواب
// ===========================

class _ChapterListData {
  final List<String> chapters;
  final String bookTitle;

  const _ChapterListData({
    required this.chapters,
    required this.bookTitle,
  });
}
