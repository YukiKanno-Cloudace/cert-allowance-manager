/// 通知設定モデル
class NotificationSettings {
  final bool salaryDayNotificationEnabled;
  final int salaryDay; // 給料日（1-31）
  final bool renewalNotificationEnabled;
  final bool customReminderEnabled;

  const NotificationSettings({
    this.salaryDayNotificationEnabled = false,
    this.salaryDay = 25,
    this.renewalNotificationEnabled = false,
    this.customReminderEnabled = false,
  });

  NotificationSettings copyWith({
    bool? salaryDayNotificationEnabled,
    int? salaryDay,
    bool? renewalNotificationEnabled,
    bool? customReminderEnabled,
  }) {
    return NotificationSettings(
      salaryDayNotificationEnabled:
          salaryDayNotificationEnabled ?? this.salaryDayNotificationEnabled,
      salaryDay: salaryDay ?? this.salaryDay,
      renewalNotificationEnabled:
          renewalNotificationEnabled ?? this.renewalNotificationEnabled,
      customReminderEnabled:
          customReminderEnabled ?? this.customReminderEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'salaryDayNotificationEnabled': salaryDayNotificationEnabled,
      'salaryDay': salaryDay,
      'renewalNotificationEnabled': renewalNotificationEnabled,
      'customReminderEnabled': customReminderEnabled,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      salaryDayNotificationEnabled: map['salaryDayNotificationEnabled'] ?? false,
      salaryDay: map['salaryDay'] ?? 25,
      renewalNotificationEnabled: map['renewalNotificationEnabled'] ?? false,
      customReminderEnabled: map['customReminderEnabled'] ?? false,
    );
  }
}

