import 'package:flutter/material.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/menu/custom/bottom_bar_animation_for_theme.dart';
import 'package:risala/menu/custom/choose_icon.dart';
import 'package:risala/menu/custom/custom_circle.dart';

import 'package:risala/menu/custom/custom_item/custom_text_bar_for_theme.dart';
import 'package:risala/menu/custom/custom_item/custom_text_bar_for_theme2.dart';
import 'package:risala/menu/custom/custom_item/custom_text_bar_for_theme3.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class ThemeView extends StatefulWidget {
  const ThemeView({super.key});

  @override
  State<ThemeView> createState() => _ThemeViewState();
}

class _ThemeViewState extends State<ThemeView> {
  late int selectedThemeIndex;
  late bool isGlassEffect = false;
  int sizeOfTextBar = sharedPref.getInt("sizeOfTextBar") ?? 1;

  final List<Color> themeMainColors = [
    const Color(0xFFFFFCBA),
    dilutionamberColor,
    const Color.fromARGB(255, 252, 255, 214),
    const Color(0xFFFBFFC4),
  ];

  final List<Color> themeScandColors = [
    const Color(0xFF463700),
    const Color(0xFF1E1E1E),
    const Color(0xFF005417),
    const Color(0xFF050041),
  ];

  @override
  void initState() {
    super.initState();
    selectedThemeIndex = sharedPref.getInt("myTheme") ?? 0;
    isGlassEffect = sharedPref.getBool("checkboxValue") ?? false;
    loadAllTranslations();
  }

  ////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////

  Translation? translation;

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    setState(() {
      translation = list.first;
    });
  }

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    int safeIndex = selectedThemeIndex.clamp(0, themeMainColors.length - 1);
    Color currentMainColor = themeMainColors[safeIndex];
    Color currentScandColor = themeScandColors[safeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
            translation != null
                ? translation!.appearance.isNotEmpty
                    ? translation!.appearance
                    : "المظهر"
                : "المظهر",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Text(
              translation != null
                  ? translation!.changeAppearance.isNotEmpty
                      ? translation!.changeAppearance
                      : "تغيير المظهر"
                  : "تغيير المظهر",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ChooseIcon(
                color:
                    sizeOfTextBar == 2 ? currentScandColor : currentMainColor,
                icon: Icons.grid_view_rounded,
                onTap: () {
                  setState(() {
                    sizeOfTextBar = 2;
                  });
                },
              ),
              ChooseIcon(
                color:
                    sizeOfTextBar == 1 ? currentScandColor : currentMainColor,
                icon: Icons.rectangle,
                onTap: () {
                  setState(() {
                    sizeOfTextBar = 1;
                  });
                },
              ),
              ChooseIcon(
                color:
                    sizeOfTextBar == 3 ? currentScandColor : currentMainColor,
                icon: Icons.grid_on,
                onTap: () {
                  setState(() {
                    sizeOfTextBar = 3;
                  });
                },
              ),
            ]),
            const SizedBox(height: 25),
            Text(
              translation != null
                  ? translation!.previewAppearance.isNotEmpty
                      ? translation!.previewAppearance
                      : "معاينة المظهر"
                  : "معاينة المظهر",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            if (sizeOfTextBar == 1)
              CustomTextBarForTheme(
                  sizeOfFont: sizeOfTextBar,
                  main: currentMainColor,
                  surah: "سورة",
                  aya: "آية",
                  where: "مكان",
                  number: "1"),
            if (sizeOfTextBar == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomTextBarForTheme2(
                      sizeOfFont: sizeOfTextBar,
                      main: currentMainColor,
                      surah: "سورة",
                      aya: "آية",
                      where: "مكان",
                      number: "1"),
                  CustomTextBarForTheme2(
                      sizeOfFont: sizeOfTextBar,
                      main: currentMainColor,
                      surah: "سورة",
                      aya: "آية",
                      where: "مكان",
                      number: "1"),
                ],
              ),
            if (sizeOfTextBar == 3)
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                children: [
                  CustomTextBarForTheme3(
                      sizeOfFont: sizeOfTextBar,
                      main: currentMainColor,
                      surah: "سورة",
                      aya: "آية",
                      where: "مكان",
                      number: "1"),
                  CustomTextBarForTheme3(
                      sizeOfFont: sizeOfTextBar,
                      main: currentMainColor,
                      surah: "سورة",
                      aya: "آية",
                      where: "مكان",
                      number: "1"),
                  CustomTextBarForTheme3(
                      sizeOfFont: sizeOfTextBar,
                      main: currentMainColor,
                      surah: "سورة",
                      aya: "آية",
                      where: "مكان",
                      number: "1"),
                ],
              ),

            const SizedBox(height: 15),

            // خيار تأثير الزجاج
            Card(
              color: whiteColor,
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      translation != null
                          ? translation!.glassEffect.isNotEmpty
                              ? translation!.glassEffect
                              : "تأثير الزجاج"
                          : "تأثير الزجاج",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Checkbox(
                      checkColor: currentMainColor,
                      activeColor: currentScandColor,
                      value: isGlassEffect,
                      onChanged: (value) {
                        setState(() {
                          isGlassEffect = value ?? false;
                        });
                      },
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // معاينة الشريط السفلي
            BottomBarAnimationForTheme(
              theme: isGlassEffect,
              icons: const [
                Icons.import_contacts_rounded,
                Icons.thunderstorm_rounded,
                Icons.gpp_good,
              ],
              onIconTap: (index) {},
              scand: currentScandColor,
              main: currentMainColor,
            ),

            const SizedBox(height: 30),
            Text(
              translation != null
                  ? translation!.chooseColor.isNotEmpty
                      ? translation!.chooseColor
                      : "اختر اللون"
                  : "اختر اللون",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // دوائر اختيار الألوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSelectableCircle(0),
                _buildSelectableCircle(1),
                _buildSelectableCircle(2),
                _buildSelectableCircle(3),
              ],
            ),
            const SizedBox(height: 40),

            // زر حفظ التغييرات
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentScandColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                onPressed: () async {
                  themeIndex = selectedThemeIndex;
                  await sharedPref.setInt("myTheme", selectedThemeIndex);
                  await sharedPref.setBool("checkboxValue", isGlassEffect);
                  await sharedPref.setInt("sizeOfTextBar", sizeOfTextBar);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: currentScandColor,
                        content: Text(translation != null
                            ? translation!.saved.isNotEmpty
                                ? translation!.saved
                                : "تم حفظ وتطبيق التغييرات بنجاح"
                            : "تم حفظ وتطبيق التغييرات بنجاح"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainView(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  translation != null
                      ? translation!.save.isNotEmpty
                          ? translation!.save
                          : "تطبيق الثيم"
                      : "تطبيق الثيم",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableCircle(int index) {
    bool isSelected = selectedThemeIndex == index;

    return Container(
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: blackColor,
                width: 3,
              ),
            )
          : null,
      child: CustomCircle(
        onTap: () {
          setState(() {
            selectedThemeIndex = index;
          });
        },
        outColor: themeMainColors[index],
        inColor: themeScandColors[index],
        borderColor: blackColor,
      ),
    );
  }
}
