import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';

class SabhuhView extends StatefulWidget {
  const SabhuhView({super.key});

  @override
  State<SabhuhView> createState() => _SabhuhViewState();
}

class _SabhuhViewState extends State<SabhuhView> {
  int conter = 0;
  bool showAdhkarView = false;

  List<dynamic> adhkarList = [];
  Map<String, dynamic>? selectedDhikr;

  @override
  void initState() {
    super.initState();
    loadAdhkar();
  }

  Future<void> loadAdhkar() async {
    final String response =
        await rootBundle.loadString('assets/json/adhkar/adhkar.json');
    final data = await json.decode(response);
    setState(() {
      adhkarList = data;
      if (adhkarList.isNotEmpty) {
        selectedDhikr = adhkarList[0];
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
                          sharedPref.getString("selectedValue") != "ar" &&
                                  sharedPref.getString("selectedValue") != null
                              ? selectedDhikr![
                                  sharedPref.getString("selectedValue")]
                              : selectedDhikr!["arabic"],
                          style: TextStyle(
                            color: scandColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sharedPref.getString("selectedValue") != "ar" &&
                                  sharedPref.getString("selectedValue") != null
                              ? selectedDhikr![
                                  "explanation${sharedPref.getString("selectedValue")}"]
                              : selectedDhikr!["explanationar"] ?? "",
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

        // زر الأذكار العلوي
        Positioned(
          top: 40,
          right: 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
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

        // عرض الأذكار
        if (showAdhkarView)
          Center(
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
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView(
                padding: const EdgeInsets.all(12),
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
                  for (var dhikr in adhkarList)
                    ListTile(
                      title: Text(
                        sharedPref.getString("selectedValue") != "ar" &&
                                sharedPref.getString("selectedValue") != null
                            ? dhikr[sharedPref.getString("selectedValue")]
                            : dhikr["arabic"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          color: blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedDhikr = dhikr;
                          showAdhkarView = false;
                          conter = 0;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
