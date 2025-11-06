import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

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

  Future<void> showAdhanNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'adhan_channel',
      'إشعارات الأذان',
      channelDescription: 'إشعار عند وقت الأذان',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails, iOS: DarwinNotificationDetails());

    await notificationsPlugin.show(id, title, body, platformDetails);
  }
}
