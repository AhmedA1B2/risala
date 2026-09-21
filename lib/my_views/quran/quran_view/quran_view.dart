import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:risala/custom/custom_bottom_bar/bottom_bar_animation/bottom_bar_animation2.dart';
import 'package:risala/custom/custom_loading/custom_loading_screen/custom_loading_screen2.dart';
import 'package:risala/custom/custom_snack_bar/custom_snack_bar.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/models/reciters/hafs/reciters_hafs.dart';
import 'package:risala/models/reciters/qaloun/reciters_qaloun.dart';
import 'package:risala/models/tafsir.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/my_views/quran/custom/custom_app_bar.dart';
import 'package:risala/my_views/quran/custom/custom_copysave_button.dart';
import 'package:risala/my_views/quran/custom/custom_surah_name.dart';
import 'package:risala/my_views/quran/custom/custom_surah_page.dart';
import 'package:risala/my_views/quran/custom/custom_surah_page_for_ss.dart';
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
  final QuranHafsAudioService _audioService = QuranHafsAudioService();
  final QuranQalounAudioService _audioService2 = QuranQalounAudioService();
  bool isPlayingHafsAyah = false;
  bool isPlayingQalounAyah = false;

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
  bool isPlayingAyah = false;

  List<RecitersHafs> recitersHafs = [];
  RecitersHafs? selectedReciterHafs;
  List<RecitersQaloun> recitersQaloun = [];
  RecitersQaloun? selectedReciterQaloun;

  bool isDownloading = false;
  double downloadProgress = 0;
  bool isDownloaded = false;

  // مراقبة التحميل حتى لا تبقى شاشة التحميل عالقة
  Timer? _loadingWatchdog;
  int? _loadingWatchdogRequestId;

  // رقم العملية الحالية لمنع ظهور رسالة خطأ بعد أن يضغط المستخدم إيقاف
  int _playRequestId = 0;

  // مهلة فحص الاتصال ومهلة بدء تحميل الصوت
  static const Duration _internetCheckTimeout = Duration(seconds: 4);
  static const Duration _loadingTimeout = Duration(seconds: 8);

  int idOfReciterHafs = sharedPref.getInt("idOfReciter") ?? 4;
  String urlOfReciterHafs = sharedPref.getString("urlOfReciterHafs") ??
      "https://server11.mp3quran.net/shatri/";
  String idOfReciterQaloun = sharedPref.getString("idOfReciterQaloun") ?? "208";
  String urlOfReciterQaloun = sharedPref.getString("urlOfReciterQaloun") ??
      "https://server7.mp3quran.net/dokali/";

  String riwoya = sharedPref.getString("riwoya") ?? "hafs";

  late StreamSubscription playerSub1;
  late StreamSubscription playerSub2;
  int _savedRetry = 0;
  int _searchRetry = 0;

  Future<void> checkDownloaded() async {
    bool downloaded;

    if (riwoya == "hafs") {
      downloaded = await _audioService.isSurahDownloaded(
        surahNumber,
        idOfReciterHafs,
        surahName ?? "",
      );
    } else {
      downloaded = await _audioService2.isSurahDownloaded(
        surahNumber,
        idOfReciterQaloun,
        surahName ?? "",
      );
    }

    if (!mounted) return;

    setState(() {
      isDownloaded = downloaded;
    });
  }

  @override
  void initState() {
    super.initState();
    loadAllTranslations();
    loadSurahName();
    loadData();
    checkDownloaded();

    // 💡 التعديل الجوهري الأول: مراقبة حالة مشغل الصوت الأول (حفص)
    playerSub1 = _audioService.player.playerStateStream.listen(
      (state) {
        if (!mounted) return;

        if (state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering) {
          setState(() {
            isloading = true;
          });

          if (isitplay) {
            _startLoadingWatchdog(
              player: _audioService.player,
              requestId: _playRequestId,
            );
          }
        }

        if (state.processingState == ProcessingState.ready) {
          _cancelLoadingWatchdog();

          setState(() {
            isloading = false;
          });
        }

        if (state.processingState == ProcessingState.completed) {
          _cancelLoadingWatchdog();

          setState(() {
            isloading = false;
            isitplay = false;
            isPlayerPause = false;
            iconData = Icons.play_arrow;
            onOff = translation?.turnOn ?? "تشغيل";
          });
        }
      },
      onError: (error, stack) {
        if (!mounted) return;

        _resetMainPlaybackUi();
        _showWeakInternetSnackBar();
      },
    );
    // 💡 التعديل الجوهري الثاني: مراقبة حالة مشغل الصوت الثاني (قالون)

    playerSub2 = _audioService2.player.playerStateStream.listen(
      (state) {
        if (!mounted) return;

        if (state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering) {
          setState(() {
            isloading = true;
          });

          if (isitplay) {
            _startLoadingWatchdog(
              player: _audioService2.player,
              requestId: _playRequestId,
            );
          }
        }

        if (state.processingState == ProcessingState.ready) {
          _cancelLoadingWatchdog();

          setState(() {
            isloading = false;
          });
        }

        if (state.processingState == ProcessingState.completed) {
          _cancelLoadingWatchdog();

          setState(() {
            isloading = false;
            isitplay = false;
            isPlayerPause = false;
            iconData = Icons.play_arrow;
            onOff = translation?.turnOn ?? "تشغيل";
          });
        }
      },
      onError: (error, stack) {
        if (!mounted) return;

        _resetMainPlaybackUi();
        _showWeakInternetSnackBar();
      },
    );
/////

    if (widget.x == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goToSavedVerse());
    }
    if (widget.x == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goToSearchedVerse());
    }
  }

  Future<bool?> _checkInternetSafely(
    Future<bool> Function() checkInternet,
  ) async {
    try {
      return await checkInternet().timeout(
        _internetCheckTimeout,
      );
    } on SocketException {
      // لا يوجد اتصال بالإنترنت
      return false;
    } on TimeoutException {
      // الاتصال موجود/محتمل، لكن الاستجابة بطيئة جدًا
      return null;
    } catch (_) {
      // خطأ غير متوقع في فحص الاتصال
      return null;
    }
  }

  void _cancelLoadingWatchdog() {
    _loadingWatchdog?.cancel();
    _loadingWatchdog = null;
    _loadingWatchdogRequestId = null;
  }

  void _startLoadingWatchdog({
    required AudioPlayer player,
    required int requestId,
  }) {
    // لا تعِد تشغيل المؤقت مع كل buffering؛ المهلة تبدأ من بداية الطلب
    // وتبقى ثابتة حتى نجاح التشغيل أو فشل الطلب.
    if (_loadingWatchdog != null &&
        _loadingWatchdog!.isActive &&
        _loadingWatchdogRequestId == requestId) {
      return;
    }

    _cancelLoadingWatchdog();
    _loadingWatchdogRequestId = requestId;

    _loadingWatchdog = Timer(_loadingTimeout, () async {
      if (!mounted) return;
      if (requestId != _playRequestId) return;
      if (!isitplay) return;

      final processingState = player.processingState;

      // إذا أصبح المشغل جاهزًا بالفعل، فلا نوقف التلاوة لمجرد انتهاء المؤقت.
      // هذا مهم خصوصًا عندما يكون الصوت مخزنًا محليًا أو تم تحميله مسبقًا.
      if (processingState != ProcessingState.loading &&
          processingState != ProcessingState.buffering) {
        _cancelLoadingWatchdog();

        if (mounted) {
          setState(() {
            isloading = false;
          });
        }
        return;
      }

      try {
        await player.stop();
      } catch (_) {}

      if (!mounted) return;
      if (requestId != _playRequestId) return;

      _cancelLoadingWatchdog();

      setState(() {
        isloading = false;
        isitplay = false;
        isPlayerPause = false;
        iconData = Icons.play_arrow;
        iconDataPause = Icons.pause_rounded;
        onOff = translation?.turnOn ?? "تشغيل";
      });

      _showWeakInternetSnackBar();
    });
  }

  void _resetMainPlaybackUi() {
    _cancelLoadingWatchdog();

    if (!mounted) return;

    setState(() {
      isloading = false;
      isitplay = false;
      isPlayerPause = false;
      iconData = Icons.play_arrow;
      iconDataPause = Icons.pause_rounded;
      onOff = translation?.turnOn ?? "تشغيل";
    });
  }

  Future<void> _runHafsPlayback(int requestId) async {
    try {
      await _audioService.playSurah(
        urlOfReciterHafs,
        surahNumber,
      );
    } catch (_) {
      if (!mounted) return;
      if (requestId != _playRequestId) return;
      if (!isitplay) return;

      _resetMainPlaybackUi();
      _showWeakInternetSnackBar();
    }
  }

  Future<void> _runQalounPlayback(int requestId) async {
    try {
      await _audioService2.playSurah(
        urlOfReciterQaloun,
        surahNumber,
      );
    } catch (_) {
      if (!mounted) return;
      if (requestId != _playRequestId) return;
      if (!isitplay) return;

      _resetMainPlaybackUi();
      _showWeakInternetSnackBar();
    }
  }

  @override
  void dispose() {
    _cancelLoadingWatchdog();

    playerSub1.cancel();
    playerSub2.cancel();
    _audioService.dispose();
    _audioService2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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

  void loadData() async {
    recitersHafs = await loadRecitersHafs();
    recitersQaloun = await loadRecitersQalouin();
    if (!mounted) return;
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
    if (!mounted) return;
    setState(() {
      translation = list.first;
      onOff = translation?.turnOn ?? "تشغيل";
    });
  }

  void saveMyAya(int verse, int surah, String surahName) async {
    await sharedPref.setInt('ayasaved', verse);
    await sharedPref.setInt('surahsaved', surah);
    await sharedPref.setString('namesaved', surahName);

    if (!mounted) return;

    String messageText = "تم الحفظ";
    if (translation != null && translation!.saved.isNotEmpty) {
      messageText = translation!.saved;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar(text: messageText),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
    setState(() => highlightedVerse = null);
  }

  void goToSavedVerse() {
    if (_savedRetry > 10) return;

    if (ayasaved == null || surahsaved != surahNumber) {
      return;
    }

    Future.delayed(
      const Duration(milliseconds: 200),
      () {
        if (!mounted) return;

        final ctx = verseContexts[ayasaved!];

        if (ctx != null && ctx.mounted) {
          // تحديد الآية دائماً
          setState(() {
            highlightedVerse = ayasaved;
          });

          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 400),
            alignment: 0.15,
          );
        } else {
          _savedRetry++;
          goToSavedVerse();
        }
      },
    );
  }

  void goToSearchedVerse() {
    if (_searchRetry > 10) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = verseContexts[widget.searchedVerse];
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          alignment: 0.3,
        );
        setState(() {
          highlightedVerse = widget.searchedVerse;
        });
      } else {
        _searchRetry++;
        goToSearchedVerse();
      }
    });
  }

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
              widget.x != 0
                  ? CustomSurahPageForSs(
                      surahNumber: surahNumber,
                      selectedVerse: highlightedVerse,
                      onVerseContext: (verseNum, ctx) =>
                          verseContexts[verseNum] = ctx,
                      selectedWordKey: highlightedWord != null &&
                              highlightedWordVerse != null
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
                    )
                  : CustomSurahPage(
                      surahNumber: surahNumber,
                      selectedVerse: highlightedVerse,
                      onVerseContext: (verseNum, ctx) =>
                          verseContexts[verseNum] = ctx,
                      selectedWordKey: highlightedWord != null &&
                              highlightedWordVerse != null
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: riwoya == "hafs"
                  ? _buildHafsBottomActionBars()
                  : _buildQalounBottomActionBars(),
            ),
          ),
          isitplay && highlightedVerse == null && highlightedWord == null
              ? Positioned(
                  bottom: 12,
                  right: 12,
                  child: SafeArea(
                    child: Card(
                      color: scandColor,
                      margin: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: isDownloading
                            ? SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  value: downloadProgress,
                                  color: mainColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isDownloaded
                                    ? Icons.check_circle
                                    : Icons.download,
                                color: mainColor,
                                size: 36,
                              ),
                        onPressed: isDownloaded || isDownloading
                            ? null
                            : () async {
                                setState(() {
                                  isDownloading = true;
                                  downloadProgress = 0;
                                });

                                final result = riwoya == "hafs"
                                    ? await _audioService.downloadSurah(
                                        urlOfReciterHafs,
                                        surahNumber,
                                        surahName ?? "",
                                        idOfReciterHafs.toString(),
                                        (progress) {
                                          setState(() {
                                            downloadProgress = progress;
                                          });
                                        },
                                      )
                                    : await _audioService2.downloadSurah(
                                        urlOfReciterQaloun,
                                        surahNumber,
                                        surahName ?? "",
                                        idOfReciterQaloun,
                                        (progress) {
                                          setState(() {
                                            downloadProgress = progress;
                                          });
                                        },
                                      );

                                if (!mounted) return;

                                setState(() {
                                  isDownloading = false;
                                  isDownloaded = result != null;
                                });

                                if (result != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: scandColor,
                                      content: const Icon(Icons.check),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          _buildTafsirOverlay(),

          //if (highlightedVerse != null)
          //  const CustomCopysaveButton(
          //    bottom: 180,
          //    icon: Icons.image,
          //  ),

          if (highlightedVerse != null)
            CustomCopysaveButton(
              bottom: 100,
              icon: Icons.copy,
              onTap: () => copySelectedVerse(),
            ),
          if (isloading) const CustomLoadingScreen2(),
        ],
      ),
    );
  }

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
        onChanged: (value) async {
          if (value == null) return;
          selectedReciterHafs = value;
          sharedPref.setString(
            "urlOfReciterHafs",
            value.urlReciter,
          );
          sharedPref.setInt(
            "idOfReciter",
            value.id,
          );
          sharedPref.setInt(
            "numOfReciter",
            value.number,
          );
          urlOfReciterHafs = value.urlReciter;
          idOfReciterHafs = value.id;

          _audioService.clearTimingsCache();

          await checkDownloaded();
          if (!mounted) return;

          setState(() {});
        },
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
        onChanged: (value) async {
          if (value == null) return;
          selectedReciterQaloun = value;
          sharedPref.setString(
            "urlOfReciterQaloun",
            value.urlReciter,
          );
          sharedPref.setString(
            "idOfReciterQaloun",
            value.id,
          );
          sharedPref.setInt(
            "numOfReciterQaloun",
            value.number,
          );
          urlOfReciterQaloun = value.urlReciter;
          idOfReciterQaloun = value.id;
          await checkDownloaded();
          if (!mounted) return;

          setState(() {});
        },
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

  // 💡 التعديل الجوهري الثالث: إصلاح أزرار التشغيل لتحديث الواجهة فوراً
  Future<void> _handleMainHafsPlayButton() async {
    // إيقاف
    if (isitplay) {
      _playRequestId++;
      _cancelLoadingWatchdog();

      try {
        await _audioService.player.stop();
      } catch (_) {}

      _resetMainPlaybackUi();
      return;
    }

    // فحص الإنترنت
    final internet = await _checkInternetSafely(
      _audioService.checkInternet,
    );

    if (!mounted) return;

    // لا يوجد إنترنت
    if (internet == false) {
      _showNoInternetSnackBar();
      return;
    }

    // الإنترنت ضعيف أو الفحص استغرق وقتًا طويلًا
    if (internet == null) {
      _showWeakInternetSnackBar();
      return;
    }

    // عملية تشغيل جديدة
    final requestId = ++_playRequestId;

    setState(() {
      isitplay = true;
      isloading = true;
      isPlayerPause = false;
      iconDataPause = Icons.pause;
      onOff = translation?.turnOff ?? "إيقاف";
      iconData = Icons.stop;
      highlightedVerse = null;
      highlightedWord = null;
    });

    // لا نستخدم timeout على playSurah نفسه
    // لأن Future الخاصة به قد تستمر حتى نهاية التلاوة
    _startLoadingWatchdog(
      player: _audioService.player,
      requestId: requestId,
    );

    unawaited(_runHafsPlayback(requestId));
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

  Future<void> _handleMainQalounPlayButton() async {
    // إيقاف
    if (isitplay) {
      _playRequestId++;
      _cancelLoadingWatchdog();

      try {
        await _audioService2.player.stop();
      } catch (_) {}

      _resetMainPlaybackUi();
      return;
    }

    // فحص الإنترنت
    final internet = await _checkInternetSafely(
      _audioService2.checkInternet,
    );

    if (!mounted) return;

    // لا يوجد إنترنت
    if (internet == false) {
      _showNoInternetSnackBar();
      return;
    }

    // الإنترنت ضعيف
    if (internet == null) {
      _showWeakInternetSnackBar();
      return;
    }

    final requestId = ++_playRequestId;

    setState(() {
      isitplay = true;
      isloading = true;
      isPlayerPause = false;
      onOff = translation?.turnOff ?? "إيقاف";
      iconData = Icons.stop;
      iconDataPause = Icons.pause;
      highlightedVerse = null;
      highlightedWord = null;
    });

    _startLoadingWatchdog(
      player: _audioService2.player,
      requestId: requestId,
    );

    unawaited(_runQalounPlayback(requestId));
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

  Widget _buildHafsBottomActionBars() {
    if (highlightedVerse != null && highlightedWord == null) {
      return BottomBarAnimation2(
        onIconTap: (index) async {
          //////////////////////////////////////////////////
          // تشغيل الآية
          //////////////////////////////////////////////////

          if (index == 0) {
            isitplay = false;
            onOff = translation!.turnOn;
            iconData = Icons.play_arrow;
            // إيقاف
            if (isPlayingHafsAyah) {
              await _audioService.stop();

              setState(() {
                isPlayingHafsAyah = false;

                positionsOfMusic = null;
                sizeoficonOfMusic = null;
              });

              return;
            }

            //////////////////////////////////////////////////
            // التوقيتات
            //////////////////////////////////////////////////

            final internet = await _checkInternetSafely(
              _audioService.checkInternet,
            );

            if (!mounted) return;

            if (internet == false) {
              _showNoInternetSnackBar();
              return;
            }

            if (internet == null) {
              _showWeakInternetSnackBar();
              return;
            }

            try {
              final timings = await _audioService
                  .fetchAyahTimings(
                    surahNumber,
                    idOfReciterHafs,
                  )
                  .timeout(_loadingTimeout);

              if (!mounted) return;

              final currentAyahTiming = timings.firstWhere(
                (t) => t.ayah == highlightedVerse,
              );

              setState(() {
                isPlayingHafsAyah = true;
                positionsOfMusic = -30;
                sizeoficonOfMusic = 48;
              });

              await _audioService.playAyah(
                urlOfReciterHafs,
                surahNumber,
                currentAyahTiming,
              );
            } on TimeoutException {
              if (!mounted) return;
              _showWeakInternetSnackBar();

              setState(() {
                isPlayingHafsAyah = false;
                positionsOfMusic = null;
                sizeoficonOfMusic = null;
              });
            } catch (_) {
              if (!mounted) return;
              _showWeakInternetSnackBar();

              setState(() {
                isPlayingHafsAyah = false;
                positionsOfMusic = null;
                sizeoficonOfMusic = null;
              });
            }
            highlightedVerse = null;
          }

          //////////////////////////////////////////////////
          // حفظ
          //////////////////////////////////////////////////

          else if (index == 1) {
            saveMyAya(
              highlightedVerse!,
              surahNumber,
              surahName ?? "",
            );
          }

          //////////////////////////////////////////////////
          // تفسير
          //////////////////////////////////////////////////

          else if (index == 2) {
            setState(() {
              showTafsir = 1;
            });
          }
        },
        icons: const [
          Icons.music_note,
          Icons.bookmark_outlined,
          Icons.format_align_right,
        ],
        positionsOfMusic: positionsOfMusic,
        sizeoficonOfMusic: sizeoficonOfMusic,
      );
    }

    //////////////////////////////////////////////////////
    // تشغيل كلمة
    //////////////////////////////////////////////////////

    else if (highlightedWord != null && highlightedVerse == null) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(16),
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: scandColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: dilutionScandColor,
              width: 2,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.music_note,
              size: 36,
              color: mainColor,
            ),
            onPressed: () async {
              final internet = await _checkInternetSafely(
                _audioService.checkInternet,
              );

              if (!mounted) return;

              if (internet == false) {
                _showNoInternetSnackBar();
                return;
              }

              if (internet == null) {
                _showWeakInternetSnackBar();
                return;
              }

              isitplay = false;
              onOff = translation?.turnOn ?? "تشغيل";
              iconData = Icons.play_arrow;

              await _audioService.playWord(
                surahNumber,
                highlightedWordVerse!,
                highlightedWord!,
              );
            },
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildQalounBottomActionBars() {
    if (highlightedVerse != null && highlightedWord == null) {
      return Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height - 75,
        ),
        child: BottomBarAnimation2(
          onIconTap: (index) async {
            //////////////////////////////////////////////////
            // تشغيل الآية
            //////////////////////////////////////////////////

            if (index == 0) {
              isitplay = false;
              onOff = translation!.turnOn;
              iconData = Icons.play_arrow;
              // إيقاف
              if (isPlayingQalounAyah) {
                await _audioService2.stop();

                setState(() {
                  isPlayingQalounAyah = false;

                  positionsOfMusic = null;
                  sizeoficonOfMusic = null;
                });

                return;
              }

              //////////////////////////////////////////////////
              // التحقق من الإنترنت
              //////////////////////////////////////////////////

              final internet = await _checkInternetSafely(
                _audioService2.checkInternet,
              );

              if (!mounted) return;

              if (internet == false) {
                _showNoInternetSnackBar();
                return;
              }

              if (internet == null) {
                _showWeakInternetSnackBar();
                return;
              }

              //////////////////////////////////////////////////
              // التوقيتات
              //////////////////////////////////////////////////

              try {
                final timings = await _audioService2
                    .fetchAyahTimings(
                      surahNumber,
                    )
                    .timeout(_loadingTimeout);

                if (!mounted) return;

                final currentAyahTiming = timings.firstWhere(
                  (t) => t.ayah == highlightedVerse,
                );

                //////////////////////////////////////////////////
                // تشغيل
                //////////////////////////////////////////////////

                setState(() {
                  isPlayingQalounAyah = true;

                  positionsOfMusic = -30;
                  sizeoficonOfMusic = 48;
                });

                await _audioService2.playAyah(
                  surahNumber,
                  currentAyahTiming,
                );
              } on TimeoutException {
                if (!mounted) return;
                _showWeakInternetSnackBar();

                setState(() {
                  isPlayingQalounAyah = false;
                  positionsOfMusic = null;
                  sizeoficonOfMusic = null;
                });
              } catch (_) {
                if (!mounted) return;
                setState(() {
                  isPlayingQalounAyah = false;
                  positionsOfMusic = null;
                  sizeoficonOfMusic = null;
                });

                _showWeakInternetSnackBar();
              }

              highlightedVerse = null;
            }

            //////////////////////////////////////////////////
            // حفظ
            //////////////////////////////////////////////////

            else if (index == 1) {
              saveMyAya(
                highlightedVerse!,
                surahNumber,
                surahName ?? "",
              );
            }

            //////////////////////////////////////////////////
            // تفسير
            //////////////////////////////////////////////////

            else if (index == 2) {
              setState(() {
                showTafsir = 1;
              });
            }
          },
          icons: const [
            Icons.music_note,
            Icons.bookmark_outlined,
            Icons.format_align_right,
          ],
          positionsOfMusic: positionsOfMusic,
          sizeoficonOfMusic: sizeoficonOfMusic,
        ),
      );
    }

    return const SizedBox();
  }

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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CustomLoadingScreen2();
                  }
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
    setState(() {
      highlightedWord = null;
      highlightedWordVerse = null;
    });
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const CustomSnackBar(
            text: "الإنترنت غير متوفر",
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.05,
          ),
        ),
      );
  }

  void _showWeakInternetSnackBar() {
    setState(() {
      highlightedWord = null;
      highlightedWordVerse = null;
    });
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const CustomSnackBar(
            text: "الإنترنت ضعيف، يرجى المحاولة مرة أخرى",
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.05,
          ),
        ),
      );
  }

  Future<void> copySelectedVerse() async {
    if (highlightedVerse == null) return;

    final jsonString = await rootBundle.loadString(
      'assets/json/quran/$riwoya/surahs/$surahNumber.json',
    );

    final List<dynamic> data = json.decode(jsonString);

    final verse = data.firstWhere(
      (e) => e["verse_number"] == highlightedVerse,
    );

    final String text = verse["content"];

    await Clipboard.setData(
      ClipboardData(text: text),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomSnackBar(
            text: translation != null && translation!.copy.isNotEmpty
                ? translation!.copy
                : "تم نسخ الآية"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
