import 'package:flutter/material.dart';
import 'package:risala/main.dart';

const Color whiteColor = Colors.white;
const Color blackColor = Colors.black;
const Color amberColor = Colors.amber;
const Color dilutionamberColor = Color(0xFFffecb3);

int themeIndex = sharedPref.getInt("myTheme") ?? 0;

final List<Map<String, Color>> themes = [
  {
    "scand": const Color(0xFF463700),
    "main": const Color(0xFFFFFCBA),
    "dilution": const Color(0xFFA68200),
  },
  {
    "scand": const Color(0xFF1E1E1E),
    "main": dilutionamberColor,
    "dilution": const Color(0xFF505050),
  },
  {
    "scand": const Color(0xFF050041),
    "main": const Color(0xFFFBFFC4),
    "dilution": const Color.fromARGB(255, 23, 16, 105),
  },
  {
    "scand": const Color(0xFF1A2A03),
    "main": const Color(0xFFFBFFC4),
    "dilution": const Color(0xFF286305),
  },
];

Color get scandColor => themes[themeIndex]["scand"]!;
Color get mainColor => themes[themeIndex]["main"]!;
Color get dilutionScandColor => themes[themeIndex]["dilution"]!;
