import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:risala/main.dart';
import 'package:risala/models/reciters/qaloun/ayah_timing.dart';

class QuranHafsAudioService {
  final AudioPlayer player = AudioPlayer();

  // بيانات الـ API
  final String clientId = "e3af92df-f3d7-4d3a-9ccc-152c532492ee";
  final String clientSecret = "1tfKz8HWd3w9iyGkBTkv_b~N8t";
  final String tokenEndpoint = "https://oauth2.quran.foundation/oauth2/token";

  String? _accessToken;

  // فحص الإنترنت
  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // الحصول على التوكن
  Future<String?> fetchAccessToken() async {
    try {
      final auth =
          'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}';
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': auth,
        },
        body: 'grant_type=client_credentials&scope=content',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        return _accessToken;
      }
    } catch (e) {
      debugPrint("🔥 Error fetching token: $e");
    }
    return null;
  }

/////////////////////////////////////////////////////////////////////
  Future<void> playSurah(String urlReciter, int surah) async {
    final url = "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

    await player.stop();
    await player.setUrl(url);
    player.play();
  }
//////////////////////////////////////////////////////////////////////

  Future<List<AyahTiming>> fetchAyahTimings(int surah, int reciter) async {
    if (sharedPref.getInt("numOfReciter")! > 18) reciter = 4;

    final url =
        "https://www.mp3quran.net/api/v3/ayat_timing?surah=$surah&read=$reciter";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => AyahTiming.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error fetching timings: $e");
    }
    return [];
  }

  Future<void> playAyah(String urlReciter, int surah, AyahTiming timing) async {
    if (sharedPref.getInt("numOfReciter") == null ||
        sharedPref.getInt("numOfReciter")! > 18) {
      urlReciter = "https://server11.mp3quran.net/shatri/";
    }
    final url = "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

    await player.stop();

    // نقتطع الجزء الخاص بالآية بناءً على التوقيتات
    final audioSource = ClippingAudioSource(
      child: AudioSource.uri(Uri.parse(url)),
      start: Duration(milliseconds: timing.startTime),
      end: Duration(milliseconds: timing.endTime),
    );

    await player.setAudioSource(audioSource);
    player.play();
  }

///////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
  // تشغيل كلمة محددة
  Future<void> playWord(String verseKey, int position, int recitationId) async {
    if (_accessToken == null) await fetchAccessToken();

    final response = await http.get(
      Uri.parse(
          "https://apis.quran.foundation/content/api/v4/verses/by_key/$verseKey?words=true&audio=$recitationId"),
      headers: {
        "Accept": "application/json",
        "x-auth-token": _accessToken!,
        "x-client-id": clientId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final words = data["verse"]["words"] as List<dynamic>;
      final word = words.firstWhere((w) => w["position"] == position,
          orElse: () => null);

      if (word != null && word["audio_url"] != null) {
        String audioUrl = word["audio_url"];
        if (!audioUrl.startsWith("http"))
          audioUrl = "https://verses.quran.com/$audioUrl";

        await player.stop();
        await player.setUrl(audioUrl);
        player.play();
      }
    }
  }

  void dispose() {
    player.dispose();
  }
}
