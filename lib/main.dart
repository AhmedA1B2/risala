import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:risala/custom/custom_splash_screen/custom_splash_screen1.dart';

late SharedPreferences sharedPref;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الأشياء الآمنة فقط هنا
  await Hive.initFlutter();
  await Hive.openBox("saved_notifications");
  await NotificationService.instance.init();
  sharedPref = await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // bool adhanPlayed = sharedPref.getBool("adhanPlayed") ?? false;
    // adhanPlayed ? const MoadhnView() :
    return const MaterialApp(
      //debugShowCheckedModeBanner: false,
      home: CustomSplashScreen1(),
    );
  }
}
//flutter run --release
