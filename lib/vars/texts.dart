//      FONT SIZE

import 'package:risala/main.dart';

double mytitlefontSize =
    sharedPref.getDouble("valueOfSize") ?? 26; //24 -> 26 -> 32
double quranfontSize =
    sharedPref.getDouble("valueOfSize2") ?? 36; //22 -> 36 -> 56

//   FONT FAMILY

String quranfontFamily = sharedPref.getString("selectedValue2") ??
    "Amiri"; //Lateef // Amiri // ScheherazadeNew
