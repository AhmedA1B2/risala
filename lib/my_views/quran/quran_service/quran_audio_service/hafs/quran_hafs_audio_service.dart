import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:risala/main.dart';
import 'package:risala/models/reciters/qaloun/ayah_timing.dart';

class QuranHafsAudioService {
  ////////////////////////////////////////////////////////////
  // Audio Player
  ////////////////////////////////////////////////////////////

  final AudioPlayer player = AudioPlayer();

  ////////////////////////////////////////////////////////////
  // Dio
  ////////////////////////////////////////////////////////////

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 20),
      followRedirects: true,
      validateStatus: (status) {
        return status != null &&
            status >= 200 &&
            status < 300;
      },
    ),
  );

  ////////////////////////////////////////////////////////////
  // API
  ////////////////////////////////////////////////////////////

  final String clientId =
      "e3af92df-f3d7-4d3a-9ccc-152c532492ee";

  final String clientSecret =
      "1tfKz8HWd3w9iyGkBTkv_b~N8t";

  final String tokenEndpoint =
      "https://oauth2.quran.foundation/oauth2/token";

  String? _accessToken;

  ////////////////////////////////////////////////////////////
  // Cache
  ////////////////////////////////////////////////////////////

  final Map<int, List<AyahTiming>>
      _timingsCache = {};

  ////////////////////////////////////////////////////////////
  // Internet Check
  ////////////////////////////////////////////////////////////

  Future<bool> checkInternet() async {
    try {
      final result =
          await InternetAddress.lookup(
        'google.com',
      ).timeout(
        const Duration(seconds: 5),
      );

      return result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  ////////////////////////////////////////////////////////////
  // Token
  ////////////////////////////////////////////////////////////

  Future<String?> fetchAccessToken() async {
    try {
      if (_accessToken != null) {
        return _accessToken;
      }

      final auth =
          'Basic ${base64Encode(
        utf8.encode(
          '$clientId:$clientSecret',
        ),
      )}';

      final response = await http
          .post(
            Uri.parse(tokenEndpoint),
            headers: {
              'Content-Type':
                  'application/x-www-form-urlencoded',
              'Authorization': auth,
            },
            body:
                'grant_type=client_credentials&scope=content',
          )
          .timeout(
            const Duration(seconds: 20),
          );

      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body);

        _accessToken =
            data['access_token'];

        return _accessToken;
      }

      debugPrint(
        "Token Error: ${response.statusCode}",
      );
    } catch (e) {
      debugPrint(
        "Token Exception: $e",
      );
    }

    return null;
  }

  ////////////////////////////////////////////////////////////
  // Stop Current Audio Safely
  ////////////////////////////////////////////////////////////

  Future<void> _preparePlayer() async {
    try {
      await player.stop();

      await player.seek(
        Duration.zero,
      );
    } catch (_) {}
  }

  ////////////////////////////////////////////////////////////
  // Play Surah
  ////////////////////////////////////////////////////////////

  Future<bool> playSurah(
    String urlReciter,
    int surah,
  ) async {
    try {
      await _preparePlayer();

      final url =
          "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

      await player.setUrl(url);

      await player.play();

      return true;
    } catch (e) {
      debugPrint(
        "Play Surah Error: $e",
      );

      return false;
    }
  }

  ////////////////////////////////////////////////////////////
  // Fetch Ayah Timings
  ////////////////////////////////////////////////////////////

  Future<List<AyahTiming>>
      fetchAyahTimings(
    int surah,
    int reciter,
  ) async {
    try {
      //////////////////////////////////////////////////////
      // Cache
      //////////////////////////////////////////////////////

      if (_timingsCache.containsKey(
        surah,
      )) {
        return _timingsCache[surah]!;
      }

      //////////////////////////////////////////////////////
      // Default Reciter
      //////////////////////////////////////////////////////

      if (sharedPref.getInt(
                "numOfReciter",
              ) ==
              null ||
          sharedPref.getInt(
                "numOfReciter",
              )! >
              18) {
        reciter = 4;
      }

      //////////////////////////////////////////////////////
      // Request
      //////////////////////////////////////////////////////

      final url =
          "https://www.mp3quran.net/api/v3/ayat_timing?surah=$surah&read=$reciter";

      final response = await http
          .get(
            Uri.parse(url),
          )
          .timeout(
            const Duration(
              seconds: 20,
            ),
          );

      //////////////////////////////////////////////////////
      // Response
      //////////////////////////////////////////////////////

      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(response.body);

        final timings = data
            .map(
              (item) =>
                  AyahTiming.fromJson(item),
            )
            .toList();

        _timingsCache[surah] =
            timings;

        return timings;
      }
    } catch (e) {
      debugPrint(
        "Timings Error: $e",
      );
    }

    return [];
  }

  ////////////////////////////////////////////////////////////
  // Play Ayah
  ////////////////////////////////////////////////////////////

  Future<bool> playAyah(
    String urlReciter,
    int surah,
    AyahTiming timing,
  ) async {
    try {
      //////////////////////////////////////////////////////
      // Default Reciter
      //////////////////////////////////////////////////////

      if (sharedPref.getInt(
                "numOfReciter",
              ) ==
              null ||
          sharedPref.getInt(
                "numOfReciter",
              )! >
              18) {
        urlReciter =
            "https://server11.mp3quran.net/shatri/";
      }

      //////////////////////////////////////////////////////
      // URL
      //////////////////////////////////////////////////////

      final url =
          "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

      //////////////////////////////////////////////////////
      // Validate Timing
      //////////////////////////////////////////////////////

      if (timing.endTime <=
          timing.startTime) {
        return false;
      }

      //////////////////////////////////////////////////////
      // Prepare Player
      //////////////////////////////////////////////////////

      await _preparePlayer();

      //////////////////////////////////////////////////////
      // Audio Source
      //////////////////////////////////////////////////////

      final audioSource =
          ClippingAudioSource(
        child: AudioSource.uri(
          Uri.parse(url),
        ),
        start: Duration(
          milliseconds:
              timing.startTime,
        ),
        end: Duration(
          milliseconds:
              timing.endTime,
        ),
      );

      //////////////////////////////////////////////////////
      // Play
      //////////////////////////////////////////////////////

      await player.setAudioSource(
        audioSource,
      );

      await player.play();

      return true;
    } catch (e) {
      debugPrint(
        "Play Ayah Error: $e",
      );

      return false;
    }
  }

  ////////////////////////////////////////////////////////////
  // Play Word
  ////////////////////////////////////////////////////////////

  Future<bool> playWord(
    int surah,
    int verse,
    int position,
  ) async {
    try {
      //////////////////////////////////////////////////////
      // Prepare
      //////////////////////////////////////////////////////

      await _preparePlayer();

      //////////////////////////////////////////////////////
      // Build URL
      //////////////////////////////////////////////////////

      final s =
          surah.toString().padLeft(
                3,
                '0',
              );

      final v =
          verse.toString().padLeft(
                3,
                '0',
              );

      final p =
          position.toString().padLeft(
                3,
                '0',
              );

      final audioUrl =
          "https://audio.qurancdn.com/wbw/${s}_${v}_${p}.mp3";

      //////////////////////////////////////////////////////
      // Play
      //////////////////////////////////////////////////////

      await player.setUrl(
        audioUrl,
      );

      await player.play();

      return true;
    } catch (e) {
      debugPrint(
        "Play Word Error: $e",
      );

      return false;
    }
  }

  ////////////////////////////////////////////////////////////
  // Request Permissions
  ////////////////////////////////////////////////////////////

  Future<bool> _requestPermissions() async {
    try {
      if (!Platform.isAndroid) {
        return true;
      }

      //////////////////////////////////////////////////////
      // Android 13+
      //////////////////////////////////////////////////////

      final audioStatus =
          await Permission.audio.request();

      //////////////////////////////////////////////////////
      // Android <= 12
      //////////////////////////////////////////////////////

      final storageStatus =
          await Permission.storage.request();

      //////////////////////////////////////////////////////
      // Validate
      //////////////////////////////////////////////////////

      if (audioStatus.isDenied &&
          storageStatus.isDenied) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  ////////////////////////////////////////////////////////////
  // Download Surah
  ////////////////////////////////////////////////////////////

  Future<String?> downloadSurah(
    String urlReciter,
    int surah,
    String surahName,
    String reciterNum,
    Function(double progress)?
        onProgress,
  ) async {
    try {
      //////////////////////////////////////////////////////
      // Permissions
      //////////////////////////////////////////////////////

      final hasPermission =
          await _requestPermissions();

      if (!hasPermission) {
        debugPrint(
          "Permission Denied",
        );

        return null;
      }

      //////////////////////////////////////////////////////
      // URL
      //////////////////////////////////////////////////////

      final url =
          "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

      //////////////////////////////////////////////////////
      // Directory
      //////////////////////////////////////////////////////

      final Directory reciterDir =
          Directory(
        "/storage/emulated/0/Music/Risala Quran/Hafs$reciterNum",
      );

      //////////////////////////////////////////////////////
      // Create Directory
      //////////////////////////////////////////////////////

      if (!await reciterDir.exists()) {
        await reciterDir.create(
          recursive: true,
        );
      }

      //////////////////////////////////////////////////////
      // File Path
      //////////////////////////////////////////////////////

      final filePath =
          "${reciterDir.path}/${surah.toString().padLeft(3, '0')} - $surahName.mp3";

      //////////////////////////////////////////////////////
      // File Exists
      //////////////////////////////////////////////////////

      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }

      //////////////////////////////////////////////////////
      // Download
      //////////////////////////////////////////////////////

      await _dio.download(
        url,
        filePath,

        deleteOnError: true,

        onReceiveProgress: (
          received,
          total,
        ) {
          if (total <= 0) {
            return;
          }

          if (onProgress != null) {
            onProgress(
              received / total,
            );
          }
        },
      );

      //////////////////////////////////////////////////////
      // Media Scan
      //////////////////////////////////////////////////////

      if (Platform.isAndroid) {
        await Process.run(
          'am',
          [
            'broadcast',
            '-a',
            'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
            '-d',
            'file://$filePath'
          ],
        );
      }

      //////////////////////////////////////////////////////
      // Done
      //////////////////////////////////////////////////////

      debugPrint(
        "Downloaded: $filePath",
      );

      return filePath;
    } catch (e) {
      debugPrint(
        "Download Error: $e",
      );

      return null;
    }
  }

  ////////////////////////////////////////////////////////////
  // Check Downloaded
  ////////////////////////////////////////////////////////////

  Future<bool> isSurahDownloaded(
    int surah,
    int reciterNum,
    String surahName,
  ) async {
    try {
      final filePath =
          "/storage/emulated/0/Music/Risala Quran/Hafs$reciterNum/${surah.toString().padLeft(3, '0')} - $surahName.mp3";

      return File(filePath).exists();
    } catch (_) {
      return false;
    }
  }

  ////////////////////////////////////////////////////////////
  // Clear Cache
  ////////////////////////////////////////////////////////////

  void clearTimingsCache() {
    _timingsCache.clear();
  }

  ////////////////////////////////////////////////////////////
  // Dispose
  ////////////////////////////////////////////////////////////

  Future<void> dispose() async {
    try {
      await player.stop();

      await player.dispose();
    } catch (_) {}
  }
}