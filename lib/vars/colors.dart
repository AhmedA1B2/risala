
import 'package:flutter/material.dart';
import 'package:risala/main.dart';

const Color whiteColor = Colors.white;
const Color blackColor = Colors.black;
const Color amberColor = Colors.amber;
const Color dilutionamberColor = Color(0xFFffecb3);

final List<Map<String, Color>> themes = [
  {
    "scand": const Color(0xFF463700),
    "main": const Color(0xFFFFFCBA),
    "dilution": const Color(0xFFA68200),
  },
  {
    "scand": const Color(0xFF020611),
    "main": dilutionamberColor,
    "dilution": const Color(0xFF0C2140),
  },
  {
    "scand": const Color(0xFF020609),
    "main": const Color(0xFFFBFFC4),
    "dilution": const Color(0xFF102F16),
  },
  {
    "scand": const Color(0xFF010204),
    "main": const Color(0xFFFBFFC4),
    "dilution": const Color(0xFF1B303D),
  },
];

int _safeThemeIndex(int index) {
  if (index < 0 || index >= themes.length) return 0;
  return index;
}

// مصدر الحالة الموحد للثيم في التطبيق.
final ValueNotifier<int> themeNotifier = ValueNotifier<int>(
  _safeThemeIndex(sharedPref.getInt('myTheme') ?? 0),
);

// نحافظ على themeIndex حتى لا تتعطل الملفات القديمة التي تستخدمه.
int get themeIndex => themeNotifier.value;

set themeIndex(int value) {
  final safeIndex = _safeThemeIndex(value);

  if (themeNotifier.value != safeIndex) {
    themeNotifier.value = safeIndex;
  }
}

Color get scandColor => themes[themeIndex]["scand"]!;
Color get mainColor => themes[themeIndex]["main"]!;
Color get dilutionScandColor => themes[themeIndex]["dilution"]!;
