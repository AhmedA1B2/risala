import 'package:flutter/material.dart';
import 'package:risala/main.dart';
import 'package:risala/main_view/main_view.dart';
import 'package:risala/vars/colors.dart';
import 'package:risala/vars/texts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:risala/Notifications/notification_service.dart';

class CustomSplashScreen1 extends StatefulWidget {
  const CustomSplashScreen1({super.key});

  @override
  State<CustomSplashScreen1> createState() => _CustomSplashScreen1State();
}

class _CustomSplashScreen1State extends State<CustomSplashScreen1> {
  double heightofContainer = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices();
    });

    _reloadFontSettings();
    _startAnimation();
    _goToMain();
  }

  Future<void> _initServices() async {
    try {
      await WakelockPlus.enable();
      await NotificationService.instance.init();
    } catch (e) {
      debugPrint("wakelock error: $e");
    }
  }

  // ========================

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        heightofContainer = 60;
      });
    });
  }

  void _goToMain() {
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainView()),
      );
    });
  }

  void _reloadFontSettings() {
    quranfontSize = sharedPref.getDouble("valueOfSize2") ?? 36;
    mytitlefontSize = sharedPref.getDouble("valueOfSize") ?? 26;
    quranfontFamily = sharedPref.getString("selectedValue2") ?? "Amiri";
  }
  // ========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Image.asset("assets/images/mosq_splash.gif"),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: heightofContainer,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              color: scandColor,
            ),
            child: Text(
              "السلام عليكم ورحمة الله",
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Amiri',
                color: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
