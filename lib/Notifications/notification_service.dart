import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    initializeTimeZones();
    setLocalLocation(getLocation('Africa/Cairo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // عند الضغط على الإشعار لإيقاف الأذان
        final service = FlutterBackgroundService();
        service.invoke("stopAdhan");
        print("🛑 المستخدم ضغط على الإشعار لإيقاف الأذان");
      },
    );
  }

  Future<void> showAdhanNotification() async {
    const platform = MethodChannel("adhan_control");
    await platform.invokeMethod("showAdhanNotification");
  }

  void listenFromAndroid() {
    const platform = MethodChannel("adhan_control");

    platform.setMethodCallHandler((call) async {
      if (call.method == "stopAdhan") {
        print("🛑 Android طلب إيقاف الأذان");
        final service = FlutterBackgroundService();
        service.invoke("stopAdhan");
      }
    });
  }
}
