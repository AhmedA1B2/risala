import 'package:flutter/material.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:risala/custom/custom_splash_screen/custom_splash_screen1.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة إشعارات الأذان
  await NotificationService.instance.init();

  sharedPref = await SharedPreferences.getInstance();
  await WakelockPlus.enable();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // bool adhanPlayed = sharedPref.getBool("adhanPlayed") ?? false;
    // adhanPlayed ? const MoadhnView() :
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomSplashScreen1(),
    );
  }
}
