import 'package:flutter/foundation.dart';
import '../models/acquired_cert.dart';
import '../services/storage_service.dart';
import '../constants/certification_data.dart';

/// フィルタータイプ
enum CertFilter { all, expiring, valid }

/// 資格データプロバイダー
class CertProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<AcquiredCert> _acquiredCerts = [];
  CertFilter _currentFilter = CertFilter.all;
  bool _isLoading = false;

  List<AcquiredCert> get acquiredCerts => _acquiredCerts;
  CertFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;

  /// 初期化
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await loadAcquiredCerts();
    } catch (e) {
      debugPrint('Error initializing: $e');
      _acquiredCerts = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// 取得済み資格を読み込み
  Future<void> loadAcquiredCerts() async {
    try {
      final certs = await _storageService.getAllAcquiredCerts();
      _acquiredCerts = certs;
      debugPrint('Loaded ${_acquiredCerts.length} acquired certifications');
    } catch (e) {
      debugPrint('Error loading acquired certs: $e');
      _acquiredCerts = [];
    }
    notifyListeners();
  }

  /// 資格を追加
  Future<bool> addCertification(String certId, DateTime acquiredDate) async {
    try {
      // すでに取得済みかチェック
      final existing = await _storageService.getAcquiredCertByCertId(certId);
      if (existing != null) {
        return false; // すでに取得済み
      }

      // 資格マスターから情報取得
      final cert = CertificationData.getCertificationById(certId);
      if (cert == null) return false;

      // 有効期限を計算
      final expiryDate = DateTime(
        acquiredDate.year + cert.validYears,
        acquiredDate.month,
        acquiredDate.day,
      );

      // 新しい取得済み資格を作成
      final acquiredCert = AcquiredCert(
        certId: certId,
        acquiredDate: acquiredDate,
        expiryDate: expiryDate,
      );

      // データベースに保存
      final savedCert = await _storageService.insertAcquiredCert(acquiredCert);
      _acquiredCerts.add(savedCert);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding certification: $e');
      return false;
    }
  }

  /// 資格を削除
  Future<bool> removeCertification(String certId) async {
    try {
      final cert = _acquiredCerts.firstWhere((c) => c.certId == certId);
      if (cert.id != null) {
        await _storageService.deleteAcquiredCert(cert.id!);
        _acquiredCerts.removeWhere((c) => c.certId == certId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error removing certification: $e');
      return false;
    }
  }

  /// すべてのデータをリセット
  Future<void> resetAllData() async {
    try {
      await _storageService.deleteAllAcquiredCerts();
      _acquiredCerts = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting data: $e');
    }
  }

  /// フィルターを変更
  void setFilter(CertFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// フィルタリングされた資格リストを取得
  List<AcquiredCert> getFilteredCerts() {
    switch (_currentFilter) {
      case CertFilter.expiring:
        return _acquiredCerts.where((cert) => cert.needsRenewal).toList();
      case CertFilter.valid:
        return _acquiredCerts.where((cert) => !cert.needsRenewal).toList();
      case CertFilter.all:
        return _acquiredCerts;
    }
  }

  /// 月額手当の合計を計算（上限10万円）
  /// ※期限切れの資格は除外
  int getTotalAllowance() {
    return getTotalAllowanceAsOfDate(DateTime.now());
  }

  /// 指定日時点での月額手当の合計を計算（上限10万円）
  /// ※指定日時点で期限切れの資格は除外
  int getTotalAllowanceAsOfDate(DateTime date) {
    int total = 0;
    for (final acquiredCert in _acquiredCerts) {
      // 指定日時点で期限切れの資格は除外
      if (acquiredCert.expiryDate.isBefore(date)) {
        continue;
      }
      
      final cert = CertificationData.getCertificationById(acquiredCert.certId);
      if (cert != null) {
        total += cert.allowance;
      }
    }
    return total > 100000 ? 100000 : total;
  }

  /// 次回給料日（来月25日）に支給される手当額を計算
  /// = 前月末時点で有効な資格の合計
  int getNextSalaryAllowance() {
    final now = DateTime.now();
    // 前月末を計算
    final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    return getTotalAllowanceAsOfDate(lastMonthEnd);
  }

  /// 次々回給料日（再来月25日）に支給される手当額を計算
  /// = 今月末時点で有効な資格の合計
  int getFollowingSalaryAllowance() {
    final now = DateTime.now();
    // 今月末を計算
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getTotalAllowanceAsOfDate(thisMonthEnd);
  }

  /// 更新が必要な資格の数を取得
  int getExpiringCertsCount() {
    return _acquiredCerts.where((cert) => cert.needsRenewal).length;
  }

  /// 更新が必要な資格のリストを取得
  List<AcquiredCert> getExpiringCerts() {
    return _acquiredCerts.where((cert) => cert.needsRenewal).toList();
  }

  /// 資格が取得済みかチェック
  bool isCertAcquired(String certId) {
    return _acquiredCerts.any((cert) => cert.certId == certId);
  }

  /// 取得済み資格数を取得
  int get acquiredCertsCount => _acquiredCerts.length;
}

