import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:risala/my_views/quran/quran_text/quran_text.dart';
import 'package:risala/vars/texts.dart';

class CustomSurahPage extends StatefulWidget {
  const CustomSurahPage({
    super.key,
    required this.surahNumber,
    this.selectedVerse,
    this.selectedWordKey,
    this.onVerseSelected,
    this.onVerseContext,
    this.onWordSelected,
  });

  final int surahNumber;
  final int? selectedVerse;
  final String? selectedWordKey; // "verseNum-wordPosition"
  final void Function(int?)? onVerseSelected;
  final void Function(String)? onWordSelected;
  final void Function(int verseNum, BuildContext context)? onVerseContext;

  @override
  State<CustomSurahPage> createState() => _CustomSurahPageState();
}

class _CustomSurahPageState extends State<CustomSurahPage> {
  int? _selectedVerse;
  String? _selectedWordKey;

  // مفاتيح لكل آية (تُستخدم للحصول على context دقيق داخل النص المتصل)
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _selectedVerse = widget.selectedVerse;
    _selectedWordKey = widget.selectedWordKey;
  }

  String fixQuranText(String text) {
    final Map<String, String> replacements = {
      'ٞ': 'ٌ',
      'ٗ': 'ً',
      'ٖ': 'ٍ',
    };
    replacements.forEach((wrong, correct) {
      text = text.replaceAll(wrong, correct);
    });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final currentSurah = quranText
        .where((v) => v['surah_number'] == widget.surahNumber)
        .toList();

    // نجمع TextSpan و WidgetSpan في قائمة واحدة
    final List<InlineSpan> allSpans = [];

    for (final verse in currentSurah) {
      final int verseNum = verse['verse_number'] as int;
      final String verseText = fixQuranText(verse['content']);
      final bool isVerseSelected = widget.selectedVerse == verseNum;

      // احصل أو أنشئ GlobalKey لهذه الآية
      final key = _verseKeys.putIfAbsent(verseNum, () => GlobalKey());

      // إضافة marker صغيرة (WidgetSpan) في بداية الآية.
      // هذا العنصر له Key ووجوده داخل الـ flow يسمح لنا بالحصول على context
      // في الموضع الدقيق داخل النص المتصل.
      allSpans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: SizedBox(
            key: key,
            width: 0,
            height: 0,
          ),
        ),
      );

      // نجزئ الآية لكلمات/رموز كما في كودك الأصلي
      final RegExp regex = RegExp(r'([۞۩۝ٖٞٗ]+|[^\s۞۩۝ٖٞٗ]+)');
      final matches = regex.allMatches(verseText).toList();

      int preMarkCounter = 0;
      int postMarkCounter = -1;
      bool inPostMarkMode = false;

      for (final match in matches) {
        final token = match.group(0)!;
        final bool isSymbol = RegExp(r'[۞۩۝ٖٞٗ]').hasMatch(token);

        if (isSymbol) {
          if (token.contains('۞')) {
            inPostMarkMode = true;
            postMarkCounter = -1;
          }
          allSpans.add(
            TextSpan(
              text: '$token ',
              style: TextStyle(
                fontFamily: quranfontFamily,
                fontSize: quranfontSize,
                color: Colors.grey[600],
                height: 2,
              ),
            ),
          );
        } else {
          int effectivePosition;
          if (!inPostMarkMode) {
            preMarkCounter++;
            effectivePosition = preMarkCounter;
          } else {
            postMarkCounter++;
            effectivePosition = postMarkCounter;
          }

          final wordKey = "$verseNum-$effectivePosition";
          final bool isWordSelected = _selectedWordKey == wordKey;

          allSpans.add(
            TextSpan(
              text: '$token ',
              style: TextStyle(
                fontFamily: quranfontFamily,
                fontSize: quranfontSize,
                color: isVerseSelected
                    ? Colors.amber
                    : (isWordSelected ? Colors.blue : Colors.black),
                backgroundColor: isWordSelected
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.transparent,
                height: 2,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _selectedWordKey = isWordSelected ? null : wordKey;
                    _selectedVerse = null;
                  });
                  widget.onWordSelected?.call(_selectedWordKey ?? '');
                },
            ),
          );
        }
      }

      // رقم الآية مع التعرف على الضغط عليه
      allSpans.add(
        TextSpan(
          text: ' ﴿$verseNum﴾ ',
          style: TextStyle(
            fontFamily: quranfontFamily,
            fontSize: quranfontSize,
            color: isVerseSelected ? Colors.amber : Colors.grey[700],
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              setState(() {
                _selectedVerse = _selectedVerse == verseNum ? null : verseNum;
                _selectedWordKey = null;
              });
              widget.onVerseSelected?.call(_selectedVerse);
            },
        ),
      );
    }

    // بعد انتهاء البناء نرسل contexts لجميع الـ keys الموجودة مرة واحدة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verseKeys.forEach((verseNum, gk) {
        if (gk.currentContext != null) {
          widget.onVerseContext?.call(verseNum, gk.currentContext!);
        }
      });
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.surahNumber != 1 && widget.surahNumber != 9)
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "بِسْمِ اللَّهِ الرَّحْمٰنِ الرَّحِيمِ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: quranfontSize,
                  ),
                ),
              ),
            Text.rich(
              TextSpan(children: allSpans),
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
