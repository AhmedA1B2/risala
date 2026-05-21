import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:risala/models/reciters/qaloun/ayah_timing.dart';

class QuranQalounAudioService {
  final AudioPlayer player = AudioPlayer();

  /////////////////////////////////////////////////////////
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty &&
          result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /////////////////////////////////////////////////////////
  Future<void> playSurah(
    String urlReciter,
    int surah,
  ) async {
    final url =
        "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

    await player.stop();

    await player.setUrl(url);

    await player.play();
  }

  /////////////////////////////////////////////////////////
  Future<List<AyahTiming>> fetchAyahTimings(
    int surah,
  ) async {
    final url =
        "https://www.mp3quran.net/api/v3/ayat_timing?surah=$surah&read=75";

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        List<dynamic> data =
            json.decode(response.body);

        return data
            .map(
              (item) =>
                  AyahTiming.fromJson(item),
            )
            .toList();
      }
    } catch (e) {
      debugPrint("Error fetching timings: $e");
    }

    return [];
  }

  /////////////////////////////////////////////////////////
  Future<void> playAyah(
    int surah,
    AyahTiming timing,
  ) async {
    final url =
        "https://server9.mp3quran.net/huthifi_qalon/${surah.toString().padLeft(3, '0')}.mp3";

    await player.stop();

    final audioSource = ClippingAudioSource(
      child: AudioSource.uri(
        Uri.parse(url),
      ),
      start: Duration(
        milliseconds: timing.startTime,
      ),
      end: Duration(
        milliseconds: timing.endTime,
      ),
    );

    await player.setAudioSource(audioSource);

    await player.play();
  }

  /////////////////////////////////////////////////////////
  Future<String?> downloadSurah(
    String urlReciter,
    int surah,
    String surahName,
    String reciterid,
    Function(double progress)? onProgress,
  ) async {
    try {

      /////////////////////////////////////////////////////
      // الصلاحيات
      /////////////////////////////////////////////////////

      if (Platform.isAndroid) {

        // Android 13+
        await Permission.audio.request();

        // Android 12 وأقل
        await Permission.storage.request();
      }

      /////////////////////////////////////////////////////
      // رابط الملف
      /////////////////////////////////////////////////////

      final url =
          "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

      /////////////////////////////////////////////////////
      // مجلد Music الحقيقي
      /////////////////////////////////////////////////////

      final Directory musicDir =
          Directory(
        "/storage/emulated/0/Music/Risala Quran/Qaloun$reciterid",
      );

      /////////////////////////////////////////////////////
      // إنشاء المجلد
      /////////////////////////////////////////////////////

      if (!await musicDir.exists()) {
        await musicDir.create(
          recursive: true,
        );
      }

      /////////////////////////////////////////////////////
      // اسم الملف
      /////////////////////////////////////////////////////

      final String filePath =
          "${musicDir.path}/${surah.toString().padLeft(3, '0')} - $surahName.mp3";

      /////////////////////////////////////////////////////
      // التحميل
      /////////////////////////////////////////////////////

      await Dio().download(
        url,
        filePath,
        deleteOnError: true,

        onReceiveProgress: (
          received,
          total,
        ) {
          if (total > 0 &&
              onProgress != null) {
            onProgress(
              received / total,
            );
          }
        },
      );

      /////////////////////////////////////////////////////
      // تحديث ملفات النظام
      /////////////////////////////////////////////////////

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

      debugPrint(
        "تم حفظ السورة في: $filePath",
      );

      return filePath;

    } catch (e) {

      debugPrint(
        "خطأ أثناء التحميل: $e",
      );

      return null;
    }
  }

  /////////////////////////////////////////////////////////
  Future<bool> isSurahDownloaded(
    int surah,
    String reciterid,
    String surahName,
  ) async {

    final filePath =
        "/storage/emulated/0/Music/Risala Quran/Qaloun$reciterid/${surah.toString().padLeft(3, '0')} - $surahName.mp3";

    return File(filePath).exists();
  }

  /////////////////////////////////////////////////////////
  void dispose() {
    player.dispose();
  }
}