import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/models/quran.dart';
import 'package:risala/vars/colors.dart';

import 'package:risala/vars/texts.dart';

//=====================
// تحميل JSON
//=====================
Future<List<Quran>> loadQuranFromJson() async {
  final String jsonString =
      await rootBundle.loadString('assets/json/quran/quran.json');

  final List<dynamic> data = json.decode(jsonString);

  return data.map((e) => Quran.fromMap(e)).toList();
}

//=====================
// الصفحة
//=====================
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
  int? _selectedVerse;
  String? _selectedWordKey;

  final Map<int, GlobalKey> _verseKeys = {};

  late Future<List<Quran>> _quranFuture;

  @override
  void initState() {
    super.initState();

    _selectedVerse = widget.selectedVerse;
    _selectedWordKey = widget.selectedWordKey;

    _quranFuture = loadQuranFromJson();
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
    return FutureBuilder<List<Quran>>(
      future: _quranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: scandColor,
          ));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ في تحميل القرآن: ${snapshot.error}'),
          );
        }

        final allQuran = snapshot.data ?? [];

        final currentSurah =
            allQuran.where((v) => v.surahNumber == widget.surahNumber).toList();

        final List<InlineSpan> allSpans = [];

        for (final verse in currentSurah) {
          final int verseNum = verse.verseNumber;
          final String verseText = fixQuranText(verse.content);

          final bool isVerseSelected = widget.selectedVerse == verseNum;

          final key = _verseKeys.putIfAbsent(
            verseNum,
            () => GlobalKey(),
          );

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
                    _selectedVerse =
                        _selectedVerse == verseNum ? null : verseNum;

                    _selectedWordKey = null;
                  });

                  widget.onVerseSelected?.call(_selectedVerse);
                },
            ),
          );
        }

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
      },
    );
  }
}
