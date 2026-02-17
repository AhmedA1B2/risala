import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/sabhuh/custom/custom_sabhuh_item.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class SabhuhView extends StatefulWidget {
  const SabhuhView({super.key});

  @override
  State<SabhuhView> createState() => _SabhuhViewState();
}

class _SabhuhViewState extends State<SabhuhView> {
  int conter = sharedPref.getInt("sabhuhConter") ?? 0;
  String myDhkar = sharedPref.getString("myDhkar") ?? "tsbyh";
  bool isTap = false;
  bool showAdhkarView = false;

  List<dynamic> adhkarList = [];
  Map<String, dynamic>? selectedDhikr;

  @override
  void initState() {
    super.initState();
    loadAdhkar();
    loadAllTranslations();
  }

  Future<void> loadAdhkar() async {
    myDhkar = sharedPref.getString("myDhkar") ?? "tsbyh";
    final String response =
        await rootBundle.loadString('assets/json/adhkar/$myDhkar.json');
    final List<dynamic> data = await json.decode(response);

    String? savedDhikr = sharedPref.getString("selectedDhikrText");

    setState(() {
      adhkarList = data;
      if (adhkarList.isNotEmpty) {
        // البحث عن الذكر المحفوظ
        var found = adhkarList.firstWhere(
          (element) => element['arabic'] == savedDhikr,
          orElse: () => null,
        );

        // إذا وجدنا المحفوظ نضعه، وإلا نضع أول عنصر في القائمة
        selectedDhikr = found ?? adhkarList[0];
      }
    });
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
    return Stack(
      children: [
        SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // البطاقة الرئيسية للعداد
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scandColor,
                      border: Border.all(color: dilutionScandColor, width: 2),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 24),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$conter",
                            style: const TextStyle(
                              color: whiteColor,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                conter = 0;
                                sharedPref.setInt("sabhuhConter", conter);
                              });
                            },
                            icon: const Icon(
                              Icons.restart_alt_rounded,
                              size: 48,
                              color: whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // بطاقة الذكر
                if (selectedDhikr != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: scandColor, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          (sharedPref.getString("selectedValue") != "ar" &&
                                  sharedPref.getString("selectedValue") != null)
                              ? (selectedDhikr?[
                                      sharedPref.getString("selectedValue")] ??
                                  "")
                              : (selectedDhikr?["arabic"] ?? ""),
                          style: TextStyle(
                            color: scandColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (sharedPref.getString("selectedValue") != "ar" &&
                                  sharedPref.getString("selectedValue") != null)
                              ? (selectedDhikr?[
                                      "explanation${sharedPref.getString("selectedValue")}"] ??
                                  "")
                              : (selectedDhikr?["explanationar"] ?? ""),
                          style: TextStyle(
                            color: dilutionScandColor,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 160,
                )
              ],
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: scandColor,
                  border: Border.all(color: dilutionScandColor, width: 2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black38,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      conter += 1;
                      sharedPref.setInt("sabhuhConter", conter);
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 56,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ),
        ),

        // عرض الأذكار
        if (showAdhkarView)
          Positioned.fill(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        translation != null
                            ? translation!.adhkar.isNotEmpty
                                ? translation!.adhkar
                                : "الأذكار"
                            : "الأذكار",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: blackColor),
                      ),
                    ),
                    const Divider(),

                    // الحل هنا: استخدام Expanded ليأخذ الجزء المتغير المساحة المتبقية
                    Expanded(
                      child: isTap
                          ? ListView.builder(
                              // أفضل من for loop للأداء
                              itemCount: adhkarList.length,
                              itemBuilder: (context, index) {
                                var dhikr = adhkarList[index];
                                return ListTile(
                                  title: Column(
                                    children: [
                                      Text(
                                        sharedPref.getString("selectedValue") !=
                                                    "ar" &&
                                                sharedPref.getString(
                                                        "selectedValue") !=
                                                    null
                                            ? dhikr[sharedPref
                                                .getString("selectedValue")]
                                            : dhikr["arabic"],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: blackColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedDhikr = dhikr;
                                      sharedPref.setString("selectedDhikrText",
                                          dhikr['arabic'] ?? "");

                                      showAdhkarView = false;
                                      isTap = false;
                                      conter = 0;
                                    });
                                  },
                                );
                              },
                            )
                          : GridView.count(
                              crossAxisCount: 2,
                              children: [
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.morning.isNotEmpty
                                          ? translation!.morning
                                          : "الصباح"
                                      : "الصباح",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "sbah");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.evening.isNotEmpty
                                          ? translation!.evening
                                          : "المساء"
                                      : "المساء",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "msaa");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.prayerTime.isNotEmpty
                                          ? translation!.prayerTime
                                          : "االصلاة"
                                      : "الصلاة",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "slah");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.sleep.isNotEmpty
                                          ? translation!.sleep
                                          : "النوم"
                                      : "النوم",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "noom");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.tasbihAndDhikr.isNotEmpty
                                          ? translation!.tasbihAndDhikr
                                          : "تسبيح وذكر"
                                      : "تسبيح وذكر",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "tsbyh");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.wakingUp.isNotEmpty
                                          ? translation!.wakingUp
                                          : "الاستيقاظ"
                                      : "الاستيقاظ",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "estyqad");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.adhan.isNotEmpty
                                          ? translation!.adhan
                                          : "الأذان"
                                      : "الأذان",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "adan");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.mosque.isNotEmpty
                                          ? translation!.mosque
                                          : "المسجد"
                                      : "المسجد",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "msjed");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.ablution.isNotEmpty
                                          ? translation!.ablution
                                          : "الوضوء"
                                      : "الوضوء",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "wdoa");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.homePlace.isNotEmpty
                                          ? translation!.homePlace
                                          : "المنزل"
                                      : "المنزل",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "mnzl");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.restroom.isNotEmpty
                                          ? translation!.restroom
                                          : "الخلاء"
                                      : "الخلاء",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "khla");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                                CustomSabhuhItem(
                                  text: translation != null
                                      ? translation!.food.isNotEmpty
                                          ? translation!.food
                                          : "الطعام"
                                      : "الطعام",
                                  onTap: () {
                                    sharedPref.setString("myDhkar", "taam");
                                    isTap = true;
                                    loadAdhkar();
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(
                      height: 60,
                    )
                  ],
                ),
              ),
            ),
          ),
        // زر الأذكار العلوي
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          top: showAdhkarView ? 10 : 40,
          right: showAdhkarView ? 25 : 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isTap = false;
                showAdhkarView = !showAdhkarView;
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: dilutionScandColor, width: 2),
                  color: scandColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  showAdhkarView == false
                      ? translation != null
                          ? translation!.adhkar.isNotEmpty
                              ? translation!.adhkar
                              : "الأذكار"
                          : "الأذكار"
                      : "X",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: whiteColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
