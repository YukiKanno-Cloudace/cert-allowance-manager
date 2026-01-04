/// 取得済み資格モデル
class AcquiredCert {
  final String? id; // データベースID（nullの場合は未保存）
  final String certId; // 資格マスターID
  final DateTime acquiredDate; // 取得日
  final DateTime expiryDate; // 有効期限日

  const AcquiredCert({
    this.id,
    required this.certId,
    required this.acquiredDate,
    required this.expiryDate,
  });

  /// 有効期限までの残り日数を計算
  int getDaysUntilExpiry() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final expiryStart = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiryStart.difference(todayStart).inDays;
  }

  /// 期限切れかどうか
  bool get isExpired => getDaysUntilExpiry() < 0;

  /// 更新が必要かどうか（90日以内または期限切れ）
  bool get needsRenewal => getDaysUntilExpiry() <= 90;

  /// 有効期限のステータスメッセージ（更新可能状態も含む）
  String getExpiryStatusMessage(int validYears) {
    final daysUntilExpiry = getDaysUntilExpiry();
    
    // 期限切れ
    if (daysUntilExpiry < 0) {
      return '${daysUntilExpiry.abs()}日超過（期限切れ）';
    }
    
    // 本日が期限
    if (daysUntilExpiry == 0) {
      return '本日が期限';
    }
    
    // 更新可能かチェック
    // Professional（2年）: 60日前から
    // Associate/Foundational（3年）: 180日前から
    final renewalDays = validYears >= 3 ? 180 : 60;
    final canRenew = daysUntilExpiry <= renewalDays;
    
    // 更新可能期間内
    if (canRenew) {
      return 'あと${daysUntilExpiry}日（更新可能）';
    }
    
    // 通常（更新可能期間外）
    return 'あと${daysUntilExpiry}日';
  }

  /// 更新可能かどうか（180日前または60日前から）
  bool canRenew(int validYears) {
    final daysUntilExpiry = getDaysUntilExpiry();
    final renewalDays = validYears >= 3 ? 180 : 60;
    return daysUntilExpiry <= renewalDays && daysUntilExpiry >= 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'certId': certId,
      'acquiredDate': acquiredDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
    };
  }

  factory AcquiredCert.fromMap(Map<String, dynamic> map) {
    return AcquiredCert(
      id: map['id']?.toString(),
      certId: map['certId'] as String,
      acquiredDate: DateTime.parse(map['acquiredDate'] as String),
      expiryDate: DateTime.parse(map['expiryDate'] as String),
    );
  }

  AcquiredCert copyWith({
    String? id,
    String? certId,
    DateTime? acquiredDate,
    DateTime? expiryDate,
  }) {
    return AcquiredCert(
      id: id ?? this.id,
      certId: certId ?? this.certId,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  String toString() {
    return 'AcquiredCert{id: $id, certId: $certId, acquiredDate: $acquiredDate, expiryDate: $expiryDate}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AcquiredCert &&
        other.id == id &&
        other.certId == certId &&
        other.acquiredDate == acquiredDate &&
        other.expiryDate == expiryDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, certId, acquiredDate, expiryDate);
  }
}

