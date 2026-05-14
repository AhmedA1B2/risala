import 'dart:convert';
import 'dart:math' as math;
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

class CustomSurahPageForSs extends StatefulWidget {
  const CustomSurahPageForSs({
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
  State<CustomSurahPageForSs> createState() => _CustomSurahPageForSsState();
}

class _CustomSurahPageForSsState extends State<CustomSurahPageForSs> {
  List<SurahToken>? _processedTokens;
  bool _isLoading = true;

  List<InlineSpan>? _cachedSpans;

  final Map<int, GlobalKey> _verseKeys = {};

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  int _currentRenderLimit = 30;

  @override
  void initState() {
    super.initState();
    _loadDataIsolated(riwoya);
  }

  Future<void> _loadDataIsolated(String riwoya) async {
    try {
      if (_surahCache.containsKey(widget.surahNumber)) {
        _processedTokens = _surahCache[widget.surahNumber];
        _startProgressiveRendering();
        return;
      }

      final String jsonString = await rootBundle.loadString(
          'assets/json/quran/$riwoya/surahs/${widget.surahNumber}.json');

      final List<dynamic> jsonData = json.decode(jsonString);

      final resultTokens = await compute(processSurahInBackground, {
        'data': jsonData,
        'surahNumber': widget.surahNumber,
      });

      _surahCache[widget.surahNumber] = resultTokens;

      if (mounted) {
        _processedTokens = resultTokens;
        _startProgressiveRendering();
      }
    } catch (e) {
      debugPrint("Error loading surah: $e");
    }
  }

  void _startProgressiveRendering() {
    if (widget.selectedVerse != null) {
      _currentRenderLimit = math.max(30, widget.selectedVerse! + 5);
    } else {
      _currentRenderLimit = 30;
    }

    setState(() {
      _isLoading = false;
    });

    _renderRestProgressively();
  }

  Future<void> _renderRestProgressively() async {
    if (_processedTokens == null) return;

    int maxVerses = _processedTokens!.isNotEmpty
        ? (_processedTokens!.last.verseNumber ?? 300)
        : 300;

    while (_currentRenderLimit < maxVerses) {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      setState(() {
        _currentRenderLimit += 30;
      });
    }
  }

  void _buildSpansIfNeeded() {
    _cachedSpans = [];

    for (final token in _processedTokens!) {
      if (token.verseNumber != null &&
          token.verseNumber! > _currentRenderLimit) {
        break;
      }

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

    _buildSpansIfNeeded();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_verseKeys.isNotEmpty) {
        if (widget.selectedVerse != null &&
            _verseKeys.containsKey(widget.selectedVerse)) {
          final ctx = _verseKeys[widget.selectedVerse]!.currentContext;
          if (ctx != null) {
            widget.onVerseContext?.call(widget.selectedVerse!, ctx);
          }
        }
        _verseKeys.forEach((k, v) {
          if (v.currentContext != null) {
            widget.onVerseContext?.call(k, v.currentContext!);
          }
        });
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: RepaintBoundary(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.surahNumber == 1 &&
                      sharedPref.getString("riwoya") == "hafs"
                  ? const SizedBox()
                  : widget.surahNumber != 9
                      ? Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "بِسْمِ اللَّهِ الرَّحْمٰنِ الرَّحِيمِ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: quranfontSize,
                            ),
                          ))
                      : const SizedBox(),
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

  final List<Quran> allQuran = rawData.map((e) => Quran.fromMap(e)).toList();

  final currentSurah =
      allQuran.where((v) => v.surahNumber == surahNumber).toList();

  final List<SurahToken> tokens = [];

  final RegExp regex = RegExp(r'([۞۩۝ٖٞٗ]+|[^\s۞۩۝ٖٞٗ]+)');
  final RegExp symbolRegex = RegExp(r'[۞۩۝ٖٞٗ]');

  String fixText(String text) {
    return text.replaceAll('ٞ', 'ٌ').replaceAll('ٗ', 'ً').replaceAll('ٖ', 'ٍ');
  }

  for (final verse in currentSurah) {
    final int verseNum = verse.verseNumber;
    final String verseText = fixText(verse.content);

    tokens.add(SurahToken(text: "", isSymbol: true, verseNumber: verseNum));

    final matches = regex.allMatches(verseText);

    int wordCounter = 0;

    for (final match in matches) {
      final tokenText = match.group(0)!;
      final bool isSymbol = symbolRegex.hasMatch(tokenText);

      if (isSymbol) {
        tokens.add(SurahToken(
          text: '$tokenText ',
          isSymbol: true,
          verseNumber: verseNum,
        ));
      } else {
        wordCounter++;

        final wordKey = "$verseNum-$wordCounter";

        tokens.add(SurahToken(
          text: '$tokenText ',
          isSymbol: false,
          verseNumber: verseNum,
          wordKey: wordKey,
        ));
      }
    }

    tokens.add(SurahToken(
      text: ' ﴿$verseNum﴾ ',
      isSymbol: true,
      verseNumber: verseNum,
    ));
  }

  return tokens;
}
