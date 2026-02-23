import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/models/quran.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

final Map<int, List<SurahToken>> _surahCache = {};

void clearSurahCache() {
  _surahCache.clear();
}

class SurahToken {
  final String text;
  final bool isSymbol;
  final int? verseNumber;
  final String? wordKey;

  SurahToken({
    required this.text,
    required this.isSymbol,
    this.verseNumber,
    this.wordKey,
  });
}

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
  final String? selectedWordKey;
  final void Function(int?)? onVerseSelected;
  final void Function(String)? onWordSelected;
  final void Function(int verseNum, BuildContext context)? onVerseContext;

  @override
  State<CustomSurahPage> createState() => _CustomSurahPageState();
}

class _CustomSurahPageState extends State<CustomSurahPage> {
  List<SurahToken>? _processedTokens;
  bool _isLoading = true;

  // تخزين الـ Spans لعدم إعادة بنائها عند كل SetState (مهم جداً للأداء)
  List<InlineSpan>? _cachedSpans;

  final Map<int, GlobalKey> _verseKeys = {};

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  @override
  void initState() {
    super.initState();
    _loadDataIsolated(riwoya);
  }

  Future<void> _loadDataIsolated(String riwoya) async {
    try {
      if (_surahCache.containsKey(widget.surahNumber)) {
        _processedTokens = _surahCache[widget.surahNumber];
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final String jsonString = await rootBundle.loadString(
          'assets/json/quran/$riwoya/surahs/${widget.surahNumber}.json');

      final List<dynamic> jsonData = json.decode(jsonString);

      final resultTokens = await compute(processSurahInBackground, {
        'data': jsonData,
        'surahNumber': widget.surahNumber,
      });

      // 🔥 نحفظها في الكاش
      _surahCache[widget.surahNumber] = resultTokens;

      if (mounted) {
        setState(() {
          _processedTokens = resultTokens;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading surah: $e");
    }
  }

  void _buildSpansIfNeeded() {
    _cachedSpans = [];

    for (final token in _processedTokens!) {
      if (token.text.isEmpty && token.verseNumber != null) {
        final key =
            _verseKeys.putIfAbsent(token.verseNumber!, () => GlobalKey());
        _cachedSpans!
            .add(WidgetSpan(child: SizedBox(key: key, width: 0, height: 0)));
        continue;
      }

      final bool isVerseSelected = widget.selectedVerse == token.verseNumber;
      final bool isWordSelected = widget.selectedWordKey == token.wordKey;

      String fontFamily = quranfontFamily;

      if (fontFamily != "UthmanicQaloun" && fontFamily != "UthmanicHafs") {
        fontFamily = "UthmanicHafs";
        sharedPref.setString("selectedValue2", fontFamily);
      }

      // 2. النصوص
      if (token.isSymbol) {
        final bool isVerseNum = token.text.contains('﴿');
        _cachedSpans!.add(TextSpan(
          text: token.text,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: quranfontSize,
            color: isVerseNum
                ? (isVerseSelected ? Colors.amber : Colors.grey[700])
                : Colors.grey[600],
            height: 2,
          ),
          recognizer: isVerseNum
              ? (TapGestureRecognizer()
                ..onTap = () {
                  widget.onVerseSelected?.call(
                      widget.selectedVerse == token.verseNumber
                          ? null
                          : token.verseNumber);
                  widget.onWordSelected?.call('');
                })
              : null,
        ));
      } else {
        _cachedSpans!.add(TextSpan(
          text: token.text,
          style: TextStyle(
            fontFamily: quranfontFamily,
            fontSize: quranfontSize,
            color: isVerseSelected
                ? Colors.amber
                : (isWordSelected ? Colors.blue : Colors.black),
            backgroundColor: isWordSelected
                // ignore: deprecated_member_use
                ? Colors.blue.withOpacity(0.15)
                : Colors.transparent,
            height: 2,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              widget.onVerseSelected?.call(null);
              widget.onWordSelected
                  ?.call(isWordSelected ? '' : (token.wordKey ?? ''));
            },
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: scandColor));
    }

    // بناء الـ Spans عند كل build لضمان تحديث الألوان
    // (سريعة جداً الآن لأن البيانات جاهزة)
    _buildSpansIfNeeded();

    // إرسال الـ Contexts مرة واحدة بعد البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verseKeys.isNotEmpty) {
        // نتحقق فقط من الآيات المطلوبة للتمرير لتقليل الضغط
        if (widget.selectedVerse != null &&
            _verseKeys.containsKey(widget.selectedVerse)) {
          final ctx = _verseKeys[widget.selectedVerse]!.currentContext;
          if (ctx != null) {
            widget.onVerseContext?.call(widget.selectedVerse!, ctx);
          }
        }
        // أو يمكنك ترك اللوب كما هو إذا كنت تحتاج كل المواقع
        _verseKeys.forEach((k, v) {
          if (v.currentContext != null) {
            widget.onVerseContext?.call(k, v.currentContext!);
          }
        });
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      // RepaintBoundary: هذا الودجت يمنع إعادة رسم النص بالكامل عند التمرير
      // أو عند تحديث مشغل الصوت خارج هذا الودجت
      child: RepaintBoundary(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.surahNumber != 1 && widget.surahNumber != 9)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    "بِسْمِ اللَّهِ الرَّحْمٰنِ الرَّحِيمِ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: quranfontSize,
                    ),
                  ),
                ),
              // استخدام const هنا غير ممكن بسبب البيانات المتغيرة، لكن SelectableText قد يكون أثقل
              // RichText هو الأخف وزناً
              Text.rich(
                TextSpan(children: _cachedSpans),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<SurahToken> processSurahInBackground(Map<String, dynamic> params) {
  final List<dynamic> rawData = params['data'];
  final int surahNumber = params['surahNumber'];

  // تحويل البيانات الخام
  final List<Quran> allQuran = rawData.map((e) => Quran.fromMap(e)).toList();

  final currentSurah =
      allQuran.where((v) => v.surahNumber == surahNumber).toList();
  final List<SurahToken> tokens = [];

  // تجميع الـ Regex مرة واحدة (تحسين أداء)
  final RegExp regex = RegExp(r'([۞۩۝ٖٞٗ]+|[^\s۞۩۝ٖٞٗ]+)');
  final RegExp symbolRegex = RegExp(r'[۞۩۝ٖٞٗ]');

  // دالة التصحيح الداخلية
  String fixText(String text) {
    return text.replaceAll('ٞ', 'ٌ').replaceAll('ٗ', 'ً').replaceAll('ٖ', 'ٍ');
  }

  for (final verse in currentSurah) {
    final int verseNum = verse.verseNumber;
    final String verseText = fixText(verse.content);

    // إضافة مؤشر بداية الآية (وهمي لضبط المفاتيح لاحقاً)
    tokens.add(SurahToken(text: "", isSymbol: true, verseNumber: verseNum));

    final matches = regex.allMatches(verseText);
    int preMarkCounter = 0;
    int postMarkCounter = -1;
    bool inPostMarkMode = false;

    for (final match in matches) {
      final tokenText = match.group(0)!;
      final bool isSymbol = symbolRegex.hasMatch(tokenText);

      if (isSymbol) {
        if (tokenText.contains('۞')) {
          inPostMarkMode = true;
          postMarkCounter = -1;
        }
        tokens.add(SurahToken(text: '$tokenText ', isSymbol: true));
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
        tokens.add(SurahToken(
          text: '$tokenText ',
          isSymbol: false,
          verseNumber: verseNum,
          wordKey: wordKey,
        ));
      }
    }

    // رقم الآية
    tokens.add(SurahToken(
      text: ' ﴿$verseNum﴾ ',
      isSymbol: true,
      verseNumber: verseNum,
    ));
  }

  return tokens;
}
