import 'package:flutter/material.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/custom/custom_surah_page_for_ss.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/main.dart';
import 'package:risala/translation/translation.dart';

class LanguageTextSettingsView extends StatefulWidget {
  const LanguageTextSettingsView({super.key});

  @override
  State<LanguageTextSettingsView> createState() =>
      _LanguageTextSettingsViewState();
}

class _LanguageTextSettingsViewState extends State<LanguageTextSettingsView> {
  late String selectedValue = sharedPref.getString("selectedValue") ?? "ar";

  late String selectedFont =
      sharedPref.getString("selectedValue2") ?? "UthmanicHafs";

  double titleSize = sharedPref.getDouble("valueOfSize") ?? 26;

  double ayaSize = sharedPref.getDouble("valueOfSize2") ?? 36;

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  late Future<List<Translation>> _translationsFuture;
  int _futureKey = 0;

  @override
  void initState() {
    super.initState();
    _translationsFuture = loadTranslation(selectedValue);
    if (selectedFont != "UthmanicQaloun" && selectedFont != "UthmanicHafs") {
      selectedFont = "UthmanicHafs";
      sharedPref.setString("selectedValue2", selectedFont);
    }
  }

  void _updateLanguage(String newLang) {
    setState(() {
      selectedValue = newLang;
      _futureKey++;
      _translationsFuture = loadTranslation(newLang);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: scandColor,
        iconTheme: IconThemeData(color: mainColor),
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Translation>>(
        key: ValueKey(_futureKey),
        future: _translationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final trans = snapshot.data!.first;

          return Column(
            children: [
              /// المحتوى
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    /// =======================
                    /// LANGUAGE
                    /// =======================
                    _buildSectionTitle(trans.languageAndText),

                    const SizedBox(height: 10),

                    _buildCard(
                      child: DropdownButtonFormField<String>(
                        value: selectedValue,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        dropdownColor: scandColor,
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
                            child: Text(
                              lang["name"]!,
                              style: TextStyle(color: mainColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateLanguage(value);
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

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
                        _buildSectionTitle(trans.hafsNarration),

                        const SizedBox(width: 20), // مسافة بين الخيارين

                        // خيار رواية قالون
                        Radio<String>(
                          value: "qaloun",
                          activeColor: scandColor,
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

                        _buildSectionTitle(trans.qaloonNarration),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// =======================
                    /// TITLE SIZE
                    /// =======================
                    _buildSectionTitle(trans.explanatoryTextForTitle),

                    const SizedBox(height: 10),

                    _buildPreviewText(trans.explanatoryTextForTitle, titleSize),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: scandColor,
                        inactiveTrackColor: dilutionScandColor,
                        thumbColor: scandColor,
                        overlayColor: scandColor.withOpacity(.2),
                      ),
                      child: Slider(
                        min: 24,
                        max: 32,
                        divisions: 8,
                        value: titleSize,
                        label: titleSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            titleSize = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// =======================
                    /// AYA SIZE
                    /// =======================
                    _buildSectionTitle(trans.explanatoryTextForAya),

                    const SizedBox(height: 10),

                    _buildPreviewText(trans.explanatoryTextForAya, ayaSize),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: scandColor,
                        inactiveTrackColor: dilutionScandColor,
                        thumbColor: scandColor,
                        overlayColor: scandColor.withOpacity(.2),
                      ),
                      child: Slider(
                        min: 22,
                        max: 56,
                        divisions: 34,
                        value: ayaSize,
                        label: ayaSize.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            ayaSize = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// =======================
                    /// FONT
                    /// =======================
                    _buildSectionTitle("Font"),

                    const SizedBox(height: 10),

                    _buildCard(
                      child: DropdownButtonFormField<String>(
                        value: selectedFont,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        dropdownColor: scandColor,
                        items: [
                          riwoya == "qaloun"
                              ? "UthmanicQaloun"
                              : "UthmanicHafs",
                        ]
                            .map((font) => DropdownMenuItem(
                                  value: font,
                                  child: Text(
                                    font,
                                    style: TextStyle(
                                        fontFamily: font, color: mainColor),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedFont = value;
                            });
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              /// =======================
              /// SAVE BUTTON
              /// =======================
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scandColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      sharedPref.setString("selectedValue", selectedValue);
                      sharedPref.setDouble("valueOfSize", titleSize);
                      sharedPref.setString("selectedValue2", selectedFont);
                      sharedPref.setDouble("valueOfSize2", ayaSize);
                      sharedPref.setString("riwoya", riwoya);
                      clearSurahCache();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainView(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text(
                      trans.save,
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ===== Helpers =====

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPreviewText(String text, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontFamily: selectedFont,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: scandColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
