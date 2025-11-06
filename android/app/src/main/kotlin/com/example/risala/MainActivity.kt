package com.example.risala

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter_background_service"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "showAdhanNotification" -> {
                    showAdhanNotification()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // تسجيل المستمع لزر "إيقاف الأذان"
        val filter = IntentFilter("STOP_ADHAN_ACTION")
        registerReceiver(stopAdhanReceiver, filter)
    }

    private val stopAdhanReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            methodChannel?.invokeMethod("stopAdhan", null)
        }
    }

    private fun showAdhanNotification() {
        val channelId = "adhan_channel"
        val notificationId = 555
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // إنشاء قناة الإشعارات إن لم تكن موجودة
        val channel = NotificationChannel(
            channelId,
            "قناة الأذان",
            NotificationManager.IMPORTANCE_HIGH
        )
        nm.createNotificationChannel(channel)

        // إنشاء PendingIntent لزر الإيقاف
        val stopIntent = Intent("STOP_ADHAN_ACTION")
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // إنشاء الإشعار
        val notification = Notification.Builder(this, channelId)
            .setContentTitle("🕌 وقت الأذان الآن")
            .setContentText("اضغط لإيقاف الأذان 🔇")
            .setSmallIcon(android.R.drawable.ic_lock_silent_mode)
            .addAction(android.R.drawable.ic_media_pause, "إيقاف الأذان", stopPendingIntent)
            .setOngoing(true) // يبقى الإشعار حتى توقف الأذان
            .build()

        nm.notify(notificationId, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(stopAdhanReceiver)
    }
}
