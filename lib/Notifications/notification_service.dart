import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:risala/Notifications/saved_notification.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

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

  /// جدولة إشعار حسب أيام الأسبوع
  /// [daysOfWeek] أيام الأسبوع: الإثنين=1 ... الأحد=7
  Future<void> scheduledNotification({
    required List<int> daysOfWeek,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    for (var day in daysOfWeek) {
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      int id = day * 10000 + hour * 100 + minute;

      // جدولة الإشعار
      await notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_channel_id',
            'Weekly Notifications',
            channelDescription: 'Weekly scheduled notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      List<String> daysOfWeekToString = [];

      for (int day in daysOfWeek) {
        switch (day) {
          case 1:
            daysOfWeekToString.add("الإثنين");
            break;
          case 2:
            daysOfWeekToString.add("الثلاثاء");
            break;
          case 3:
            daysOfWeekToString.add("الأربعاء");
            break;
          case 4:
            daysOfWeekToString.add("الخميس");
            break;
          case 5:
            daysOfWeekToString.add("الجمعة");
            break;
          case 6:
            daysOfWeekToString.add("السبت");
            break;
          case 7:
            daysOfWeekToString.add("الأحد");
            break;
        }
      }

      int idOfHive = now.year +
          now.month +
          now.day +
          hour +
          minute +
          now.minute +
          now.second +
          now.millisecond * body.length +
          title.length +
          daysOfWeek.length;

      // حفظ الإشعار في Hive
      final box = await Hive.openBox("saved_notifications");
      await box.put(
          idOfHive,
          SavedNotification(
            id: idOfHive,
            title: title,
            body: body,
            hour: hour,
            minute: minute,
            days: daysOfWeekToString,
          ).toMap());
    }
  }

  /// حذف كل الإشعارات
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();

    final box = await Hive.openBox("saved_notifications");
    await box.clear();
  }

  Future<void> cancelNotifications(int id) async {
    await notificationsPlugin.cancel(id);
    final box = await Hive.openBox("saved_notifications");
    await box.delete(id);
  }

  Future<List<SavedNotification>> getSavedNotifications() async {
    final box = await Hive.openBox("saved_notifications");

    return box.values.map((data) => SavedNotification.fromMap(data)).toList();
  }
}
