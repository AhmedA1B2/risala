import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/models/quran.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

final Map<int, List<List<SurahToken>>> _surahChunksCache = {};

void clearSurahCache() {
  _surahChunksCache.clear();
}

class SurahToken {
  final String text;
  final bool isSymbol;
  final int verseNumber;
  final String? wordKey;

  SurahToken({
    required this.text,
    required this.isSymbol,
    required this.verseNumber,
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
  bool _isLoading = true;

  List<List<SurahToken>> _chunks = [];

  final Map<int, GlobalKey> _verseKeys = {};

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (_surahChunksCache.containsKey(widget.surahNumber)) {
        _chunks = _surahChunksCache[widget.surahNumber]!;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final jsonString = await rootBundle.loadString(
        'assets/json/quran/$riwoya/surahs/${widget.surahNumber}.json',
      );

      final List<dynamic> jsonData = json.decode(jsonString);

      final result = await compute(
        processSurahInBackground,
        {
          'data': jsonData,
          'surahNumber': widget.surahNumber,
        },
      );

      _chunks = result;

      _surahChunksCache[widget.surahNumber] = result;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ERROR LOADING SURAH: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: scandColor,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedVerse != null &&
          _verseKeys.containsKey(widget.selectedVerse)) {
        final ctx = _verseKeys[widget.selectedVerse]!.currentContext;

        if (ctx != null) {
          widget.onVerseContext?.call(widget.selectedVerse!, ctx);
        }
      }
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      cacheExtent: 2000,
      itemCount: _chunks.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildBasmala();
        }

        final chunk = _chunks[index - 1];

        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text.rich(
                TextSpan(
                  children: _buildChunkSpans(chunk),
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                softWrap: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBasmala() {
    if (widget.surahNumber == 1 && sharedPref.getString("riwoya") == "hafs") {
      return const SizedBox();
    }

    if (widget.surahNumber == 9) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Text(
        "بِسْمِ اللَّهِ الرَّحْمٰنِ الرَّحِيمِ",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: quranfontSize,
        ),
      ),
    );
  }

  List<InlineSpan> _buildChunkSpans(List<SurahToken> tokens) {
    final List<InlineSpan> spans = [];

    String fontFamily = quranfontFamily;

    if (fontFamily != "UthmanicQaloun" && fontFamily != "UthmanicHafs") {
      fontFamily = "UthmanicHafs";
    }

    for (final token in tokens) {
      if (token.text.isEmpty) {
        final key = _verseKeys.putIfAbsent(
          token.verseNumber,
          () => GlobalKey(),
        );

        spans.add(
          WidgetSpan(
            child: SizedBox(
              key: key,
              width: 0,
              height: 0,
            ),
          ),
        );

        continue;
      }

      final bool isVerseSelected = widget.selectedVerse == token.verseNumber;

      final bool isWordSelected = widget.selectedWordKey == token.wordKey;

      if (token.isSymbol) {
        final bool isVerseNum = token.text.contains('﴿');

        spans.add(
          TextSpan(
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
                          : token.verseNumber,
                    );

                    widget.onWordSelected?.call('');
                  })
                : null,
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.text,
            style: TextStyle(
              fontFamily: fontFamily,
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
                widget.onVerseSelected?.call(null);

                final key = token.wordKey ?? '';

                widget.onWordSelected?.call(
                  isWordSelected ? '' : key,
                );
              },
          ),
        );
      }
    }

    return spans;
  }
}

List<List<SurahToken>> processSurahInBackground(
  Map<String, dynamic> params,
) {
  final List<dynamic> rawData = params['data'];

  final int surahNumber = params['surahNumber'];

  final List<Quran> allQuran = rawData.map((e) => Quran.fromMap(e)).toList();

  final currentSurah =
      allQuran.where((v) => v.surahNumber == surahNumber).toList();

  final List<List<SurahToken>> chunks = [];

  List<SurahToken> currentChunk = [];

  final RegExp regex = RegExp(r'([۞۩۝ٖٞٗ]+|[^\s۞۩۝ٖٞٗ]+)');

  final RegExp symbolRegex = RegExp(r'[۞۩۝ٖٞٗ]');

  String fixText(String text) {
    return text.replaceAll('ٞ', 'ٌ').replaceAll('ٗ', 'ً').replaceAll('ٖ', 'ٍ');
  }

  int verseCounter = 0;

  for (final verse in currentSurah) {
    verseCounter++;

    final int verseNum = verse.verseNumber;

    final String verseText = fixText(verse.content);

    currentChunk.add(
      SurahToken(
        text: "",
        isSymbol: true,
        verseNumber: verseNum,
      ),
    );

    final matches = regex.allMatches(verseText);

    int wordCounter = 0;

    for (final match in matches) {
      final tokenText = match.group(0)!;

      final bool isSymbol = symbolRegex.hasMatch(tokenText);

      if (isSymbol) {
        currentChunk.add(
          SurahToken(
            text: '$tokenText ',
            isSymbol: true,
            verseNumber: verseNum,
          ),
        );
      } else {
        wordCounter++;

        currentChunk.add(
          SurahToken(
            text: '$tokenText ',
            isSymbol: false,
            verseNumber: verseNum,
            wordKey: "$verseNum-$wordCounter",
          ),
        );
      }
    }

    currentChunk.add(
      SurahToken(
        text: ' ﴿$verseNum﴾ ',
        isSymbol: true,
        verseNumber: verseNum,
      ),
    );

    /// تقسيم السورة إلى chunks
    /// كل chunk يحتوي 20 آية فقط
    if (verseCounter % 20 == 0) {
      chunks.add(currentChunk);
      currentChunk = [];
    }
  }

  if (currentChunk.isNotEmpty) {
    chunks.add(currentChunk);
  }

  return chunks;
}
