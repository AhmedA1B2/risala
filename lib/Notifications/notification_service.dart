import 'dart:io';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:risala/Notifications/saved_notification.dart';
import 'package:risala/main.dart';
import 'package:risala/models/translation.dart';
import 'package:risala/translation/translation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance =
      NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = "weekly_channel_id";

  /// ================= INIT =================
  Future<void> init() async {
    tz.initializeTimeZones(); // تهيئة كافة المناطق

    // 1. جلب اسم المنطقة الخام من النظام (قد يحتوي على تفاصيل زائدة)
    String rawTimeZoneName = "${await FlutterTimezone.getLocalTimezone()}";
    String cleanTimeZoneName = 'Africa/Tripoli'; // قيمة افتراضية

    // 2. تنظيف النص لاستخراج الاسم القياسي (مثل Africa/Tripoli)
    // هذا التعبير النمطي يبحث عن أي نص بصيغة "قارة/مدينة"
    final RegExp regex = RegExp(r'([A-Za-z]+(?:\/[A-Za-z_-]+)+)');
    final match = regex.firstMatch(rawTimeZoneName);

    if (match != null) {
      cleanTimeZoneName = match.group(1)!;
    }

    // 3. تعيين الموقع باستخدام الاسم الصافي داخل كتل try-catch للحماية
    try {
      tz.setLocalLocation(tz.getLocation(cleanTimeZoneName));
    } catch (e) {
      print("فشل تعيين المنطقة الزمنية: $e");
      tz.setLocalLocation(tz.getLocation('Africa/Tripoli'));
    }

    // 4. إعدادات الإشعارات
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
      },
    );

    // 5. إنشاء القناة وطلب الصلاحيات للأندرويد
    if (Platform.isAndroid) {
      final androidPlugin =
          notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          channelId,
          'Weekly Notifications',
          description: 'Weekly scheduled notifications',
          importance: Importance.max,
        );
        await androidPlugin.createNotificationChannel(channel);
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }

      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    }
  }

  /// ================= SCHEDULE =================
  Future<void> scheduledNotification({
    required List<int> daysOfWeek,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final box = await Hive.openBox("saved_notifications");

    // استبدل دالة _generateId بهذا السطر داخل دالة الإدولة:
    final int mainId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final List<String> daysNames = daysOfWeek.map(_dayName).toList();

    for (final day in daysOfWeek) {
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

      final int systemId = mainId + day;

      await notificationsPlugin.zonedSchedule(
        systemId,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Weekly Notifications',
            channelDescription: 'Weekly scheduled notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

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
    for (int i = 1; i <= 7; i++) {
      await notificationsPlugin.cancel(id + i);
    }
    final box = await Hive.openBox("saved_notifications");
    await box.delete(id);
  }

  /// ================= GET =================
  Future<List<SavedNotification>> getSavedNotifications() async {
    final box = await Hive.openBox("saved_notifications");
    return box.values.map((e) => SavedNotification.fromMap(e)).toList();
  }

  /// ================= TRANSLATION =================
  Translation? translation;
  bool _isTranslationLoaded = false;

  Future<void> loadAllTranslations() async {
    final list =
        await loadTranslation(sharedPref.getString("selectedValue") ?? "ar");
    if (list.isNotEmpty) {
      translation = list.first;
      _isTranslationLoaded = true;
    }
  }

  /// ================= UTILS =================
  String _dayName(int day) {
    const fallback = [
      "الإثنين",
      "الثلاثاء",
      "الأربعاء",
      "الخميس",
      "الجمعة",
      "السبت",
      "الأحد"
    ];

    if (!_isTranslationLoaded || translation == null) {
      return fallback[day - 1];
    }

    switch (day) {
      case 1:
        return translation!.monday;
      case 2:
        return translation!.tuesday;
      case 3:
        return translation!.wednesday;
      case 4:
        return translation!.thursday;
      case 5:
        return translation!.friday;
      case 6:
        return translation!.saturday;
      case 7:
        return translation!.sunday;
      default:
        return "";
    }
  }
}
