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

  /// ================= INIT =================
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
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        FlutterBackgroundService().invoke("stopAdhan");
        print("🛑 تم الضغط على الإشعار وإيقاف الأذان");
      },
    );
  }

  /// ================= SCHEDULE =================
  /// daysOfWeek: الإثنين=1 ... الأحد=7
  Future<void> scheduledNotification({
  required List<int> daysOfWeek,
  required int hour,
  required int minute,
  required String title,
  required String body,
}) async {
  final now = tz.TZDateTime.now(tz.local);

  final box = await Hive.openBox("saved_notifications");

  /// ID واحد فقط للإشعار
  final int mainId =
      daysOfWeek.first * 100000 + hour * 100 + minute;

  /// أسماء الأيام
  final List<String> daysNames =
      daysOfWeek.map(_dayName).toList();

  /// 🔔 جدولة إشعار لكل يوم
  for (final day in daysOfWeek) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != day ||
        scheduledDate.isBefore(now)) {
      scheduledDate =
          scheduledDate.add(const Duration(days: 1));
    }

    /// ID مختلف لكل يوم (للنظام فقط)
    final int systemId =
        mainId + day;

    await notificationsPlugin.zonedSchedule(
      systemId,
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
      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// 💾 حفظ الإشعار مرة واحدة فقط
  await box.put(
    mainId,
    SavedNotification(
      id: mainId,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      days: daysNames,
    ).toMap(),
  );
}

  /// ================= CANCEL =================
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
    final box = await Hive.openBox("saved_notifications");
    await box.clear();
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
    final box = await Hive.openBox("saved_notifications");
    await box.delete(id);
  }

  /// ================= GET =================
  Future<List<SavedNotification>> getSavedNotifications() async {
    final box = await Hive.openBox("saved_notifications");
    return box.values
        .map((e) => SavedNotification.fromMap(e))
        .toList();
  }

  /// ================= UTILS =================
  String _dayName(int day) {
    switch (day) {
      case 1:
        return "الإثنين";
      case 2:
        return "الثلاثاء";
      case 3:
        return "الأربعاء";
      case 4:
        return "الخميس";
      case 5:
        return "الجمعة";
      case 6:
        return "السبت";
      case 7:
        return "الأحد";
      default:
        return "";
    }
  }
}
