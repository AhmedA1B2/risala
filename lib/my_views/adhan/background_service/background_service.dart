import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:adhan/adhan.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:risala/main.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      initialNotificationTitle: "خدمة الأذان تعمل",
      initialNotificationContent: "سيتم تشغيل الأذان في الوقت المحدد",
    ),
    iosConfiguration: IosConfiguration(autoStart: true),
  );

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final prefs = await SharedPreferences.getInstance();

  double savedLat =
      prefs.getDouble("savedCityLat") ?? 32.8872; // طرابلس افتراضياً
  double savedLng = prefs.getDouble("savedCityLng") ?? 13.1913;

  final player = AudioPlayer();
  DateTime? nextPrayer = getNextPrayerTime(savedLat, savedLng);
  bool adhanPlayed = false;

  // استقبال أمر الإيقاف من الإشعار
  service.on("stopAdhan").listen((event) async {
    await player.stop();
    print("🛑 تم إيقاف الأذان بواسطة المستخدم من الإشعار");
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final now = DateTime.now();

    if (nextPrayer == null || now.isAfter(nextPrayer!)) {
      nextPrayer = getNextPrayerTime(savedLat, savedLng);
      adhanPlayed = false;
      print("🔁 تحديث وقت الصلاة القادمة: $nextPrayer");
    }

    final remaining = nextPrayer!.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (service is AndroidServiceInstance) {
      await service.setForegroundNotificationInfo(
        title: "خدمة الأذان تعمل",
        content: "الصلاة القادمة بعد "
            "${hours.toString().padLeft(2, '0')}:"
            "${minutes.toString().padLeft(2, '0')}:"
            "${seconds.toString().padLeft(2, '0')}",
      );
    }

    if (!adhanPlayed && remaining.inSeconds.abs() <= 3) {
      adhanPlayed = true;
      print("🔊 تشغيل الأذان الآن 🔊");
      prefs.setBool("adhanPlayed", true);
      // إشعار الأذان
      await NotificationService.instance.showAdhanNotification(
        id: 100,
        title: "الأذان",
        body: "اضغط لإيقاف الأذان",
      );

      // تشغيل الأذان
      await player.setAsset('assets/audio/adhan/Nasser_al_Qatami_Adhan.mp3');
      await player.play();

      player.playerStateStream.listen((state) async {
        if (state.processingState == ProcessingState.completed) {
          nextPrayer = getNextPrayerTime(savedLat, savedLng);
          adhanPlayed = false;
          print("✅ الأذان انتهى، تم تحديد الصلاة التالية: $nextPrayer");
          prefs.setBool("adhanPlayed", false);
        }
      });
    }
  });
}

// دالة حساب الصلاة القادمة
DateTime? getNextPrayerTime(double lat, double lng) {
  final coordinates = Coordinates(lat, lng);
  final params = CalculationMethod.umm_al_qura.getParameters();
  params.madhab = Madhab.shafi;

  final now = DateTime.now();
  final prayerTimes =
      PrayerTimes(coordinates, DateComponents.from(now), params);

  if (now.isBefore(prayerTimes.fajr)) return prayerTimes.fajr;
  if (now.isBefore(prayerTimes.dhuhr)) return prayerTimes.dhuhr;
  if (now.isBefore(prayerTimes.asr)) return prayerTimes.asr;
  if (now.isBefore(prayerTimes.maghrib)) return prayerTimes.maghrib;
  if (now.isBefore(prayerTimes.isha)) return prayerTimes.isha;

  final tomorrow = now.add(const Duration(days: 1));
  final tomorrowTimes =
      PrayerTimes(coordinates, DateComponents.from(tomorrow), params);
  return tomorrowTimes.fajr;
}
