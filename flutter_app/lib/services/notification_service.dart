import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

/// 通知サービス
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// 初期化
  Future<void> initialize() async {
    if (_initialized) return;

    // タイムゾーンデータの初期化
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));

    // Android設定
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS設定
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 初期化設定
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// 通知がタップされた時の処理
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // TODO: 必要に応じて画面遷移などの処理を追加
  }

  /// 通知許可をリクエスト
  Future<bool> requestPermission() async {
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
    }
    return true;
  }

  /// 即座に通知を表示（テスト用）
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'テスト通知',
      channelDescription: 'テスト用の通知チャンネル',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'テスト通知',
      '通知機能が正常に動作しています',
      details,
    );
  }

  /// 1分後にテスト通知をスケジュール
  Future<void> scheduleTestNotificationInOneMinute() async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'テスト通知',
      channelDescription: 'テスト用の通知チャンネル',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      999, // テスト通知用のID
      '⏰ テスト通知',
      'バックグラウンド通知が正常に動作しています',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Test notification scheduled for $scheduledDate');
  }

  /// 給料日通知のテスト（1分後）
  Future<void> testSalaryDayNotification(int totalAllowance) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'salary_day_channel',
      '給料日通知',
      channelDescription: '毎月の給料日に資格手当額を通知します',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      998, // テスト用のID
      '💰 今月の資格手当（テスト）',
      '資格手当: ¥${_formatNumber(totalAllowance)}',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Test salary day notification scheduled for $scheduledDate');
  }

  /// 資格更新通知のテスト（1分後）
  Future<void> testRenewalNotification() async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'renewal_channel',
      '資格更新通知',
      channelDescription: '資格の更新可能日を通知します',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      997, // テスト用のID
      '📝 資格更新可能（テスト）',
      'テスト資格の更新が可能になりました',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Test renewal notification scheduled for $scheduledDate');
  }

  /// 給料日通知をスケジュール
  Future<void> scheduleSalaryDayNotification(int day, int totalAllowance) async {
    final tz.TZDateTime scheduledDate = _nextInstanceOfDay(day, hour: 9);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'salary_day_channel',
      '給料日通知',
      channelDescription: '毎月の給料日に資格手当額を通知します',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
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
    );

    debugPrint('Salary day notification scheduled for day $day at 9:00 AM');
  }

  /// 資格更新可能日通知をスケジュール
  Future<void> scheduleRenewalNotifications(
    String certId,
    String certName,
    DateTime renewalDate,
  ) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(renewalDate, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'renewal_channel',
      '資格更新通知',
      channelDescription: '資格の更新可能日を通知します',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
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

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
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
    await _notifications.cancel(1);
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

    return scheduledDate;
  }

  /// 数値をフォーマット
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

