import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/vars/colors.dart';

class BukhariChapterView extends StatefulWidget {
  const BukhariChapterView({
    super.key,
    required this.chapterId,
  });

  // ID الباب، وهو نفسه اسم ملف JSON.
  final int chapterId;

  @override
  State<BukhariChapterView> createState() => _BukhariChapterViewState();
}

class _BukhariChapterViewState extends State<BukhariChapterView> {
  static const String languagePreferenceKey = 'bukhariChapterLanguage';

  late final String selectedLanguage;
  late final Future<_ChapterData> chapterFuture;

  bool get isArabic => selectedLanguage == 'ar';

  @override
  void initState() {
    super.initState();

    // استعادة اللغة التي اختارها المستخدم سابقًا.
    final savedLanguage = sharedPref.getString(languagePreferenceKey);

    // استخدام لغة التطبيق كخيار احتياطي عند عدم وجود لغة محفوظة.
    final appLanguage = sharedPref.getString('selectedValue');

    selectedLanguage = savedLanguage == 'ar' || savedLanguage == 'en'
        ? savedLanguage!
        : appLanguage == 'en'
            ? 'en'
            : 'ar';

    // تحميل ملف الباب المطلوب مرة واحدة.
    chapterFuture = loadChapter();
  }

  // ==========================================
  // تحميل بيانات الباب من ملف JSON
  // ==========================================

  Future<_ChapterData> loadChapter() async {
    final filePath = 'assets/json/bukhari/${widget.chapterId}.json';

    final jsonString = await rootBundle.loadString(filePath);
    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException(
        'تنسيق ملف الباب غير صحيح.',
      );
    }

    final data = Map<String, dynamic>.from(decoded);

    // بيانات الكتاب.
    final metadataRaw = data['metadata'];

    if (metadataRaw is! Map) {
      throw const FormatException(
        'لم يتم العثور على بيانات الكتاب.',
      );
    }

    final metadata = Map<String, dynamic>.from(metadataRaw);

    final languageMetadataRaw = metadata[isArabic ? 'arabic' : 'english'];

    if (languageMetadataRaw is! Map) {
      throw const FormatException(
        'لم يتم العثور على بيانات الكتاب باللغة المطلوبة.',
      );
    }

    final languageMetadata = Map<String, dynamic>.from(languageMetadataRaw);

    // بيانات الباب نفسه.
    final chapterRaw = data['chapter'];

    if (chapterRaw is! Map) {
      throw const FormatException(
        'لم يتم العثور على بيانات الباب.',
      );
    }

    final chapter = Map<String, dynamic>.from(chapterRaw);

    // قائمة الأحاديث.
    final hadithsRaw = data['hadiths'];

    if (hadithsRaw is! List) {
      throw const FormatException(
        'لم يتم العثور على قائمة الأحاديث.',
      );
    }

    final hadiths = hadithsRaw
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();

    final rawTotal = data['total_hadiths_in_chapter'];

    final totalHadiths = rawTotal is int ? rawTotal : hadiths.length;

    return _ChapterData(
      chapterId: widget.chapterId,
      chapterTitle: chapter[isArabic ? 'arabic' : 'english']?.toString() ??
          (isArabic ? 'باب غير معروف' : 'Unknown chapter'),
      bookTitle: languageMetadata['title']?.toString() ??
          (isArabic ? 'صحيح البخاري' : 'Sahih al-Bukhari'),
      author: languageMetadata['author']?.toString() ??
          (isArabic
              ? 'الإمام محمد بن إسماعيل البخاري'
              : 'Imam Muhammad ibn Ismail al-Bukhari'),
      totalHadiths: totalHadiths,
      hadiths: hadiths,
    );
  }

  // ==========================================
  // الواجهة الرئيسية
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: mainColor),
          backgroundColor: scandColor,
          title: FutureBuilder<_ChapterData>(
            future: chapterFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!.chapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: mainColor),
                );
              }

              return Text(
                isArabic ? 'تحميل الباب...' : 'Loading chapter...',
              );
            },
          ),
        ),
        body: FutureBuilder<_ChapterData>(
          future: chapterFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isArabic
                            ? 'حدث خطأ أثناء تحميل الباب.'
                            : 'An error occurred while loading this chapter.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text(
                  isArabic
                      ? 'تعذر تحميل بيانات الباب.'
                      : 'Unable to load chapter data.',
                ),
              );
            }

            final data = snapshot.data!;

            if (data.hadiths.isEmpty) {
              return Center(
                child: Text(
                  isArabic
                      ? 'لا توجد أحاديث في هذا الباب.'
                      : 'No hadiths found in this chapter.',
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                24,
              ),
              itemCount: data.hadiths.length + 1,
              itemBuilder: (context, index) {
                // رأس الصفحة.
                if (index == 0) {
                  return buildChapterHeader(data);
                }

                // بيانات الحديث.
                final hadith = data.hadiths[index - 1];

                return buildHadithCard(
                  hadith,
                  index - 1,
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // رأس الصفحة: الكتاب والمؤلف وعدد الأحاديث
  // ==========================================

  Widget buildChapterHeader(_ChapterData data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              data.bookTitle,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              data.author,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'عدد الأحاديث: ${data.totalHadiths}'
                        : 'Number of hadiths: ${data.totalHadiths}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // بطاقة الحديث
  // ==========================================

  Widget buildHadithCard(
    Map<String, dynamic> hadith,
    int index,
  ) {
    final hadithId = hadith['id']?.toString() ?? '${index + 1}';

    final String arabicText = hadith['arabic']?.toString() ?? '';

    final dynamic englishRaw = hadith['english'];

    final Map<String, dynamic> englishData = englishRaw is Map
        ? Map<String, dynamic>.from(englishRaw)
        : <String, dynamic>{};

    final String narrator = englishData['narrator']?.toString() ?? '';

    final String englishText = englishData['text']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // رقم الحديث.
            Align(
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scandColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isArabic ? 'حديث رقم $hadithId' : 'Hadith $hadithId',
                  style: TextStyle(color: mainColor),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // النص العربي.
            if (isArabic)
              SelectableText(
                arabicText.isNotEmpty
                    ? arabicText
                    : 'لا يتوفر النص العربي لهذا الحديث.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 19,
                      height: 2,
                    ),
              )

            // النص الإنجليزي.
            else ...[
              if (narrator.isNotEmpty) ...[
                Text(
                  narrator,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
              ],
              SelectableText(
                englishText.isNotEmpty
                    ? englishText
                    : 'English text is not available for this hadith.',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.8,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==========================================
// نموذج بيانات الباب
// ==========================================

class _ChapterData {
  final int chapterId;
  final String chapterTitle;
  final String bookTitle;
  final String author;
  final int totalHadiths;
  final List<Map<String, dynamic>> hadiths;

  const _ChapterData({
    required this.chapterId,
    required this.chapterTitle,
    required this.bookTitle,
    required this.author,
    required this.totalHadiths,
    required this.hadiths,
  });
}
