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

enum _PlaybackKind { none, surah, ayah, word }

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

  late StreamSubscription<PlayerState> playerSub1;
  late StreamSubscription<PlayerState> playerSub2;
  int _savedRetry = 0;
  int _searchRetry = 0;

  // حالة عملية الصوت النشطة؛ أحداث أي مشغل آخر يتم تجاهلها.
  AudioPlayer? _activePlayer;
  _PlaybackKind _playbackKind = _PlaybackKind.none;
  String? _activeRiwoya;
  bool _isPreparingMainPlayback = false;
  bool _isAyahBusy = false;
  bool _isWordBusy = false;
  Future<void> _audioStopQueue = Future<void>.value();
  Timer? _savedRetryTimer;
  Timer? _searchRetryTimer;

  // تحميل التفسير مرة واحدة لكل لغة بدل فك JSON عند كل إعادة بناء.
  final Map<String, Future<Map<String, String>>> _tafsirDataByLanguage = {};

  Future<void> checkDownloaded() async {
    final int checkedSurah = surahNumber;
    final String checkedRiwoya = riwoya;
    final int checkedHafsReciter = idOfReciterHafs;
    final String checkedQalounReciter = idOfReciterQaloun;
    final String? checkedName = surahName;

    if (checkedName == null || checkedName.isEmpty) {
      if (mounted) setState(() => isDownloaded = false);
      return;
    }

    var downloaded = false;
    try {
      if (checkedRiwoya == "hafs") {
        downloaded = await _audioService.isSurahDownloaded(
          checkedSurah,
          checkedHafsReciter,
          checkedName,
        );
      } else {
        downloaded = await _audioService2.isSurahDownloaded(
          checkedSurah,
          checkedQalounReciter,
          checkedName,
        );
      }
    } catch (_) {
      downloaded = false;
    }

    if (!mounted ||
        checkedSurah != surahNumber ||
        checkedRiwoya != riwoya ||
        checkedHafsReciter != idOfReciterHafs ||
        checkedQalounReciter != idOfReciterQaloun ||
        checkedName != surahName) {
      return;
    }
    setState(() => isDownloaded = downloaded);
  }

  @override
  void initState() {
    super.initState();

    playerSub1 = _audioService.player.playerStateStream.listen(
      (state) => _handlePlayerState(_audioService.player, state),
      onError: (Object error, StackTrace stack) {
        _handlePlayerError(_audioService.player);
      },
    );
    playerSub2 = _audioService2.player.playerStateStream.listen(
      (state) => _handlePlayerState(_audioService2.player, state),
      onError: (Object error, StackTrace stack) {
        _handlePlayerError(_audioService2.player);
      },
    );

    unawaited(_initializeView());

    if (widget.x == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goToSavedVerse());
    } else if (widget.x == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) => goToSearchedVerse());
    }
  }

  Future<void> _initializeView() async {
    await Future.wait<void>([
      loadAllTranslations(),
      loadSurahName(),
      loadData(),
    ]);
    if (mounted) await checkDownloaded();
  }

  void _handlePlayerState(AudioPlayer player, PlayerState state) {
    if (!mounted || !identical(player, _activePlayer)) return;

    final requestId = _playRequestId;
    switch (state.processingState) {
      case ProcessingState.loading:
      case ProcessingState.buffering:
        if (!isloading) setState(() => isloading = true);
        if (_playbackKind != _PlaybackKind.none) {
          _startLoadingWatchdog(player: player, requestId: requestId);
        }
        break;
      case ProcessingState.ready:
        _cancelLoadingWatchdog(requestId: requestId);
        if (isloading) setState(() => isloading = false);
        break;
      case ProcessingState.completed:
        _cancelLoadingWatchdog(requestId: requestId);
        _finishPlayback(requestId);
        break;
      case ProcessingState.idle:
        // قد تكون idle حالة طبيعية قبل ضبط المصدر. لا نعيد ضبط الواجهة
        // هنا لأن ذلك قد يلغي عملية تشغيل بدأت للتو.
        break;
    }
  }

  void _handlePlayerError(AudioPlayer player) {
    if (!mounted || !identical(player, _activePlayer)) return;
    final requestId = _playRequestId;
    _finishPlayback(requestId);
    _showWeakInternetSnackBar();
  }

  Future<bool?> _checkInternetSafely(
    Future<bool> Function() checkInternet,
  ) async {
    try {
      return await checkInternet().timeout(_internetCheckTimeout);
    } on SocketException {
      return false;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  void _cancelLoadingWatchdog({int? requestId}) {
    if (requestId != null && _loadingWatchdogRequestId != requestId) return;
    _loadingWatchdog?.cancel();
    _loadingWatchdog = null;
    _loadingWatchdogRequestId = null;
  }

  void _startLoadingWatchdog({
    required AudioPlayer player,
    required int requestId,
  }) {
    if (!mounted ||
        requestId != _playRequestId ||
        !identical(player, _activePlayer)) {
      return;
    }
    if (_loadingWatchdog != null &&
        _loadingWatchdog!.isActive &&
        _loadingWatchdogRequestId == requestId) {
      return;
    }

    _cancelLoadingWatchdog();
    _loadingWatchdogRequestId = requestId;
    _loadingWatchdog = Timer(_loadingTimeout, () async {
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(player, _activePlayer)) {
        return;
      }

      final state = player.processingState;
      if (state == ProcessingState.ready ||
          state == ProcessingState.completed) {
        _cancelLoadingWatchdog(requestId: requestId);
        if (mounted && requestId == _playRequestId) {
          setState(() => isloading = false);
        }
        return;
      }

      // أبطل العملية قبل إيقاف المشغلات، حتى لا تعيد أحداث الإيقاف حالتها.
      _finishPlayback(requestId);
      await _stopBothPlayersSafely();
      if (!mounted || requestId != _playRequestId) return;
      _showWeakInternetSnackBar();
    });
  }

  Future<void> _stopBothPlayersSafely() {
    // تسلسل عمليات stop يمنع عملية إيقاف أقدم من قطع تشغيل أحدث.
    final next = _audioStopQueue.then((_) async {
      try {
        await _audioService.player.stop();
      } catch (_) {}
      try {
        await _audioService2.player.stop();
      } catch (_) {}
    });
    _audioStopQueue = next;
    return next;
  }

  void _finishPlayback(int requestId) {
    if (!mounted || requestId != _playRequestId) return;
    _cancelLoadingWatchdog(requestId: requestId);
    _activePlayer = null;
    _activeRiwoya = null;
    _playbackKind = _PlaybackKind.none;
    _isPreparingMainPlayback = false;
    _isAyahBusy = false;
    _isWordBusy = false;

    setState(() {
      isloading = false;
      isitplay = false;
      isPlayerPause = false;
      isPlayingHafsAyah = false;
      isPlayingQalounAyah = false;
      isPlayingAyah = false;
      positionsOfMusic = null;
      sizeoficonOfMusic = null;
      iconData = Icons.play_arrow;
      iconDataPause = Icons.pause_rounded;
      onOff = translation?.turnOn ?? "تشغيل";
    });
  }

  Future<void> _stopPlayback() async {
    ++_playRequestId;
    _cancelLoadingWatchdog();
    _activePlayer = null;
    _activeRiwoya = null;
    _playbackKind = _PlaybackKind.none;
    _isPreparingMainPlayback = false;
    _isAyahBusy = false;
    _isWordBusy = false;

    if (mounted) {
      setState(() {
        isloading = false;
        isitplay = false;
        isPlayerPause = false;
        isPlayingHafsAyah = false;
        isPlayingQalounAyah = false;
        isPlayingAyah = false;
        positionsOfMusic = null;
        sizeoficonOfMusic = null;
        iconData = Icons.play_arrow;
        iconDataPause = Icons.pause_rounded;
        onOff = translation?.turnOn ?? "تشغيل";
      });
    }
    await _stopBothPlayersSafely();
  }

  String _localSurahFilePath({
    required bool hafs,
    required int requestedSurah,
    required String requestedName,
    required int hafsReciterId,
    required String qalounReciterId,
  }) {
    final paddedSurah = requestedSurah.toString().padLeft(3, '0');
    if (hafs) {
      return '/storage/emulated/0/Music/Risala Quran/$hafsReciterId/'
          '$paddedSurah - $requestedName--$hafsReciterId.mp3';
    }
    return '/storage/emulated/0/Music/Risala Quran/Qaloun$qalounReciterId/'
        '$paddedSurah - $requestedName.mp3';
  }

  Future<void> _queueLocalFilePlayback({
    required int requestId,
    required AudioPlayer player,
    required String filePath,
  }) {
    final next = _audioStopQueue.then((_) async {
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(_activePlayer, player)) {
        return;
      }
      try {
        await player.setFilePath(filePath);
      } catch (_) {
        if (mounted &&
            requestId == _playRequestId &&
            identical(_activePlayer, player)) {
          _finishPlayback(requestId);
          _showWeakInternetSnackBar();
        }
        return;
      }
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(_activePlayer, player)) {
        return;
      }
      unawaited(_playConfiguredPlayer(player, requestId));
    });
    _audioStopQueue = next;
    return next;
  }

  Future<void> _playConfiguredPlayer(AudioPlayer player, int requestId) async {
    try {
      await player.play();
    } catch (_) {
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(_activePlayer, player)) {
        return;
      }
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    }
  }

  Future<void> _runHafsPlayback(
    int requestId,
    int requestedSurah,
    String requestedUrl,
    String? localFilePath,
  ) async {
    try {
      if (localFilePath != null) {
        await _queueLocalFilePlayback(
          requestId: requestId,
          player: _audioService.player,
          filePath: localFilePath,
        );
      } else {
        await _audioService.playSurah(requestedUrl, requestedSurah);
      }
    } catch (_) {
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(_activePlayer, _audioService.player)) {
        return;
      }
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    }
  }

  Future<void> _runQalounPlayback(
    int requestId,
    int requestedSurah,
    String requestedUrl,
    String? localFilePath,
  ) async {
    try {
      if (localFilePath != null) {
        await _queueLocalFilePlayback(
          requestId: requestId,
          player: _audioService2.player,
          filePath: localFilePath,
        );
      } else {
        await _audioService2.playSurah(requestedUrl, requestedSurah);
      }
    } catch (_) {
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(_activePlayer, _audioService2.player)) {
        return;
      }
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    }
  }

  @override
  void dispose() {
    _cancelLoadingWatchdog();
    _savedRetryTimer?.cancel();
    _searchRetryTimer?.cancel();
    playerSub1.cancel();
    playerSub2.cancel();
    _audioService.dispose();
    _audioService2.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadSurahName() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/surahs.json');
      final List<dynamic> jsonData = json.decode(jsonString) as List<dynamic>;
      Map<String, dynamic>? surahData;
      for (final item in jsonData) {
        if (item is Map && item['number'] == surahNumber) {
          surahData = Map<String, dynamic>.from(item);
          break;
        }
      }

      if (!mounted) return;
      final language = sharedPref.getString("selectedValue") ?? "ar";
      setState(() {
        if (surahData == null) {
          surahName = '';
        } else if (language == 'ar') {
          surahName = (surahData!['name'] as String?) ?? '';
        } else {
          surahName = (surahData!['englishName'] as String?) ??
              (surahData!['name'] as String?) ??
              '';
        }
      });
    } catch (_) {
      if (mounted) setState(() => surahName = '');
    }
  }

  Future<void> loadData() async {
    try {
      final loadedHafs = await loadRecitersHafs();
      final loadedQaloun = await loadRecitersQalouin();
      if (!mounted) return;

      setState(() {
        recitersHafs = loadedHafs;
        recitersQaloun = loadedQaloun;
        selectedReciterHafs = _findHafsReciter(idOfReciterHafs, loadedHafs);
        selectedReciterQaloun =
            _findQalounReciter(idOfReciterQaloun, loadedQaloun);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        recitersHafs = [];
        recitersQaloun = [];
        selectedReciterHafs = null;
        selectedReciterQaloun = null;
      });
    }
  }

  RecitersHafs? _findHafsReciter(int id, List<RecitersHafs> list) {
    for (final reciter in list) {
      if (reciter.id == id) return reciter;
    }
    return null;
  }

  RecitersQaloun? _findQalounReciter(String id, List<RecitersQaloun> list) {
    for (final reciter in list) {
      if (reciter.id == id) return reciter;
    }
    return null;
  }

  Future<List<RecitersHafs>> loadRecitersHafs() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/reciters/hafs/surah.json',
    );
    final Map<String, dynamic> jsonData =
        json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> recitations = jsonData['recitations'] as List<dynamic>;
    return recitations
        .map((item) => RecitersHafs.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<RecitersQaloun>> loadRecitersQalouin() async {
    final jsonString = await rootBundle.loadString(
      'assets/json/reciters/qaloun/surah.json',
    );
    final Map<String, dynamic> jsonData =
        json.decode(jsonString) as Map<String, dynamic>;
    final List<dynamic> recitations = jsonData['recitations'] as List<dynamic>;
    return recitations
        .map((item) => RecitersQaloun.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> loadAllTranslations() async {
    try {
      final list = await loadTranslation(
        sharedPref.getString("selectedValue") ?? "ar",
      );
      if (!mounted) return;
      setState(() {
        translation = list.isNotEmpty ? list.first : null;
        onOff = translation?.turnOn ?? "تشغيل";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        translation = null;
        onOff = "تشغيل";
      });
    }
  }

  Future<void> saveMyAya(int verse, int surah, String savedSurahName) async {
    try {
      await sharedPref.setInt('ayasaved', verse);
      await sharedPref.setInt('surahsaved', surah);
      await sharedPref.setString('namesaved', savedSurahName);
    } catch (_) {
      if (!mounted) return;
      _showGeneralSnackBar("تعذر حفظ الآية، يرجى المحاولة مرة أخرى");
      return;
    }

    if (!mounted) return;
    setState(() {
      ayasaved = verse;
      surahsaved = surah;
      highlightedVerse = null;
      highlightedWord = null;
      highlightedWordVerse = null;
    });

    _showGeneralSnackBar(
      translation != null && translation!.saved.isNotEmpty
          ? translation!.saved
          : "تم الحفظ",
    );
  }

  void _showGeneralSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: CustomSnackBar(text: message),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
  }

  void goToSavedVerse() {
    if (!mounted || _savedRetry >= 10) return;
    final savedAyah = ayasaved;
    if (savedAyah == null || surahsaved != surahNumber) return;

    _savedRetryTimer?.cancel();
    _savedRetryTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      final ctx = verseContexts[savedAyah];
      if (ctx != null && ctx.mounted) {
        setState(() => highlightedVerse = savedAyah);
        unawaited(Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          alignment: 0.15,
        ));
      } else {
        _savedRetry++;
        goToSavedVerse();
      }
    });
  }

  void goToSearchedVerse() {
    final searchedAyah = widget.searchedVerse;
    if (!mounted || searchedAyah == null || _searchRetry >= 10) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = verseContexts[searchedAyah];
      if (ctx != null && ctx.mounted) {
        setState(() {
          highlightedVerse = searchedAyah;
          highlightedWord = null;
          highlightedWordVerse = null;
        });
        unawaited(Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          alignment: 0.3,
        ));
      } else {
        _searchRetry++;
        _searchRetryTimer?.cancel();
        _searchRetryTimer = Timer(
          const Duration(milliseconds: 180),
          goToSearchedVerse,
        );
      }
    });
  }

  int showTafsir = 0;

  Future<Map<String, String>> _loadTafsirMap(String language) {
    return _tafsirDataByLanguage.putIfAbsent(language, () async {
      final response = await rootBundle.loadString(
        'assets/json/tafsir/$language.json',
      );
      final List<dynamic> data = json.decode(response) as List<dynamic>;
      final map = <String, String>{};
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final tafsir = Tafsir.fromJson(item);
        map['${tafsir.surah}:${tafsir.ayah}'] = tafsir.tafsir;
      }
      return map;
    });
  }

  Future<String?> getTafsir(int surah, int ayah) async {
    final language = sharedPref.getString("selectedValue") ?? "ar";
    try {
      final map = await _loadTafsirMap(language);
      return map['$surah:$ayah'];
    } catch (_) {
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
                isitplay: isitplay || _isPreparingMainPlayback,
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
                        highlightedWordVerse = null;
                      }),
                      onWordSelected: _handleWordSelected,
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
                        highlightedWordVerse = null;
                      }),
                      onWordSelected: _handleWordSelected,
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
          highlightedVerse == null && highlightedWord == null
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
                            : _downloadCurrentSurah,
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
              bottom: 120,
              icon: Icons.copy,
              onTap: () => copySelectedVerse(),
            ),
          if (isloading) const IgnorePointer(child: CustomLoadingScreen2()),
        ],
      ),
    );
  }

  Widget _buildReciterHafsDropdown() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<RecitersHafs>(
        isExpanded: true,
        menuWidth: 240,
        value: selectedReciterHafs,
        hint: Text(
          sharedPref.getInt("numOfReciter") != null
              ? "القارئ ${sharedPref.getInt("numOfReciter")}"
              : "القارئ",
          overflow: TextOverflow.ellipsis,
        ),
        items: recitersHafs
            .map((reciter) => DropdownMenuItem<RecitersHafs>(
                  value: reciter,
                  child: Text(
                    reciter.reciterName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
                  ),
                ))
            .toList(),
        onChanged: recitersHafs.isEmpty
            ? null
            : (value) async {
                if (value == null) return;
                if (_playbackKind != _PlaybackKind.none ||
                    _isPreparingMainPlayback) {
                  await _stopPlayback();
                }
                if (!mounted) return;
                setState(() {
                  selectedReciterHafs = value;
                  urlOfReciterHafs = value.urlReciter;
                  idOfReciterHafs = value.id;
                  isDownloaded = false;
                });
                _audioService.clearTimingsCache();
                await sharedPref.setString(
                    "urlOfReciterHafs", value.urlReciter);
                await sharedPref.setInt("idOfReciter", value.id);
                await sharedPref.setInt("numOfReciter", value.number);
                if (mounted) await checkDownloaded();
              },
      ),
    );
  }

  Widget _buildReciterQalounDropdown() {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<RecitersQaloun>(
        isExpanded: true,
        menuWidth: 240,
        value: selectedReciterQaloun,
        hint: Text(
          sharedPref.getInt("numOfReciterQaloun") != null
              ? "القارئ ${sharedPref.getInt("numOfReciterQaloun")}"
              : "القارئ",
          overflow: TextOverflow.ellipsis,
        ),
        items: recitersQaloun
            .map((reciter) => DropdownMenuItem<RecitersQaloun>(
                  value: reciter,
                  child: Text(
                    reciter.reciterName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 14),
                  ),
                ))
            .toList(),
        onChanged: recitersQaloun.isEmpty
            ? null
            : (value) async {
                if (value == null) return;
                if (_playbackKind != _PlaybackKind.none ||
                    _isPreparingMainPlayback) {
                  await _stopPlayback();
                }
                if (!mounted) return;
                setState(() {
                  selectedReciterQaloun = value;
                  urlOfReciterQaloun = value.urlReciter;
                  idOfReciterQaloun = value.id;
                  isDownloaded = false;
                });
                await sharedPref.setString(
                    "urlOfReciterQaloun", value.urlReciter);
                await sharedPref.setString("idOfReciterQaloun", value.id);
                await sharedPref.setInt("numOfReciterQaloun", value.number);
                if (mounted) await checkDownloaded();
              },
      ),
    );
  }

  void _handleWordSelected(String wordKey) {
    if (wordKey.isEmpty) {
      setState(() {
        highlightedWord = null;
        highlightedWordVerse = null;
      });
      return;
    }
    final parts = wordKey.split('-');
    if (parts.length != 2) return;
    final verse = int.tryParse(parts[0]);
    final word = int.tryParse(parts[1]);
    if (verse == null || word == null || verse < 1 || word < 1) return;
    setState(() {
      highlightedWordVerse = verse;
      highlightedWord = word;
      highlightedVerse = null;
    });
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

  Future<void> _handleMainHafsPlayButton() => _handleMainPlayButton(hafs: true);

  Future<void> _handleMainQalounPlayButton() =>
      _handleMainPlayButton(hafs: false);

  Future<void> _handleMainPlayButton({required bool hafs}) async {
    final requestedRiwoya = hafs ? 'hafs' : 'qaloun';
    final requestedPlayer = hafs ? _audioService.player : _audioService2.player;

    if (_isPreparingMainPlayback ||
        (_playbackKind == _PlaybackKind.surah &&
            _activeRiwoya == requestedRiwoya &&
            identical(_activePlayer, requestedPlayer))) {
      await _stopPlayback();
      return;
    }

    final requestId = ++_playRequestId;
    _cancelLoadingWatchdog();
    _activePlayer = null;
    _activeRiwoya = null;
    _playbackKind = _PlaybackKind.none;
    _isAyahBusy = false;
    _isWordBusy = false;
    _isPreparingMainPlayback = true;

    if (mounted) {
      setState(() {
        isitplay = true;
        isloading = true;
        isPlayerPause = false;
        iconDataPause = Icons.pause_rounded;
        onOff = translation?.turnOff ?? "إيقاف";
        iconData = Icons.stop;
        highlightedVerse = null;
        highlightedWord = null;
        highlightedWordVerse = null;
      });
    }

    try {
      await _stopBothPlayersSafely();
      if (!mounted || requestId != _playRequestId) return;

      // تأكد من توفر اسم السورة قبل استخدامه في فحص الملف المحلي.
      if (surahName == null || surahName!.isEmpty) {
        await loadSurahName();
      }
      if (!mounted || requestId != _playRequestId) return;

      final requestedSurah = surahNumber;
      final requestedName = surahName ?? '';
      final requestedUrl = hafs ? urlOfReciterHafs : urlOfReciterQaloun;
      final requestedHafsId = idOfReciterHafs;
      final requestedQalounId = idOfReciterQaloun;

      bool localFileAvailable = false;
      try {
        localFileAvailable = hafs
            ? await _audioService.isSurahDownloaded(
                requestedSurah, requestedHafsId, requestedName)
            : await _audioService2.isSurahDownloaded(
                requestedSurah, requestedQalounId, requestedName);
      } catch (_) {
        localFileAvailable = false;
      }
      if (!mounted || requestId != _playRequestId) return;

      String? requestedLocalPath;
      if (localFileAvailable) {
        requestedLocalPath = _localSurahFilePath(
          hafs: hafs,
          requestedSurah: requestedSurah,
          requestedName: requestedName,
          hafsReciterId: requestedHafsId,
          qalounReciterId: requestedQalounId,
        );
        // لا تعتمد على سجل التنزيل وحده؛ تحقق من وجود الملف نفسه.
        localFileAvailable = await File(requestedLocalPath).exists();
      }

      if (!localFileAvailable) {
        requestedLocalPath = null;
        final internet = await _checkInternetSafely(
          hafs ? _audioService.checkInternet : _audioService2.checkInternet,
        );
        if (!mounted || requestId != _playRequestId) return;
        if (internet == false) {
          _finishPlayback(requestId);
          _showNoInternetSnackBar();
          return;
        }
        if (internet == null) {
          _finishPlayback(requestId);
          _showWeakInternetSnackBar();
          return;
        }
      }

      if (!mounted || requestId != _playRequestId) return;
      setState(() {
        _isPreparingMainPlayback = false;
        _activePlayer = requestedPlayer;
        _activeRiwoya = requestedRiwoya;
        _playbackKind = _PlaybackKind.surah;
        isitplay = true;
        isloading = true;
      });
      _startLoadingWatchdog(player: requestedPlayer, requestId: requestId);

      if (hafs) {
        unawaited(_runHafsPlayback(
          requestId,
          requestedSurah,
          requestedUrl,
          requestedLocalPath,
        ));
      } else {
        unawaited(_runQalounPlayback(
          requestId,
          requestedSurah,
          requestedUrl,
          requestedLocalPath,
        ));
      }
    } catch (_) {
      if (!mounted || requestId != _playRequestId) return;
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    }
  }

  Future<void> _handlePauseHafsButton() =>
      _toggleMainPause(_audioService.player);
  Future<void> _handlePauseQalounButton() =>
      _toggleMainPause(_audioService2.player);

  Future<void> _toggleMainPause(AudioPlayer player) async {
    if (!identical(player, _activePlayer) ||
        _playbackKind != _PlaybackKind.surah) {
      return;
    }
    final requestId = _playRequestId;
    try {
      if (isPlayerPause) {
        // play() may complete only when playback ends; do not await it in the UI callback.
        unawaited(_resumePlayer(player, requestId));
        if (!mounted || requestId != _playRequestId) return;
        setState(() {
          isPlayerPause = false;
          iconDataPause = Icons.pause_rounded;
        });
      } else {
        await player.pause();
        if (!mounted || requestId != _playRequestId) return;
        setState(() {
          isPlayerPause = true;
          iconDataPause = Icons.play_arrow;
          isloading = false;
        });
        _cancelLoadingWatchdog(requestId: requestId);
      }
    } catch (_) {
      if (!mounted || requestId != _playRequestId) return;
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    }
  }

  Future<void> _resumePlayer(AudioPlayer player, int requestId) async {
    try {
      await player.play();
    } catch (_) {
      if (!mounted ||
          requestId != _playRequestId ||
          !identical(player, _activePlayer)) {
        return;
      }
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    }
  }

  Widget _buildHafsBottomActionBars() {
    if (highlightedVerse != null && highlightedWord == null) {
      return BottomBarAnimation2(
        onIconTap: (index) async {
          if (index == 0) {
            await _playSelectedAyah(hafs: true);
          } else if (index == 1) {
            final verse = highlightedVerse;
            if (verse != null)
              await saveMyAya(verse, surahNumber, surahName ?? "");
          } else if (index == 2) {
            setState(() => showTafsir = 1);
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

    if (highlightedWord != null && highlightedVerse == null) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.all(16),
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: scandColor,
            shape: BoxShape.circle,
            border: Border.all(color: dilutionScandColor, width: 2),
          ),
          child: IconButton(
            icon: Icon(Icons.music_note, size: 36, color: mainColor),
            onPressed: _playSelectedWord,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQalounBottomActionBars() {
    if (highlightedVerse == null || highlightedWord != null) {
      return const SizedBox.shrink();
    }
    return BottomBarAnimation2(
      onIconTap: (index) async {
        if (index == 0) {
          await _playSelectedAyah(hafs: false);
        } else if (index == 1) {
          final verse = highlightedVerse;
          if (verse != null)
            await saveMyAya(verse, surahNumber, surahName ?? "");
        } else if (index == 2) {
          setState(() => showTafsir = 1);
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

  Future<void> _playSelectedAyah({required bool hafs}) async {
    final selectedVerse = highlightedVerse;
    if (selectedVerse == null) return;

    final player = hafs ? _audioService.player : _audioService2.player;
    final selectedRiwoya = hafs ? 'hafs' : 'qaloun';
    if (_playbackKind == _PlaybackKind.ayah &&
        identical(player, _activePlayer) &&
        _activeRiwoya == selectedRiwoya) {
      await _stopPlayback();
      return;
    }
    if (_isAyahBusy) {
      await _stopPlayback();
      return;
    }

    _isAyahBusy = true;
    final requestId = ++_playRequestId;
    _cancelLoadingWatchdog();
    _activePlayer = null;
    _activeRiwoya = null;
    _playbackKind = _PlaybackKind.none;
    _isPreparingMainPlayback = false;
    _isWordBusy = false;
    if (mounted) {
      setState(() {
        isitplay = false;
        isloading = true;
        isPlayerPause = false;
        iconData = Icons.play_arrow;
        onOff = translation?.turnOn ?? "تشغيل";
        positionsOfMusic = -30;
        sizeoficonOfMusic = 48;
      });
    }

    try {
      await _stopBothPlayersSafely();
      if (!mounted || requestId != _playRequestId) return;

      final internet = await _checkInternetSafely(
        hafs ? _audioService.checkInternet : _audioService2.checkInternet,
      );
      if (!mounted || requestId != _playRequestId) return;
      if (internet == false) {
        _finishPlayback(requestId);
        _showNoInternetSnackBar();
        return;
      }
      if (internet == null) {
        _finishPlayback(requestId);
        _showWeakInternetSnackBar();
        return;
      }

      if (hafs) {
        final timings = await _audioService
            .fetchAyahTimings(surahNumber, idOfReciterHafs)
            .timeout(_loadingTimeout);
        if (!mounted || requestId != _playRequestId) return;
        final matchingTimings =
            timings.where((item) => item.ayah == selectedVerse);
        if (matchingTimings.isEmpty) {
          throw StateError('No timing found for selected ayah.');
        }
        final timing = matchingTimings.first;
        setState(() {
          _activePlayer = player;
          _activeRiwoya = selectedRiwoya;
          _playbackKind = _PlaybackKind.ayah;
          isloading = true;
          isPlayingHafsAyah = true;
          positionsOfMusic = -30;
          sizeoficonOfMusic = 48;
        });
        _startLoadingWatchdog(player: player, requestId: requestId);
        await _audioService.playAyah(urlOfReciterHafs, surahNumber, timing);
      } else {
        final timings = await _audioService2
            .fetchAyahTimings(surahNumber)
            .timeout(_loadingTimeout);
        if (!mounted || requestId != _playRequestId) return;
        final matchingTimings =
            timings.where((item) => item.ayah == selectedVerse);
        if (matchingTimings.isEmpty) {
          throw StateError('No timing found for selected ayah.');
        }
        final timing = matchingTimings.first;
        setState(() {
          _activePlayer = player;
          _activeRiwoya = selectedRiwoya;
          _playbackKind = _PlaybackKind.ayah;
          isloading = true;
          isPlayingQalounAyah = true;
          positionsOfMusic = -30;
          sizeoficonOfMusic = 48;
        });
        _startLoadingWatchdog(player: player, requestId: requestId);
        await _audioService2.playAyah(surahNumber, timing);
      }

      // خدمة حفص قد تعود بعد بدء الصوت لا بعد انتهائه؛ اكتمال المشغل
      // نفسه هو المصدر الموثوق لإعادة ضبط الحالة في هذا الفرع.
      if (!hafs && mounted && requestId == _playRequestId) {
        _finishPlayback(requestId);
      }
    } on TimeoutException {
      if (!mounted || requestId != _playRequestId) return;
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    } catch (_) {
      if (!mounted || requestId != _playRequestId) return;
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    } finally {
      if (requestId == _playRequestId) _isAyahBusy = false;
    }
  }

  Future<void> _playSelectedWord() async {
    final verse = highlightedWordVerse;
    final word = highlightedWord;
    if (verse == null || word == null) return;
    if (_isWordBusy) {
      await _stopPlayback();
      return;
    }

    _isWordBusy = true;
    final requestId = ++_playRequestId;
    _cancelLoadingWatchdog();
    _activePlayer = null;
    _activeRiwoya = null;
    _playbackKind = _PlaybackKind.none;
    _isPreparingMainPlayback = false;
    _isAyahBusy = false;
    if (mounted) setState(() => isloading = true);

    try {
      await _stopBothPlayersSafely();
      if (!mounted || requestId != _playRequestId) return;
      final internet = await _checkInternetSafely(_audioService.checkInternet);
      if (!mounted || requestId != _playRequestId) return;
      if (internet == false) {
        _finishPlayback(requestId);
        _showNoInternetSnackBar();
        return;
      }
      if (internet == null) {
        _finishPlayback(requestId);
        _showWeakInternetSnackBar();
        return;
      }

      setState(() {
        _activePlayer = _audioService.player;
        _activeRiwoya = 'hafs';
        _playbackKind = _PlaybackKind.word;
        isitplay = false;
        isloading = true;
      });
      // لا تبدأ مؤقت التحميل هنا؛ خدمة تشغيل الكلمة قد تحتاج إلى جلب بيانات
      // أولية قبل أن يظهر حدث loading من المشغل. عند بدء تحميل المشغل نفسه،
      // سيبدأ المستمع مؤقت الحماية تلقائيًا.
      await _audioService.playWord(surahNumber, verse, word);
      if (mounted && requestId == _playRequestId) _finishPlayback(requestId);
    } on TimeoutException {
      if (!mounted || requestId != _playRequestId) return;
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    } catch (_) {
      if (!mounted || requestId != _playRequestId) return;
      _finishPlayback(requestId);
      _showWeakInternetSnackBar();
    } finally {
      if (requestId == _playRequestId) _isWordBusy = false;
    }
  }

  Future<void> _downloadCurrentSurah() async {
    if (isDownloading || isDownloaded) return;
    if (surahName == null || surahName!.isEmpty) {
      _showGeneralSnackBar("تعذر تحديد اسم السورة، حاول مرة أخرى");
      return;
    }

    final requestedRiwoya = riwoya;
    final requestedSurah = surahNumber;
    final requestedName = surahName!;
    final requestedHafsId = idOfReciterHafs;
    final requestedQalounId = idOfReciterQaloun;
    final requestedHafsUrl = urlOfReciterHafs;
    final requestedQalounUrl = urlOfReciterQaloun;

    setState(() {
      isDownloading = true;
      downloadProgress = 0;
    });

    Object? result;
    try {
      if (requestedRiwoya == 'hafs') {
        result = await _audioService.downloadSurah(
          requestedHafsUrl,
          requestedSurah,
          requestedName,
          requestedHafsId.toString(),
          (progress) {
            if (mounted &&
                requestedRiwoya == riwoya &&
                requestedSurah == surahNumber &&
                requestedHafsId == idOfReciterHafs) {
              setState(
                  () => downloadProgress = progress.clamp(0.0, 1.0).toDouble());
            }
          },
        );
      } else {
        result = await _audioService2.downloadSurah(
          requestedQalounUrl,
          requestedSurah,
          requestedName,
          requestedQalounId,
          (progress) {
            if (mounted &&
                requestedRiwoya == riwoya &&
                requestedSurah == surahNumber &&
                requestedQalounId == idOfReciterQaloun) {
              setState(
                  () => downloadProgress = progress.clamp(0.0, 1.0).toDouble());
            }
          },
        );
      }
    } catch (_) {
      if (mounted)
        _showGeneralSnackBar("تعذر تنزيل السورة، تحقق من الاتصال وحاول مجددًا");
    } finally {
      if (mounted &&
          requestedRiwoya == riwoya &&
          requestedSurah == surahNumber &&
          (requestedRiwoya == 'hafs'
              ? requestedHafsId == idOfReciterHafs
              : requestedQalounId == idOfReciterQaloun)) {
        setState(() {
          isDownloading = false;
          isDownloaded = result != null;
          if (result != null) downloadProgress = 1;
        });
        if (result != null) {
          _showGeneralSnackBar("تم تنزيل السورة بنجاح");
        }
      } else if (mounted) {
        setState(() => isDownloading = false);
      }
    }
  }

  Widget _buildTafsirOverlay() {
    final verse = highlightedVerse;
    if (showTafsir == 0 || verse == null) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: whiteColor,
                border: Border.all(color: blackColor),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(22),
              child: FutureBuilder<String?>(
                future: getTafsir(surahNumber, verse),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomLoadingScreen2());
                  }
                  final tafsirText = snapshot.data;
                  return SingleChildScrollView(
                    child: Text(
                      snapshot.hasError ||
                              tafsirText == null ||
                              tafsirText.isEmpty
                          ? "لا يوجد تفسير"
                          : tafsirText,
                      style: TextStyle(
                        fontSize: quranfontSize,
                        fontFamily: 'Amiri',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 38),
                onPressed: () => setState(() => showTafsir = 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoInternetSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const CustomSnackBar(text: "الإنترنت غير متوفر"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.05,
          ),
        ),
      );
  }

  void _showWeakInternetSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const CustomSnackBar(
            text: "تعذر تشغيل الصوت أو أن الاتصال بطيء، حاول مرة أخرى",
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
    final requestedVerse = highlightedVerse;
    if (requestedVerse == null) return;
    final requestedSurah = surahNumber;
    final requestedRiwoya = riwoya;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/quran/$requestedRiwoya/surahs/$requestedSurah.json',
      );
      final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
      Map<String, dynamic>? verseData;
      for (final item in data) {
        if (item is Map && item['verse_number'] == requestedVerse) {
          verseData = Map<String, dynamic>.from(item);
          break;
        }
      }
      if (verseData == null || verseData['content'] is! String) {
        if (mounted) _showGeneralSnackBar("تعذر العثور على نص الآية");
        return;
      }

      await Clipboard.setData(
          ClipboardData(text: verseData['content'] as String));
      if (!mounted) return;
      _showGeneralSnackBar(
        translation != null && translation!.copy.isNotEmpty
            ? translation!.copy
            : "تم نسخ الآية",
      );
    } catch (_) {
      if (mounted) _showGeneralSnackBar("تعذر نسخ الآية، حاول مرة أخرى");
    }
  }
}
