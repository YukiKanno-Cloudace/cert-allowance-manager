package com.example.qualification_allowance_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.content.Context
import android.util.Log
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import java.util.Calendar

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.qualification_allowance_app/notifications"
        private const val APP_PREFS = "AppPreferences"
        private const val NOTIFICATION_DATA_CLEARED = "notification_data_cleared_v2"
    }
    
    private var methodChannel: MethodChannel? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleNotification" -> {
                    val id = call.argument<Int>("id") ?: 0
                    val title = call.argument<String>("title") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    val scheduledTime = call.argument<Long>("scheduledTime") ?: 0L
                    
                    val success = scheduleNotification(id, title, message, scheduledTime)
                    result.success(success)
                }
                "cancelNotification" -> {
                    val id = call.argument<Int>("id") ?: 0
                    cancelNotification(id)
                    result.success(true)
                }
                "cancelAllNotifications" -> {
                    // 複数の通知IDをキャンセル
                    cancelNotification(1) // 給料日通知
                    cancelNotification(999) // テスト通知
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        clearNotificationDataOnce()
    }
    
    private fun scheduleNotification(id: Int, title: String, message: String, scheduledTime: Long): Boolean {
        return try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            val intent = Intent(this, NotificationReceiver::class.java).apply {
                putExtra(NotificationReceiver.NOTIFICATION_ID, id)
                putExtra(NotificationReceiver.NOTIFICATION_TITLE, title)
                putExtra(NotificationReceiver.NOTIFICATION_MESSAGE, message)
            }
            
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                id,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            )
            
            // Android 12以降は正確なアラームの権限確認が必要
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        scheduledTime,
                        pendingIntent
                    )
                } else {
                    // 権限がない場合は通常のアラーム
                    alarmManager.set(
                        AlarmManager.RTC_WAKEUP,
                        scheduledTime,
                        pendingIntent
                    )
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    scheduledTime,
                    pendingIntent
                )
            }
            
            Log.d("MainActivity", "通知をスケジュールしました: ID=$id, 時刻=$scheduledTime")
            true
        } catch (e: Exception) {
            Log.e("MainActivity", "通知のスケジュールに失敗: ${e.message}")
            false
        }
    }
    
    private fun cancelNotification(id: Int) {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(this, NotificationReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                id,
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_NO_CREATE
            )
            
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
                Log.d("MainActivity", "通知をキャンセルしました: ID=$id")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "通知のキャンセルに失敗: ${e.message}")
        }
    }
    
    private fun clearNotificationDataOnce() {
        try {
            val appPrefs = getSharedPreferences(APP_PREFS, Context.MODE_PRIVATE)
            val alreadyCleared = appPrefs.getBoolean(NOTIFICATION_DATA_CLEARED, false)
            
            if (!alreadyCleared) {
                Log.d("MainActivity", "初回起動：通知データをクリアします")
                
                val notificationPrefs = getSharedPreferences("FlutterLocalNotificationsPlugin", Context.MODE_PRIVATE)
                val editor = notificationPrefs.edit()
                editor.clear()
                editor.apply()
                
                appPrefs.edit().putBoolean(NOTIFICATION_DATA_CLEARED, true).apply()
                
                Log.d("MainActivity", "通知データをクリアしました")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "通知データのクリアに失敗: ${e.message}")
        }
    }
}
