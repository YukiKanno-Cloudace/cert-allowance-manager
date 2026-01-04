import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 通知サービス
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  // AndroidネイティブとのMethodChannel
  static const MethodChannel _channel =
      MethodChannel('com.example.qualification_allowance_app/notifications');

  bool _initialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // タイムゾーンデータの初期化
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

      // Android設定
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS/macOS設定
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 初期化設定
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      // macOSの場合はタイムアウトを短く設定
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        await _notifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        ).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('macOS通知初期化タイムアウト（スキップ）');
            return null;
          },
        );
      } else {
        await _notifications.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );
      }

      _initialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
      _initialized = true; // エラーでも続行
    }
  }

  /// 通知がタップされた時の処理
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: 必要に応じて画面遷移などの処理を追加
  }

  /// 通知許可をリクエスト
  Future<bool> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final bool? granted = await androidImplementation?.requestNotificationsPermission();
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return granted ?? false;
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        debugPrint('macOS通知許可: $granted');
        return granted ?? false;
      }
      // その他のプラットフォーム（Linux, Windows等）
      return true;
    } catch (e) {
      debugPrint('通知許可のリクエストに失敗: $e');
      return false;
    }
  }

  /// 即座に通知を表示（テスト用）
  Future<void> showTestNotification() async {
    if (!_initialized) {
      debugPrint('通知サービスが初期化されていません');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'test_channel',
        'テスト通知',
        channelDescription: 'テスト用の通知チャンネル',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _notifications.show(
        0,
        '🔔 テスト通知',
        '通知機能が正常に動作しています',
        details,
      );
      debugPrint('テスト通知を送信しました');
    } catch (e) {
      debugPrint('テスト通知の送信に失敗: $e');
    }
  }

  /// 1分後に通知をスケジュール（バックグラウンドテスト用）
  Future<void> scheduleTestNotificationInOneMinute() async {
    if (!_initialized) {
      debugPrint('通知サービスが初期化されていません');
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android: MethodChannelを使用
        debugPrint('Android: ネイティブ通知を使用します');
        final scheduledTime = DateTime.now().add(const Duration(minutes: 1)).millisecondsSinceEpoch;
        
        final result = await _channel.invokeMethod('scheduleNotification', {
          'id': 999,
          'title': '🔔 バックグラウンド通知テスト',
          'message': 'アプリを閉じていても通知が届きました！',
          'scheduledTime': scheduledTime,
        });
        
        debugPrint('Android通知をスケジュールしました: $result');
      } else {
        // iOS/macOS: flutter_local_notificationsを使用
        debugPrint('iOS/macOS: flutter_local_notificationsを使用します');
        
        try {
          await _notifications.cancel(999);
        } catch (e) {
          debugPrint('既存テスト通知のキャンセルに失敗（無視して続行）: $e');
        }
        
        final tz.TZDateTime scheduledDate = 
            tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

        const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails details = NotificationDetails(
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _notifications.zonedSchedule(
          999,
          '🔔 バックグラウンド通知テスト',
          'アプリを閉じていても通知が届きました！',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'test_background',
        );
        
        debugPrint('1分後の通知をスケジュールしました: $scheduledDate');
      }
    } catch (e) {
      debugPrint('スケジュール通知の設定に失敗: $e');
      rethrow;
    }
  }

  /// 給料日通知をスケジュール
  Future<void> scheduleSalaryDayNotification(int day, int totalAllowance) async {
    try {
      await cancelSalaryDayNotification();
    } catch (e) {
      debugPrint('既存通知のキャンセルに失敗（無視して続行）: $e');
    }
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android: MethodChannelを使用
      final scheduledDate = _nextInstanceOfDayAsDateTime(day, hour: 9);
      final scheduledTime = scheduledDate.millisecondsSinceEpoch;
      
      await _channel.invokeMethod('scheduleNotification', {
        'id': 1,
        'title': '💰 今月の資格手当',
        'message': '資格手当: ¥${_formatNumber(totalAllowance)}',
        'scheduledTime': scheduledTime,
      });
      
      debugPrint('Android給料日通知をスケジュールしました');
      return;
    }
    
    // iOS/macOS: flutter_local_notificationsを使用
    final tz.TZDateTime scheduledDate = _nextInstanceOfDay(day, hour: 9);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'salary_day_channel',
      '給料日通知',
      channelDescription: '毎月の給料日に資格手当額を通知します',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      1, // 通知ID
      '💰 今月の資格手当',
      '資格手当: ¥${_formatNumber(totalAllowance)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'salary_day',
    );

    debugPrint('Salary day notification scheduled for day $day at 9:00 AM');
  }

  /// 資格更新可能日通知をスケジュール
  Future<void> scheduleRenewalNotifications(
    String certId,
    String certName,
    DateTime renewalDate,
  ) async {
    // 既存の更新通知をキャンセル（エラーは無視）
    try {
      await cancelRenewalNotification(certId);
    } catch (e) {
      debugPrint('既存更新通知のキャンセルに失敗（無視して続行）: $e');
    }
    
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(renewalDate, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'renewal_channel',
      '資格更新通知',
      channelDescription: '資格の更新可能日を通知します',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // 通知IDはcertIdのハッシュコードを使用（一意性を保証）
    final int notificationId = 1000 + certId.hashCode.abs() % 9000;

    await _notifications.zonedSchedule(
      notificationId,
      '📝 資格更新可能',
      '$certName の更新が可能になりました',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'renewal:$certId',
    );

    debugPrint('Renewal notification scheduled for $certName at $scheduledDate');
  }

  /// カスタム催促通知をスケジュール
  Future<void> scheduleCustomReminder(
    String certId,
    String certName,
    DateTime reminderDate,
    String message,
  ) async {
    // 既存のカスタムリマインダーをキャンセル（エラーは無視）
    try {
      await cancelCustomReminder(certId);
    } catch (e) {
      debugPrint('既存カスタム通知のキャンセルに失敗（無視して続行）: $e');
    }
    
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    // 過去の日時の場合はスケジュールしない
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('Cannot schedule reminder in the past');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'custom_reminder_channel',
      'カスタム催促通知',
      channelDescription: 'ユーザーが設定した催促通知',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // 通知IDはcertIdのハッシュコード + 10000を使用
    final int notificationId = 10000 + certId.hashCode.abs() % 9000;

    await _notifications.zonedSchedule(
      notificationId,
      '⏰ 資格更新の催促',
      '$certName - $message',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'custom_reminder:$certId',
    );

    debugPrint('Custom reminder scheduled for $certName at $scheduledDate');
  }

  /// 特定の通知をキャンセル
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 給料日通知をキャンセル
  Future<void> cancelSalaryDayNotification() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _channel.invokeMethod('cancelNotification', {'id': 1});
    } else {
      await _notifications.cancel(1);
    }
  }

  /// 資格の更新通知をキャンセル
  Future<void> cancelRenewalNotification(String certId) async {
    final int notificationId = 1000 + certId.hashCode.abs() % 9000;
    await _notifications.cancel(notificationId);
  }

  /// カスタム催促通知をキャンセル
  Future<void> cancelCustomReminder(String certId) async {
    final int notificationId = 10000 + certId.hashCode.abs() % 9000;
    await _notifications.cancel(notificationId);
  }

  /// 次の指定日時を計算
  tz.TZDateTime _nextInstanceOfDay(int day, {int hour = 9, int minute = 0}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, day, hour, minute);

    // 今月の指定日が過ぎている場合は来月に設定
    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        day,
        hour,
        minute,
      );
    }

    // 土日の場合は前の金曜日に調整
    scheduledDate = _adjustToWeekday(scheduledDate);

    return scheduledDate;
  }
  
  /// 次の指定日時を計算（DateTime版、Android用）
  DateTime _nextInstanceOfDayAsDateTime(int day, {int hour = 9, int minute = 0}) {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, day, hour, minute);

    // 今月の指定日が過ぎている場合は来月に設定
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        day,
        hour,
        minute,
      );
    }

    // 土日の場合は前の金曜日に調整
    if (scheduledDate.weekday == DateTime.saturday) {
      scheduledDate = scheduledDate.subtract(const Duration(days: 1));
    } else if (scheduledDate.weekday == DateTime.sunday) {
      scheduledDate = scheduledDate.subtract(const Duration(days: 2));
    }

    return scheduledDate;
  }

  /// 土日の場合は前の金曜日に調整
  tz.TZDateTime _adjustToWeekday(tz.TZDateTime date) {
    // 土曜日(6)の場合は-1日、日曜日(7)の場合は-2日
    if (date.weekday == DateTime.saturday) {
      return date.subtract(const Duration(days: 1));
    } else if (date.weekday == DateTime.sunday) {
      return date.subtract(const Duration(days: 2));
    }
    return date;
  }

  /// 数値をフォーマット
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// 給料日通知をテスト（1分後に送信）
  Future<void> testSalaryDayNotification(int totalAllowance) async {
    if (!_initialized) {
      debugPrint('通知サービスが初期化されていません');
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final scheduledTime = DateTime.now().add(const Duration(minutes: 1)).millisecondsSinceEpoch;
        
        await _channel.invokeMethod('scheduleNotification', {
          'id': 1001, // テスト用の異なるID
          'title': '💰 今月の資格手当',
          'message': '資格手当: ¥${_formatNumber(totalAllowance)}',
          'scheduledTime': scheduledTime,
        });
        
        debugPrint('給料日通知テストをスケジュールしました');
      } else {
        final tz.TZDateTime scheduledDate = 
            tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

        const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails details = NotificationDetails(
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _notifications.zonedSchedule(
          1001,
          '💰 今月の資格手当',
          '資格手当: ¥${_formatNumber(totalAllowance)}',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'test_salary',
        );
        
        debugPrint('給料日通知テストをスケジュールしました: $scheduledDate');
      }
    } catch (e) {
      debugPrint('給料日通知テストの設定に失敗: $e');
      rethrow;
    }
  }

  /// 資格更新通知をテスト（1分後に送信）
  Future<void> testRenewalNotification() async {
    if (!_initialized) {
      debugPrint('通知サービスが初期化されていません');
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final scheduledTime = DateTime.now().add(const Duration(minutes: 1)).millisecondsSinceEpoch;
        
        await _channel.invokeMethod('scheduleNotification', {
          'id': 1002, // テスト用の異なるID
          'title': '📝 資格更新可能',
          'message': 'Professional Cloud Architect の更新が可能になりました',
          'scheduledTime': scheduledTime,
        });
        
        debugPrint('資格更新通知テストをスケジュールしました');
      } else {
        final tz.TZDateTime scheduledDate = 
            tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

        const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails details = NotificationDetails(
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        await _notifications.zonedSchedule(
          1002,
          '📝 資格更新可能',
          'Professional Cloud Architect の更新が可能になりました',
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'test_renewal',
        );
        
        debugPrint('資格更新通知テストをスケジュールしました: $scheduledDate');
      }
    } catch (e) {
      debugPrint('資格更新通知テストの設定に失敗: $e');
      rethrow;
    }
  }
}

