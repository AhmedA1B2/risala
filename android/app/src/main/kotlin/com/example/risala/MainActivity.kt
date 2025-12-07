package com.example.risala

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.app.NotificationCompat

class MainActivity : FlutterActivity() {

    private val CHANNEL = "adhan_control"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "showAdhanNotification" -> {
                    showBasicNotification()
                    result.success(null)
                }

                "stopAdhan" -> {
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun showBasicNotification() {
        val channelId = "adhan_channel"
        val notificationManager =
            getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "إشعارات الأذان",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("إشعار")
            .setContentText("هذا إشعار عادي بدون تشغيل صوت")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(999, notification)
    }
}
