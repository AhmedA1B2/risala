import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:risala/my_views/adhan/adhan_view/adhan_view.dart';
import 'package:risala/my_views/adhan/background_service/background_service.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:risala/custom/custom_splash_screen/custom_splash_screen1.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة إشعارات الأذان
  await NotificationService.instance.init();

  // تهيئة الصوت في الخلفية
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.risala.channel.audio',
    androidNotificationChannelName: 'Adhan Audio',
    androidNotificationOngoing: true,
  );

  sharedPref = await SharedPreferences.getInstance();

  // منع الجهاز من النوم أثناء الأذان
  await WakelockPlus.enable();

  // تشغيل خدمة الأذان في الخلفية
  await initializeService();

  // تشغيل التطبيق
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool adhanPlayed = sharedPref.getBool("adhanPlayed") ?? false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: adhanPlayed ? const MoadhnView() : const CustomSplashScreen1(),
    );
  }
}
