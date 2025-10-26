import 'package:flutter/material.dart';
import 'package:risala/custom/custom_menu_itme/custom_menu_itme1.dart';
import 'package:risala/custom/custom_splash_screen/custom_splash_screen1.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/main.dart';
import 'package:risala/translation/translation.dart';

class Menu extends StatefulWidget {
  const Menu({
    super.key,
    required this.explanatoryTextForTitle,
    required this.saveText,
    required this.explanatoryTextForAya,
  });

  final String explanatoryTextForTitle;
  final String explanatoryTextForAya;
  final String saveText;

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late String selectedValue = sharedPref.getString("selectedValue") ?? "ar";
  late String selectedValue2 =
      sharedPref.getString("selectedValue2") ?? "Amiri";
  int chooselang = 0;

  double valueOfSize = sharedPref.getDouble("valueOfSize") ?? 26;
  double valueOfSize2 = sharedPref.getDouble("valueOfSize2") ?? 36;

  late Future<List<Translation>> _translationsFuture;
  late int _futureKey = 0;

  @override
  void initState() {
    super.initState();
    _translationsFuture =
        loadTranslation(selectedValue); // تحميل الترجمات حسب اللغة الحالية
  }

  /// تحديث اللغة مؤقتًا عند اختيارها من Dropdown
  void _updateLanguage(String newLang) {
    setState(() {
      selectedValue = newLang; // اللغة الجديدة مؤقتًا
      _futureKey++;
      _translationsFuture =
          loadTranslation(newLang); // تحميل الترجمات حسب اللغة الجديدة
    });
  }

  void _updateFont(String newFont) {
    setState(() {
      selectedValue2 = newFont;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Translation>>(
      key: ValueKey(_futureKey),
      future: _translationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('خطأ: ${snapshot.error}');
          return Text('خطأ: ${snapshot.error}');
        } else {
          final translations = snapshot.data!;
          final trans = translations.first;

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              if (chooselang == 0) ...[
                CustomMenuItme(
                  textItme: trans.languageAndText,
                  iconItme: Icons.language,
                  onPressed: () {
                    setState(() {
                      chooselang = 1;
                    });
                  },
                ),
                CustomMenuItme(
                  textItme: trans.support,
                  iconItme: Icons.support_agent,
                  onPressed: () {},
                ),
                CustomMenuItme(
                  textItme: trans.theme,
                  iconItme: Icons.color_lens,
                  onPressed: () async {
                    themeIndex = (themeIndex + 1) % themes.length;
                    await sharedPref.setInt("myTheme", themeIndex);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainView()),
                    );
                  },
                ),
              ] else ...[
                Card(
                  color: scandColor,
                  child: Center(
                    child: DropdownButton<String>(
                      value: selectedValue,
                      alignment: Alignment.center,
                      dropdownColor: scandColor,
                      style: TextStyle(color: mainColor),
                      items: [
                        {"code": "ar", "name": "العربية"},
                        {"code": "en", "name": "English"},
                        {"code": "sp", "name": "Español"},
                        {"code": "in", "name": "Bahasa Indonesia"},
                        {"code": "cn", "name": "中文"},
                        {"code": "bn", "name": "বাংলা"},
                        {"code": "it", "name": "Italiano"},
                        {"code": "ru", "name": "Русский"},
                        {"code": "jp", "name": "日本語"},
                      ].map((lang) {
                        return DropdownMenuItem(
                          value: lang["code"],
                          child: Text(lang["name"]!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _updateLanguage(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  trans.explanatoryTextForTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: valueOfSize,
                    fontFamily: selectedValue2,
                  ),
                ),
                Slider(
                  min: 24,
                  max: 32,
                  divisions: 8,
                  value: valueOfSize,
                  label: valueOfSize.round().toString(),
                  activeColor: scandColor,
                  inactiveColor: dilutionScandColor,
                  thumbColor: scandColor,
                  onChanged: (value) {
                    setState(() {
                      valueOfSize = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  trans.explanatoryTextForAya,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: valueOfSize2,
                    fontFamily: selectedValue2,
                  ),
                ),
                Slider(
                  min: 22,
                  max: 56,
                  divisions: 34,
                  value: valueOfSize2,
                  label: valueOfSize2.round().toString(),
                  activeColor: scandColor,
                  inactiveColor: dilutionScandColor,
                  thumbColor: scandColor,
                  onChanged: (value) {
                    setState(() {
                      valueOfSize2 = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  color: scandColor,
                  child: DropdownButton<String>(
                    value: selectedValue2,
                    alignment: Alignment.center,
                    dropdownColor: scandColor,
                    style: TextStyle(color: mainColor),
                    items: ["Amiri", "Lateef", "ScheherazadeNew"]
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _updateFont(value);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                MaterialButton(
                  color: scandColor,
                  splashColor: dilutionScandColor,
                  onPressed: () {
                    // حفظ اللغة والخطوط عند الضغط على حفظ
                    sharedPref.setString("selectedValue", selectedValue);
                    sharedPref.setDouble("valueOfSize", valueOfSize);
                    sharedPref.setString("selectedValue2", selectedValue2);
                    sharedPref.setDouble("valueOfSize2", valueOfSize2);

                    setState(() {
                      chooselang = 0;
                    });

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CustomSplashScreen1()),
                    );
                  },
                  child: Text(
                    trans.save,
                    style: TextStyle(color: mainColor),
                  ),
                ),
              ],
            ],
          );
        }
      },
    );
  }
}
