import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHome extends StatefulWidget {
  const NotificationHome({super.key});

  @override
  _NotificationHomeState createState() => _NotificationHomeState();
}

class _NotificationHomeState extends State<NotificationHome> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  // تهيئة الإشعارات للأندرويد
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  // طلب صلاحية أندرويد 13
  Future<void> _requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // دالة إرسال الإشعار
  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'اسم القناة',
      channelDescription: 'وصف القناة للإشعارات',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      id: 0,
      title: 'مرحباً بك!',
      body: 'هذا إشعار تجريبي مخصص لأندرويد 13 🚀',
      notificationDetails: platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إشعارات أندرويد 13')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_active,
                size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('طلب صلاحية الإشعارات'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showNotification,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('إرسال إشعار الآن',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
