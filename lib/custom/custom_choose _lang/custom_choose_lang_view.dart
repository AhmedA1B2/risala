import 'package:flutter/material.dart';
import 'package:risala/custom/custom_bg/custom_bg2.dart';
import 'package:risala/custom/custom_dialogue/custom_dialogue.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class CustomChooseLangView extends StatefulWidget {
  const CustomChooseLangView({super.key});

  @override
  State<CustomChooseLangView> createState() => _CustomChooseLangViewState();
}

class _CustomChooseLangViewState extends State<CustomChooseLangView> {
  late String selectedValue = sharedPref.getString("selectedValue") ?? "ar";
  late String selectedFont =
      sharedPref.getString("selectedValue2") ?? "UthmanicHafs";

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  int chooselang = 0;
  bool showDialogue = false;

  double valueOfSize = sharedPref.getDouble("valueOfSize") ?? 26;
  double valueOfSize2 = sharedPref.getDouble("valueOfSize2") ?? 36;
//
  Translation? translation;

  Future<void> loadAllTranslations(String lang) async {
    final list = await loadTranslation(lang);
    setState(() {
      translation = list.first;
    });
  }

//
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

//
  @override
  void initState() {
    super.initState();
  }

  void _updateLanguage(String newLang) {
    setState(() {
      selectedValue = newLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Stack(
        children: [
          const CustomBg2(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 250,
                child: Hero(
                  tag: "mosq",
                  child: Image(
                    image: AssetImage("assets/images/mosq.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Center(
                child: SizedBox(
                  height: 250,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: whiteColor,
                        boxShadow: const [
                          BoxShadow(
                              blurRadius: 12,
                              color: blackColor,
                              offset: Offset(0, 1))
                        ],
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
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
                        Row(
                          children: [
                            Radio<String>(
                              value: "hafs",
                              activeColor: scandColor,
                              groupValue: riwoya,
                              onChanged: (value) {
                                setState(() {
                                  riwoya = value!;
                                  if (selectedFont != "UthmanicHafs") {
                                    selectedFont = "UthmanicHafs";
                                  }
                                });
                              },
                            ),
                            _buildSectionTitle(translation!.hafsNarration),

                            const SizedBox(width: 20), // مسافة بين الخيارين

                            // خيار رواية قالون
                            Radio<String>(
                              value: "qaloun",
                              activeColor: scandColor,
                              // ignore: deprecated_member_use
                              groupValue: riwoya,
                              onChanged: (value) {
                                setState(() {
                                  riwoya = value!;
                                  if (selectedFont != "UthmanicQaloun") {
                                    selectedFont = "UthmanicQaloun";
                                  }
                                });
                              },
                            ),

                            _buildSectionTitle(translation!.qaloonNarration),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showDialogue = true;
                              loadAllTranslations(selectedValue);
                            });
                          },
                          icon: Icon(
                            Icons.check_circle,
                            color: scandColor,
                            size: 80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showDialogue)
            CustomDialogue(
              iconOk: Icons.check_circle,
              iconNo: Icons.cancel,
              text: translation != null &&
                      translation!.confirmLanguageChange.isNotEmpty
                  ? translation!.confirmLanguageChange
                  : 'هل أنت متأكد من أنك تريد استخدام هذه اللغة ؟',
              onPressediconNo: () {
                setState(() {
                  showDialogue = false;
                });
              },
              onPressediconOk: () {
                sharedPref.setString("selectedValue2", selectedFont);
                sharedPref.setString("riwoya", riwoya);
                sharedPref.setString("selectedValue", selectedValue);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainView()),
                );
              },
            ),
        ],
      ),
    );
  }
}
