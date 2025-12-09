import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:risala/Notifications/notification_service.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart';

class NotificationHome extends StatefulWidget {
  const NotificationHome({super.key});

  @override
  State<NotificationHome> createState() => _NotificationHomeState();
}

class _NotificationHomeState extends State<NotificationHome> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    initializeTimeZones();
    setLocalLocation(
      getLocation('Africa/Cairo'),
    );
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettinhs =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettinhs,
    );
    await notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notification_channel_id',
          'Instant Notifications',
          channelDescription: 'Instant notification channel',
          importance: Importance.max,
          priority: Priority.high,
        ), // AndroidNotificationDetails
        iOS: DarwinNotificationDetails(),
      ), // NotificationDetails
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    String? body,
  }) async {
    TZDateTime now = TZDateTime.now(local);
    TZDateTime scheduledDate = now.add(
      const Duration(seconds: 1),
    );
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel_id', // A unique ID to group notifications together.
          'Daily Reminders', // A human-readable name shown to users in their notification settings.
          channelDescription: 'Reminder to complete daily habits',
          importance: Importance.max,
          priority: Priority.high,
        ), // AndroidNotificationDetails
        iOS: DarwinNotificationDetails(),
      ), // NotificationDetails
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime, // or dateAndTime
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                showInstantNotification(
                    id: 0,
                    title: "showInstantNotification",
                    body: "dwkb f ufyw fuyvre fuyerf eruyferf");
              },
              child: const Center(
                child: Text(
                  "showInstantNotification",
                ),
              )),
          TextButton(
              onPressed: () {
                NotificationService.instance.scheduledNotification(
                  title: "title",
                  body: "body",
                  hour: 14,
                  minute: 38,
                  daysOfWeek: [1, 4, 5],
                );
              },
              child: const Center(
                child: Text(
                  "scheduleReminder",
                ),
              ))
        ],
      ),
    );
  }
}
