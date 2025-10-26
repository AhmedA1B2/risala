import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';

/// دالة لتحميل الترجمات من ملف JSON
Future<List<Translation>> loadTranslation(String? lang) async {
  // تحميل النص من ملف JSON
  String jsonString =
      await rootBundle.loadString('assets/language/the_translation.json');

  // تحويله إلى List
  List<dynamic> jsonData = json.decode(jsonString);

  // استخدم اللغة المرسلة، وإذا لم توجد استخدم اللغة المحفوظة أو العربية
  lang ??= sharedPref.getString("selectedValue") ?? "ar";

  // تحويل القائمة إلى كائنات Translation
  return jsonData.map((item) => Translation.fromMap(item, lang!)).toList();
}

/// دالة ترجمة نص بناءً على المفتاح (key)
Future<String> translate(String key) async {
  final translations =
      await loadTranslation(sharedPref.getString("selectedValue") ?? "ar");
  // ابحث عن النص الذي يحتوي على المفتاح المطلوب
  try {
    final item = translations.firstWhere((t) => t.key == key);
    return item.text;
  } catch (e) {
    return key; // في حال لم يتم العثور على المفتاح
  }
}
