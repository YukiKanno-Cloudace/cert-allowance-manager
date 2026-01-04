package com.example.qualification_allowance_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import android.util.Log

class NotificationReceiver : BroadcastReceiver() {
    companion object {
        const val NOTIFICATION_ID = "notification_id"
        const val NOTIFICATION_TITLE = "notification_title"
        const val NOTIFICATION_MESSAGE = "notification_message"
        const val CHANNEL_ID = "qualification_allowance_channel"
        const val CHANNEL_NAME = "資格手当通知"
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("NotificationReceiver", "通知を受信しました")
        
        val notificationId = intent.getIntExtra(NOTIFICATION_ID, 0)
        val title = intent.getStringExtra(NOTIFICATION_TITLE) ?: "資格手当アプリ"
        val message = intent.getStringExtra(NOTIFICATION_MESSAGE) ?: "通知"
        
        showNotification(context, notificationId, title, message)
    }
    
    private fun showNotification(context: Context, id: Int, title: String, message: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // 通知チャンネルの作成（Android 8.0以降）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "資格手当と更新期限の通知"
                enableVibration(true)
                enableLights(true)
                setSound(
                    android.provider.Settings.System.DEFAULT_NOTIFICATION_URI,
                    android.media.AudioAttributes.Builder()
                        .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION)
                        .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
            }
            notificationManager.createNotificationChannel(channel)
        }
        
        // アプリを開くIntent
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // 通知の作成
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(message)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL) // サウンド、バイブレーション、ライトのデフォルト設定
            .setSound(android.provider.Settings.System.DEFAULT_NOTIFICATION_URI) // 通知音
            .build()
        
        notificationManager.notify(id, notification)
        Log.d("NotificationReceiver", "通知を表示しました: $title - $message")
    }
}

