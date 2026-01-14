import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bg/custom_bg_of_home.dart';
import 'package:risala/custom/custom_dialogue/custom_dialogue.dart';
import 'package:risala/custom/custom_splash_screen/custom_splash_screen1.dart';
import 'package:risala/main.dart';
import 'package:risala/vars/colors.dart';

class CustomChooseLangView extends StatefulWidget {
  const CustomChooseLangView({super.key});

  @override
  State<CustomChooseLangView> createState() => _CustomChooseLangViewState();
}

class _CustomChooseLangViewState extends State<CustomChooseLangView> {
  late String selectedValue = sharedPref.getString("selectedValue") ?? "ar";
  late String selectedValue2 =
      sharedPref.getString("selectedValue2") ?? "Amiri";
  int chooselang = 0;
  bool showDialogue = false;

  double valueOfSize = sharedPref.getDouble("valueOfSize") ?? 26;
  double valueOfSize2 = sharedPref.getDouble("valueOfSize2") ?? 36;

  @override
  void initState() {
    super.initState();
// تحميل الترجمات حسب اللغة الحالية
  }

  /// تحديث اللغة مؤقتًا عند اختيارها من Dropdown
  void _updateLanguage(String newLang) {
    setState(() {
      selectedValue = newLang; // اللغة الجديدة مؤقتًا
// تحميل الترجمات حسب اللغة الجديدة
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(
        children: [
          const CustomBg(topMargin: 50, topBorderRadius: 1000),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 50),
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
              IconButton(
                onPressed: () {
                  setState(() {
                    showDialogue = true;
                  });
                },
                icon: const Icon(
                  Icons.check_circle,
                  size: 50,
                ),
              )
            ],
          ),
          if (showDialogue)
            CustomDialogue(
              iconOk: Icons.check_circle,
              iconNo: Icons.cancel,
              text: 'هل أنت متأكد من أنك تريد استخدام هذه اللغة ؟',
              onPressediconNo: () {
                setState(() {
                  showDialogue = false;
                });
              },
              onPressediconOk: () {
                sharedPref.setString("selectedValue", selectedValue);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomSplashScreen1()),
                );
              },
            ),
        ],
      ),
    );
  }
}
