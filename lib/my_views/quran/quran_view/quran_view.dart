import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_animation/bottom_bar_animation2.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/custom/custom_snack_bar/custom_snack_bar.dart';
import 'package:risala/custom/custom_snack_bar/custom_snack_bar_icon.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/models/reciters/hafs/reciters_hafs.dart';
import 'package:risala/models/reciters/qaloun/ayah_timing.dart';
import 'package:risala/models/reciters/qaloun/reciters_qaloun.dart';
import 'package:risala/models/tafsir.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/custom/custom_app_bar.dart';
import 'package:risala/my_views/quran/custom/custom_surah_name.dart';
import 'package:risala/my_views/quran/custom/custom_surah_page.dart';
import 'package:risala/my_views/quran/quran_service/quran_audio_service/hafs/quran_hafs_audio_service.dart';
import 'package:risala/my_views/quran/quran_service/quran_audio_service/qaloun/quran_qaloun_audio_service.dart';
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
  // تعريف الخدمة الجديدة
  final QuranHafsAudioService _audioService = QuranHafsAudioService();
  final QuranQalounAudioService _audioService2 = QuranQalounAudioService();

  final ScrollController _scrollController = ScrollController();

  bool isitplay = false;
  bool isPlayerPause = false;
  late int surahNumber = widget.surahNumber;

  IconData iconData = Icons.play_arrow;
  IconData iconDataPause = Icons.pause_rounded;
  bool isloading = false;

  final Map<int, BuildContext> verseContexts = {};
  int? highlightedWordVerse;
  int? highlightedVerse;
  int? highlightedWord;
  int? ayasaved = sharedPref.getInt('ayasaved');
  int? surahsaved = sharedPref.getInt('surahsaved');
  String? surahName;

  double? positionsOfMusic;
  double? sizeoficonOfMusic;
  String onOff = '';
  Translation? translation;

  /////////////////////////////////
  List<RecitersHafs> recitersHafs = [];
  RecitersHafs? selectedReciterHafs;
  List<RecitersQaloun> recitersQaloun = [];
  RecitersQaloun? selectedReciterQaloun;
  /////////////////////////////////

  int idOfReciterHafs = sharedPref.getInt("idOfReciter") ?? 4;
  String urlOfReciterHafs = sharedPref.getString("urlOfReciterHafs") ??
      "https://server11.mp3quran.net/shatri/";
  String idOfReciterQaloun = sharedPref.getString("idOfReciterQaloun") ??
      "https://server7.mp3quran.net/dokali/";

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
    loadSurahName();
    loadData();

    _audioService2.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          positionsOfMusic = null;
          sizeoficonOfMusic = null;
          _audioService2.player.stop();
        });
        _audioService2.player.seek(Duration.zero);
      }
    });

    _audioService.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          positionsOfMusic = null;
          sizeoficonOfMusic = null;
          _audioService.player.stop();
        });
        _audioService.player.seek(Duration.zero);
      }
    });

    if (widget.x == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goToSavedVerse());
    }
    if (widget.x == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goToSearchedVerse());
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    _audioService2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- دوال التحميل والبيانات (UI Logic) ---

  Future<void> loadSurahName() async {
    String jsonString = await rootBundle.loadString('assets/json/surahs.json');
    List<dynamic> jsonData = json.decode(jsonString);
    var surahData = jsonData.firstWhere((item) => item["number"] == surahNumber,
        orElse: () => null);

    if (surahData != null) {
      setState(() {
        surahName = sharedPref.getString("selectedValue") != "ar"
            ? surahData["englishName"]
            : surahData["name"] ?? "";
      });
    }
  }

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
  void loadData() async {
    recitersHafs = await loadRecitersHafs();
    recitersQaloun = await loadRecitersQalouin();
    setState(() {});
  }

  Future<List<RecitersHafs>> loadRecitersHafs() async {
    String jsonString =
        await rootBundle.loadString('assets/json/reciters/hafs/surah.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> recitations = jsonData["recitations"];
    return recitations.map((item) => RecitersHafs.fromMap(item)).toList();
  }

  Future<List<RecitersQaloun>> loadRecitersQalouin() async {
    String jsonString =
        await rootBundle.loadString('assets/json/reciters/qaloun/surah.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> recitations = jsonData["recitations"];
    return recitations.map((item) => RecitersQaloun.fromMap(item)).toList();
  }

  Future<void> loadAllTranslations() async {
    final list = await loadTranslation(sharedPref.getString("selectedValue"));
    setState(() {
      translation = list.first;
      onOff = translation?.turnOn ?? "تشغيل";
    });
  }

//////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

  // --- دوال التنقل (Navigation Logic) ---

  void saveMyAya(int verse, int surah, String surahName) async {
    await sharedPref.setInt('ayasaved', verse);
    await sharedPref.setInt('surahsaved', surah);
    await sharedPref.setString('namesaved', surahName);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar(
            text: translation!.saved.isNotEmpty
                ? translation!.saved
                : "تم الحفظ"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
    setState(() => highlightedVerse = null);
  }

  void goToSavedVerse() {
    if (ayasaved == null || surahsaved != surahNumber) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      final context = verseContexts[ayasaved!];
      if (context != null) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 400), alignment: 0.15);
        setState(() => highlightedVerse = ayasaved);
      }
    });
  }

  void goToSearchedVerse() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = verseContexts[widget.searchedVerse];
      if (context != null) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 400), alignment: 0.3);
        setState(() => highlightedVerse = widget.searchedVerse);
      }
    });
  }

  // --- دوال التفسير ---
  int showTafsir = 0;
  Future<String?> getTafsir(int surah, int ayah) async {
    final String response = await rootBundle.loadString(
        'assets/json/tafsir/${sharedPref.getString("selectedValue") ?? "ar"}.json');
    final List<dynamic> data = json.decode(response);
    try {
      return data
          .map((item) => Tafsir.fromJson(item))
          .firstWhere((t) => t.surah == surah && t.ayah == ayah)
          .tafsir;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              CustomAppBar(
                isitplay: isitplay,
                topButton: riwoya == "hafs"
                    ? _buildReciterHafsDropdown()
                    : _buildReciterQalounDropdown(),
                surahName: surahName ?? "",
                iconData: iconData,
                iconDataPause: iconDataPause,
                onOff: onOff,
                onPressed: riwoya == "hafs"
                    ? _handleMainHafsPlayButton
                    : _handleMainQalounPlayButton,
                onPressedPause: riwoya == "hafs"
                    ? _handlePauseHafsButton
                    : _handlePauseQalounButton,
              ),
              CustomSurahName(surahName: surahName ?? ""),
              CustomSurahPage(
                surahNumber: surahNumber,
                selectedVerse: highlightedVerse,
                onVerseContext: (verseNum, ctx) =>
                    verseContexts[verseNum] = ctx,
                selectedWordKey:
                    highlightedWord != null && highlightedWordVerse != null
                        ? "$highlightedWordVerse-$highlightedWord"
                        : null,
                onVerseSelected: (verse) => setState(() {
                  highlightedVerse = verse;
                  highlightedWord = null;
                }),
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
              _buildNextSurahButton(),
              const SizedBox(height: 80)
            ],
          ),
          riwoya == "hafs"
              ? _buildHafsBottomActionBars()
              : _buildQalounBottomActionBars(),
          _buildTafsirOverlay(),
          if (isloading) const CustomLoadingScreen2(),
        ],
      ),
    );
  }

  // --- قطع الـ UI المصغرة (Helper Widgets) ---

  Widget _buildReciterHafsDropdown() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
          color: whiteColor, borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<RecitersHafs>(
        isExpanded: true,
        menuWidth: 220,
        hint: Text(
            sharedPref.getInt("numOfReciter") != null
                ? "القارئ ${sharedPref.getInt("numOfReciter")}"
                : "القارئ",
            overflow: TextOverflow.ellipsis),
        value: selectedReciterHafs,
        items: recitersHafs
            .map((reciter) => DropdownMenuItem(
                  value: reciter,
                  child: Text(reciter.reciterName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
        onChanged: (value) => setState(() {
          selectedReciterHafs = value;
          sharedPref.setString("urlOfReciterHafs", value!.urlReciter);
          sharedPref.setInt("idOfReciter", value.id);
          sharedPref.setInt("numOfReciter", value.number);
          urlOfReciterHafs = value.urlReciter;
          idOfReciterHafs = value.id;
        }),
      ),
    );
  }

  Widget _buildReciterQalounDropdown() {
    return Container(
      width: 100,
      decoration: BoxDecoration(
          color: whiteColor, borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<RecitersQaloun>(
        isExpanded: true,
        menuWidth: 220,
        hint: Text(
            sharedPref.getInt("numOfReciterQaloun") != null
                ? "القارئ ${sharedPref.getInt("numOfReciterQaloun")}"
                : "القارئ",
            overflow: TextOverflow.ellipsis),
        value: selectedReciterQaloun,
        items: recitersQaloun
            .map((reciter) => DropdownMenuItem(
                  value: reciter,
                  child: Text(reciter.reciterName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontSize: 14)),
                ))
            .toList(),
        onChanged: (value) => setState(() {
          selectedReciterQaloun = value;
          sharedPref.setString("idOfReciterQaloun", value!.urlReciter);
          sharedPref.setInt("numOfReciterQaloun", value.number);
          idOfReciterQaloun = value.urlReciter;
        }),
      ),
    );
  }

  Widget _buildNextSurahButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (surahNumber < 114)
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: scandColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mainColor)),
            child: IconButton(
              color: mainColor,
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => surahNumber < 114
                            ? QuranView(surahNumber: surahNumber + 1, x: 0)
                            : const MainView()));
              },
              icon: const Icon(Icons.arrow_back, size: 36),
            ),
          ),
        if (surahNumber > 1)
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: scandColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: mainColor)),
            child: IconButton(
              color: mainColor,
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => surahNumber > 1
                            ? QuranView(surahNumber: surahNumber - 1, x: 0)
                            : const MainView()));
              },
              icon: const Icon(Icons.arrow_forward, size: 36),
            ),
          ),
      ],
    );
  }

  // --- منطق الأزرار المشغل (Audio UI Logic) ---

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _handleMainHafsPlayButton() async {
    if (translation == null) return;
    if (onOff == translation!.turnOn) {
      setState(() => isloading = true);
      if (!(await _audioService.checkInternet())) {
        _showNoInternetSnackBar();
        setState(() => isloading = false);
        return;
      }
      await _audioService.playSurah(urlOfReciterHafs, surahNumber);
      setState(() {
        isitplay = true;
        isloading = false;
        iconDataPause = Icons.pause;
        onOff = translation!.turnOff;
        iconData = Icons.stop;
        highlightedVerse = null;
      });
    } else {
      _audioService.player.stop();
      setState(() {
        isitplay = false;
        onOff = translation!.turnOn;
        iconData = Icons.play_arrow;
      });
    }
  }

  void _handlePauseHafsButton() {
    if (isPlayerPause) {
      _audioService.player.play();
      iconDataPause = Icons.pause;
    } else {
      _audioService.player.pause();
      iconDataPause = Icons.play_arrow;
    }
    setState(() => isPlayerPause = !isPlayerPause);
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////

  void _handleMainQalounPlayButton() async {
    if (!isitplay) {
      setState(() => isloading = true);

      try {
        final hasInternet = await _audioService2.checkInternet();
        if (!hasInternet) {
          _showNoInternetSnackBar();
          setState(() => isloading = false);
          return;
        }

        await _audioService2.playSurah(idOfReciterQaloun, surahNumber);

        if (!mounted) return;

        setState(() {
          isitplay = true;
          onOff = translation!.turnOff;
          iconData = Icons.stop;
          iconDataPause = Icons.pause;
        });
      } catch (e) {
        debugPrint("Qaloun error: $e");
      } finally {
        if (mounted) {
          setState(() => isloading = false);
        }
      }
    } else {
      await _audioService2.player.stop();
      setState(() {
        isitplay = false;
        onOff = translation!.turnOn;
        iconData = Icons.play_arrow;
      });
    }
  }

  void _handlePauseQalounButton() {
    if (isPlayerPause) {
      _audioService2.player.play();
      iconDataPause = Icons.pause;
    } else {
      _audioService2.player.pause();
      iconDataPause = Icons.play_arrow;
    }
    setState(() => isPlayerPause = !isPlayerPause);
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////

  Widget _buildHafsBottomActionBars() {
    if (highlightedVerse != null && highlightedWord == null) {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height - 75),
        child: BottomBarAnimation2(
          onIconTap: (index) async {
            if (index == 0) {
              setState(() {
                isloading = true;
                positionsOfMusic = 0;
                sizeoficonOfMusic = 42;
              });
              List<AyahTiming> timings = await _audioService.fetchAyahTimings(
                  surahNumber, idOfReciterHafs);
              try {
                final currentAyahTiming =
                    timings.firstWhere((t) => t.ayah == highlightedVerse);

                await _audioService.playAyah(
                    urlOfReciterHafs, surahNumber, currentAyahTiming);
              } catch (e) {
                print("Timing not found for this ayah");
              }
              setState(() => isloading = false);
            } else if (index == 1) {
              saveMyAya(highlightedVerse!, surahNumber, surahName ?? "");
            } else if (index == 2) {
              setState(() => showTafsir = 1);
            }
          },
          icons: const [
            Icons.music_note,
            Icons.bookmark_outlined,
            Icons.format_align_right
          ],
          positionsOfMusic: positionsOfMusic,
          sizeoficonOfMusic: sizeoficonOfMusic,
        ),
      );
    } else if (highlightedWord != null && highlightedVerse == null) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(16),
          width: 65,
          height: 65,
          decoration: BoxDecoration(
              color: scandColor,
              shape: BoxShape.circle,
              border: Border.all(color: dilutionScandColor, width: 2)),
          child: IconButton(
            icon: Icon(Icons.music_note, size: 36, color: mainColor),
            onPressed: () async {
              print("[][][][][][][][][][][][][][][][][][][][][][][][][]");
              print("[][][][][]$surahNumber:$highlightedWordVerse[][][][][]");
              print("[][][][()()()()()()()()()()[][][]");
              print("[][][][][]$highlightedWord[][][][][]");
              print("[][][][][][][][][][][][][][][][][][][][][][][][][]");
              setState(() => isloading = true);
              await _audioService.playWord(
                  "$surahNumber:$highlightedWordVerse", highlightedWord!, 7);
              setState(() => isloading = false);
            },
          ),
        ),
      );
    }
    return const SizedBox();
  }

  ///////////////////////////////////////////////////////////////////////////////

  Widget _buildQalounBottomActionBars() {
    if (highlightedVerse != null && highlightedWord == null) {
      return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height - 75),
        child: BottomBarAnimation2(
          onIconTap: (index) async {
            if (index == 0) {
              setState(() {
                isloading = true;
                positionsOfMusic = 0;
                sizeoficonOfMusic = 42;
              });
              List<AyahTiming> timings =
                  await _audioService2.fetchAyahTimings(surahNumber);
              try {
                final currentAyahTiming =
                    timings.firstWhere((t) => t.ayah == highlightedVerse);

                await _audioService2.playAyah(surahNumber, currentAyahTiming);
              } catch (e) {
                print("Timing not found for this ayah");
              }
              setState(() => isloading = false);
            } else if (index == 1) {
              saveMyAya(highlightedVerse!, surahNumber, surahName ?? "");
            } else if (index == 2) {
              setState(() => showTafsir = 1);
            }
          },
          icons: const [
            Icons.music_note,
            Icons.bookmark_outlined,
            Icons.format_align_right
          ],
          positionsOfMusic: positionsOfMusic,
          sizeoficonOfMusic: sizeoficonOfMusic,
        ),
      );
    }
    return const SizedBox();
  }

  ///////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////

  Widget _buildTafsirOverlay() {
    if (showTafsir == 0 || highlightedVerse == null) return const SizedBox();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: blackColor),
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(22),
              child: FutureBuilder<String?>(
                future: getTafsir(surahNumber, highlightedVerse!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const CustomLoadingScreen2();
                  return SingleChildScrollView(
                      child: Text(snapshot.data ?? "لا يوجد تفسير",
                          style: TextStyle(
                              fontSize: quranfontSize, fontFamily: 'Amiri'),
                          textAlign: TextAlign.center));
                },
              ),
            ),
            Positioned(
                right: 0,
                child: IconButton(
                    icon: const Icon(Icons.close, size: 38),
                    onPressed: () => setState(() {
                          showTafsir = 0;
                          highlightedVerse = null;
                        })))
          ],
        ),
      ),
    );
  }

  void _showNoInternetSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const CustomSnackBarIcon(icon: Icons.wifi_off_rounded),
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.4),
    ));
  }
}
