import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

/// 通知設定プロバイダー
class NotificationProvider extends ChangeNotifier {
  static const String _settingsKey = 'notification_settings';

  NotificationSettings _settings = const NotificationSettings();
  final NotificationService _notificationService = NotificationService();
  bool _isInitialized = false;

  NotificationSettings get settings => _settings;
  bool get isInitialized => _isInitialized;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // タイムアウトを設定（3秒）
      await _notificationService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('通知サービスの初期化がタイムアウトしました（続行）');
        },
      );
    } catch (e) {
      debugPrint('通知サービスの初期化に失敗: $e');
    }
    
    await _loadSettings();
    _isInitialized = true;
    notifyListeners();
  }

  /// 設定を読み込み
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        _settings = NotificationSettings.fromMap(map);
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  /// 設定を保存
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = json.encode(_settings.toMap());
      await prefs.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  /// 給料日通知の有効/無効を切り替え
  Future<void> toggleSalaryDayNotification(bool enabled, int totalAllowance) async {
    debugPrint('🔔 toggleSalaryDayNotification called: enabled=$enabled, totalAllowance=$totalAllowance');
    debugPrint('🔔 Current settings before: ${_settings.toMap()}');
    
    try {
      _settings = _settings.copyWith(salaryDayNotificationEnabled: enabled);
      debugPrint('🔔 Settings after copyWith: ${_settings.toMap()}');
      
      await _saveSettings();
      debugPrint('🔔 Settings saved');

      if (enabled) {
        debugPrint('🔔 Scheduling salary day notification...');
        await _notificationService.scheduleSalaryDayNotification(
          _settings.salaryDay,
          totalAllowance,
        );
        debugPrint('🔔 Salary day notification scheduled successfully');
      } else {
        debugPrint('🔔 Canceling salary day notification...');
        await _notificationService.cancelSalaryDayNotification();
        debugPrint('🔔 Salary day notification canceled');
      }
    } catch (e) {
      debugPrint('❌ Error in toggleSalaryDayNotification: $e');
      // エラーが発生しても状態は更新する
    }

    debugPrint('🔔 Calling notifyListeners()');
    notifyListeners();
    debugPrint('🔔 toggleSalaryDayNotification completed');
  }

  /// 給料日を設定
  Future<void> setSalaryDay(int day, int totalAllowance) async {
    if (day < 1 || day > 31) return;

    _settings = _settings.copyWith(salaryDay: day);
    await _saveSettings();

    // 通知が有効な場合は再スケジュール
    if (_settings.salaryDayNotificationEnabled) {
      await _notificationService.scheduleSalaryDayNotification(
        day,
        totalAllowance,
      );
    }

    notifyListeners();
  }

  /// 資格更新通知の有効/無効を切り替え
  Future<void> toggleRenewalNotification(bool enabled) async {
    debugPrint('📝 toggleRenewalNotification called: enabled=$enabled');
    debugPrint('📝 Current settings before: ${_settings.toMap()}');
    
    _settings = _settings.copyWith(renewalNotificationEnabled: enabled);
    debugPrint('📝 Settings after copyWith: ${_settings.toMap()}');
    
    await _saveSettings();
    debugPrint('📝 Settings saved');
    
    notifyListeners();
    debugPrint('📝 toggleRenewalNotification completed');
  }

  /// カスタム催促通知の有効/無効を切り替え
  Future<void> toggleCustomReminder(bool enabled) async {
    debugPrint('⏰ toggleCustomReminder called: enabled=$enabled');
    debugPrint('⏰ Current settings before: ${_settings.toMap()}');
    
    _settings = _settings.copyWith(customReminderEnabled: enabled);
    debugPrint('⏰ Settings after copyWith: ${_settings.toMap()}');
    
    await _saveSettings();
    debugPrint('⏰ Settings saved');
    
    notifyListeners();
    debugPrint('⏰ toggleCustomReminder completed');
  }

  /// 通知許可をリクエスト
  Future<bool> requestPermission() async {
    return await _notificationService.requestPermission();
  }

  /// テスト通知を表示
  Future<void> showTestNotification() async {
    await _notificationService.showTestNotification();
  }

  /// 1分後に通知をスケジュール（バックグラウンドテスト用）
  Future<void> scheduleTestNotificationInOneMinute() async {
    await _notificationService.scheduleTestNotificationInOneMinute();
  }

  /// 給料日通知をテスト（1分後）
  Future<void> testSalaryDayNotification(int totalAllowance) async {
    await _notificationService.testSalaryDayNotification(totalAllowance);
  }

  /// 資格更新通知をテスト（1分後）
  Future<void> testRenewalNotification() async {
    await _notificationService.testRenewalNotification();
  }

  /// 資格更新通知をスケジュール
  Future<void> scheduleRenewalNotification(
    String certId,
    String certName,
    DateTime renewalDate,
  ) async {
    if (!_settings.renewalNotificationEnabled) return;

    await _notificationService.scheduleRenewalNotifications(
      certId,
      certName,
      renewalDate,
    );
  }

  /// カスタム催促通知をスケジュール
  Future<void> scheduleCustomReminder({
    required String certId,
    required String certName,
    required DateTime reminderDate,
  }) async {
    debugPrint('⏰ scheduleCustomReminder called');
    
    // カスタム催促通知が無効でもこの関数は常に動作する
    // （ユーザーが個別にリマインダーを設定した場合は常に有効）
    
    final message = '「$certName」の更新期限が近づいています';
    await _notificationService.scheduleCustomReminder(
      certId,
      certName,
      reminderDate,
      message,
    );
    
    debugPrint('⏰ scheduleCustomReminder completed');
  }

  /// すべての通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}

