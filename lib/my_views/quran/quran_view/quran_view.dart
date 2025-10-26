import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_animation/bottom_bar_animation2.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/custom/custom_snack_bar/custom_snack_bar.dart';
import 'package:risala/main.dart';
import 'package:risala/models/reciters.dart';
import 'package:risala/models/tafsir.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/custom/custom_app_bar.dart';
import 'package:risala/my_views/quran/custom/custom_surah_name.dart';
import 'package:risala/my_views/quran/custom/custom_surah_page.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:risala/translation/translation.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';

class QuranView extends StatefulWidget {
  const QuranView({
    super.key,
    required this.surahNumber,
    required this.x,
    this.searchedVerse,
  });

  final int surahNumber;
  final int? searchedVerse;
  final int x;

  @override
  State<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends State<QuranView> {
  final String clientId = "e3af92df-f3d7-4d3a-9ccc-152c532492ee";
  final String clientSecret = "1tfKz8HWd3w9iyGkBTkv_b~N8t";
  final String tokenEndpoint = "https://oauth2.quran.foundation/oauth2/token";
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _player = AudioPlayer();

  String? accessToken;
  IconData iconData = Icons.play_arrow;

  bool isloading = false;

  // الخريطة لتخزين BuildContext لكل آية
  final Map<int, BuildContext> verseContexts = {};
  // الخريطة لتخزين BuildContext لكل كلمة
  final Map<String, BuildContext> wordContexts = {};

  int? highlightedWordVerse;
  int? highlightedVerse;
  int? highlightedWord;
  int? ayasaved = sharedPref.getInt('ayasaved');
  int? surahsaved = sharedPref.getInt('surahsaved');
  String? surahName;

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////

  Future<String?> getSurahNameByNumber(int surahNumber) async {
    // تحميل النص من ملف JSON
    String jsonString = await rootBundle.loadString('assets/json/surahs.json');

    // تحويل النص إلى List
    List<dynamic> jsonData = json.decode(jsonString);

    // البحث عن السورة التي رقمها يطابق surahNumber
    var surahData = jsonData.firstWhere(
      (item) => item["number"] == surahNumber,
      orElse: () => null, // في حال لم يجد السورة
    );

    // إذا وُجدت السورة، أعد اسمها
    if (surahData != null) {
      return sharedPref.getString("selectedValue") != "ar"
          ? surahData["englishName"]
          : surahData["name"] ?? "";
    }

    // إذا لم تُوجد سورة بهذا الرقم، أعد null
    return null;
  }

  Future<void> loadSurahName() async {
    surahName = await getSurahNameByNumber(widget.surahNumber);
    setState(() {});
  }

  ////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////
  // الحصول على توكن
  Future<void> fetchAccessToken() async {
    setState(() {
      isloading = true;
    });
    try {
      final auth =
          'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret'));

      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': auth,
        },
        body: 'grant_type=client_credentials&scope=content',
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        accessToken = data['access_token'];
        debugPrint("✅ تم الحصول على التوكن: $accessToken");
      } else {
        debugPrint("❌ خطأ في الحصول على التوكن: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 استثناء أثناء الحصول على التوكن: $e");
    }
    setState(() {
      isloading = false;
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // تشغيل السورة
  Future<void> playSurah(int surah, {int reciterId = 1}) async {
    setState(() {
      isloading = true;
    });
    if (accessToken == null) await fetchAccessToken();
    if (accessToken == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomSnackBar(
            text:
                translation!.error.isNotEmpty ? translation!.error : "هناك خطأ",
          ),
          backgroundColor: const Color.fromARGB(0, 255, 193, 7),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar(
          text: translation!.playing.isNotEmpty
              ? translation!.playing
              : "يتم التشغيل",
        ),
        backgroundColor: const Color.fromARGB(0, 255, 193, 7),
        duration: const Duration(seconds: 2),
      ),
    );

    final url =
        "https://apis.quran.foundation/content/api/v4/chapter_recitations/$reciterId/$surah";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-client-id': clientId,
          'x-auth-token': accessToken!,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['audio_file']?['audio_url'];
        if (audioUrl != null) {
          await _player.stop();
          await _player.play(UrlSource(audioUrl));
        }
      } else if (response.statusCode == 403) {
        accessToken = null;
        await playSurah(surah, reciterId: reciterId);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomSnackBar(
            text:
                translation!.error.isNotEmpty ? translation!.error : "هناك خطأ",
          ),
          backgroundColor: const Color.fromARGB(0, 255, 193, 7),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint("🔥 استثناء: $e");
    }
    setState(() {
      isloading = false;
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // تشغيل الآية
  Future<void> playAyah(String verseKey, int recitationId) async {
    setState(() {
      isloading = true;
    });
    if (accessToken == null) await fetchAccessToken();
    if (accessToken == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomSnackBar(
            text: "هناك خطأ",
          ),
          backgroundColor: Color.fromARGB(0, 255, 193, 7),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://apis.quran.foundation/content/api/v4/verses/by_key/$verseKey?audio=$recitationId",
        ),
        headers: {
          "Accept": 'application/json',
          "x-auth-token": accessToken!,
          "x-client-id": clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? relativePath = data["verse"]["audio"]["url"];
        if (relativePath != null) {
          final audioUrl = "https://verses.quran.com/$relativePath";
          await _player.stop();
          await _player.play(UrlSource(audioUrl));
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomSnackBar(
            text: "هناك خطأ",
          ),
          backgroundColor: Color.fromARGB(0, 255, 193, 7),
          duration: Duration(seconds: 2),
        ),
      );
      print("❌ استثناء: $e");
    }
    setState(() {
      isloading = false;
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // تشغيل الكلمة
  Future<void> playWordByPosition(
      String verseKey, int wordPosition, int recitationId) async {
    setState(() {
      isloading = true;
    });

    if (accessToken == null) await fetchAccessToken();
    if (accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomSnackBar(text: "هناك خطأ في الوصول"),
          backgroundColor: Color.fromARGB(0, 255, 193, 7),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          "https://apis.quran.foundation/content/api/v4/verses/by_key/$verseKey?words=true&audio=$recitationId",
        ),
        headers: {
          "Accept": 'application/json',
          "x-auth-token": accessToken!,
          "x-client-id": clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final words = data["verse"]["words"] as List<dynamic>;

        // البحث بالكلمة حسب الترتيب (position)
        final word = words.firstWhere(
          (w) => w["position"] == wordPosition,
          orElse: () => null,
        );

        if (word != null && word["audio_url"] != null) {
          String audioUrl = word["audio_url"];
          if (!audioUrl.startsWith("http")) {
            audioUrl = "https://verses.quran.com/$audioUrl";
          }

          await _player.stop();
          await _player.play(UrlSource(audioUrl));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  CustomSnackBar(text: "لم يتم العثور على الصوت لهذه الكلمة"),
              backgroundColor: Color.fromARGB(0, 255, 193, 7),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("❌ فشل في جلب البيانات: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CustomSnackBar(text: "حدث خطأ أثناء التشغيل"),
          backgroundColor: Color.fromARGB(0, 255, 193, 7),
          duration: Duration(seconds: 2),
        ),
      );
      print("❌ استثناء: $e");
    }

    setState(() {
      isloading = false;
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // حفظ الآية
  void saveMyAya(int verse, int surah, String surahName) async {
    await sharedPref.setInt('ayasaved', verse);
    await sharedPref.setInt('surahsaved', surah);
    await sharedPref.setString('namesaved', surahName);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar(
          text: translation!.saved.isNotEmpty ? translation!.saved : "تم الحفظ",
        ),
        backgroundColor: const Color.fromARGB(0, 255, 193, 7),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {
      highlightedVerse = null;
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // النزول للآية المحفوظة
  void goToSavedVerse() {
    if (ayasaved != null && surahsaved == widget.surahNumber) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = verseContexts[ayasaved!];
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: 0.15,
          );
          setState(() {
            highlightedVerse = ayasaved;
          });
        }
        print("IF 2 work");
      });
      print("IF 1 work");
    }
  }

  //  النزول للآية التي تم البحث عنها
  void goToSearchedVerse() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = verseContexts[widget.searchedVerse];
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
        setState(() {
          highlightedVerse = widget.searchedVerse;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
    loadSurahName();

    loadData();
    if (widget.x == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToSavedVerse();
      });
    }
    if (widget.x == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        goToSearchedVerse();
      });
    }

    _player.onPlayerComplete.listen((event) {
      setState(() {
        positionsOfMusic = null; // تعود للقيم الطبيعية
        sizeoficonOfMusic = null;
      });
    });
  }

  ////////////////////////////////////////////////////////////////////////////
  // التفسير
  int showTafsir = 0;
  String langOfTafsir = sharedPref.getString("selectedValue") ?? "ar";

  Future<List<Tafsir>> loadTafsir() async {
    final String response =
        await rootBundle.loadString('assets/json/tafsir/$langOfTafsir.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Tafsir.fromJson(item)).toList();
  }

  Future<String?> getTafsir(int surah, int ayah) async {
    List<Tafsir> tafasir = await loadTafsir();
    try {
      return tafasir
          .firstWhere((t) => t.surah == surah && t.ayah == ayah)
          .tafsir;
    } catch (e) {
      return null;
    }
  }

  ////////////////////////////////////////////////////////////////////////////
  ///
  double? positionsOfMusic = null;
  double? sizeoficonOfMusic = null;

  ///
  /////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////

  String onOff = '';

  Translation? translation;

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(
        sharedPref.getString("selectedValue")); // هذا يرجع قائمة من Translation
    setState(() {
      translation = list.first; // أو اختر حسب اللغة
    });

    onOff = translation?.turnOn ?? "تشغيل";
  }
  ///////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////

  Future<List<Reciters>> loadReciters() async {
    String jsonString =
        await rootBundle.loadString('assets/json/reciters/reciters.json');

    final Map<String, dynamic> jsonData = json.decode(jsonString);

    List<dynamic> recitations = jsonData["recitations"];

    return recitations.map((item) => Reciters.fromMap(item)).toList();
  }

  List<Reciters> reciters = [];
  Reciters? selectedReciter;
  int idOfReciter = sharedPref.getInt("idOfReciter") ?? 1;

  void loadData() async {
    reciters = await loadReciters();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(0),
            children: [
              CustomAppBar(
                topButton: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<Reciters>(
                    isExpanded: true, // ✅ مهم حتى لا يخرج النص من الحاوية
                    menuWidth: 220, // ✅ حجم القائمة
                    menuMaxHeight: 300, // ✅ التحكم في ارتفاع القائمة اختياري
                    hint: const Text(
                      "اختر القارئ",
                      overflow:
                          TextOverflow.ellipsis, // ✅ يقص النص إذا كان طويلاً
                    ),
                    value: selectedReciter,
                    items: reciters.map((reciter) {
                      return DropdownMenuItem(
                        value: reciter,
                        child: Text(
                          reciter.reciterName,
                          overflow: TextOverflow.ellipsis, // ✅ حتى داخل العناصر
                          maxLines: 1,
                          style: const TextStyle(fontSize: 14), // اختياري
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReciter = value;
                        sharedPref.setInt("idOfReciter", value!.id);
                        idOfReciter = value.id;
                      });
                    },
                  ),
                ),
                surahName: surahName ?? "",
                iconData: iconData,
                onOff: onOff,
                onPressed: () {
                  if (translation == null) return; // أو إظهار رسالة مؤقتة
                  if (onOff == translation!.turnOn) {
                    onOff = translation!.turnOff;
                    iconData = Icons.stop;
                    playSurah(widget.surahNumber, reciterId: idOfReciter);
                    setState(() {
                      highlightedVerse = null;
                    });
                  } else {
                    onOff = translation!.turnOn;
                    iconData = Icons.play_arrow;
                    _player.stop();
                  }
                  setState(() {});
                },
              ),
              CustomSurahName(surahName: surahName ?? ""),
              CustomSurahPage(
                surahNumber: widget.surahNumber,
                selectedVerse: highlightedVerse,
                onVerseContext: (verseNum, ctx) {
                  verseContexts[verseNum] = ctx;
                },
                selectedWordKey:
                    highlightedWord != null && highlightedWordVerse != null
                        ? "$highlightedWordVerse-$highlightedWord"
                        : null,
                onVerseSelected: (verse) {
                  setState(() {
                    highlightedVerse = verse;
                    highlightedWord = null;
                  });
                },
                onWordSelected: (wordKey) {
                  if (wordKey.isEmpty) {
                    setState(() {
                      highlightedWord = null;
                      highlightedWordVerse = null;
                    });
                    return;
                  }
                  final parts = wordKey.split('-');
                  setState(() {
                    highlightedWordVerse = int.parse(parts[0]);
                    highlightedWord = int.parse(parts[1]);
                    highlightedVerse = null;
                  });
                },
              ),
            ],
          ),
          highlightedVerse != null && highlightedWord == null
              ? Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height - 75),
                  child: BottomBarAnimation2(
                    oldeOnIconTap: (index) {
                      if (index == 0 && highlightedVerse != null) {
                        _player.stop();
                      }
                      if (index == 2 && highlightedVerse != null) {
                        setState(() {
                          showTafsir = 0;
                        });
                      }
                    },
                    onIconTap: (index) {
                      if (highlightedVerse == null) return;

                      if (index == 0) {
                        playAyah("${widget.surahNumber}:${highlightedVerse!}",
                            idOfReciter);

                        setState(() {
                          positionsOfMusic = 0;
                          sizeoficonOfMusic = 42;
                        });
                      } else if (index == 1 && highlightedVerse != null) {
                        saveMyAya(highlightedVerse!, widget.surahNumber,
                            surahName ?? "");
                        ayasaved = highlightedVerse;
                        surahsaved = widget.surahNumber;

                        // انتظر الإطار ثم انزل
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          goToSavedVerse();
                        });
                      } else if (index == 2) {
                        setState(() => showTafsir = 1);
                      }
                    },
                    positionsOfMusic: positionsOfMusic,
                    sizeoficonOfMusic: sizeoficonOfMusic,
                    icons: const [
                      Icons.music_note,
                      Icons.bookmark_outlined,
                      Icons.format_align_right,
                    ],
                  ),
                )
              : highlightedWord != null && highlightedVerse == null
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.all(16), // مسافة من الحواف
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: scandColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: dilutionScandColor, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.music_note, size: 36),
                          color: mainColor,
                          onPressed: () async {
                            await playWordByPosition(
                                "${widget.surahNumber}:${highlightedWordVerse!}",
                                highlightedWord!,
                                7);
                          },
                        ),
                      ),
                    )
                  : const SizedBox(),
          showTafsir == 0 || highlightedVerse == null
              ? const SizedBox()
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(color: blackColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(22.0),
                            child: FutureBuilder<String?>(
                              future: getTafsir(
                                  widget.surahNumber, highlightedVerse!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CustomLoadingScreen2();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData) {
                                  return const Text('لا يوجد تفسير');
                                } else {
                                  return SingleChildScrollView(
                                    child: Text(
                                      snapshot.data!,
                                      style: TextStyle(
                                        fontSize: quranfontSize,
                                        fontFamily: 'Amiri',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              iconSize: 38,
                              onPressed: () {
                                setState(() {
                                  showTafsir = 0;
                                  highlightedVerse = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          isloading ? const CustomLoadingScreen2() : const SizedBox(),
        ],
      ),
    );
  }
}
