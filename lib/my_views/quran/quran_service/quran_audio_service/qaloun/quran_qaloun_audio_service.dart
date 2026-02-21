import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:risala/models/reciters/qaloun/ayah_timing.dart';

class QuranQalounAudioService {
  final AudioPlayer player = AudioPlayer();

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

/////////////////////////////////////////////////////////////////////
  Future<void> playSurah(String urlReciter, int surah) async {
    final url = "$urlReciter${surah.toString().padLeft(3, '0')}.mp3";

    await player.stop();
    await player.setUrl(url);
    player.play();
  }
//////////////////////////////////////////////////////////////////////

  Future<List<AyahTiming>> fetchAyahTimings(int surah) async {
    final url =
        "https://www.mp3quran.net/api/v3/ayat_timing?surah=$surah&read=75";

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

  Future<void> playAyah(int surah, AyahTiming timing) async {
    final url =
        "https://server9.mp3quran.net/huthifi_qalon/${surah.toString().padLeft(3, '0')}.mp3";

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

  void dispose() {
    player.dispose();
  }
}
