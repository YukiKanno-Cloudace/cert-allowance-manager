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
    int total = 0;
    for (final acquiredCert in _acquiredCerts) {
      // 期限切れの資格は除外
      if (acquiredCert.isExpired) {
        continue;
      }
      
      final cert = CertificationData.getCertificationById(acquiredCert.certId);
      if (cert != null) {
        total += cert.allowance;
      }
    }
    return total > 100000 ? 100000 : total;
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

  /// 今月支給の手当を計算（先月末までに取得した資格のみ）
  int getCurrentMonthSalaryAllowance() {
    final now = DateTime.now();
    // 今月1日の0時0分
    final thisMonthStart = DateTime(now.year, now.month, 1);
    
    int total = 0;
    for (final acquiredCert in _acquiredCerts) {
      // 期限切れの資格は除外
      if (acquiredCert.isExpired) {
        continue;
      }
      
      // 今月取得した資格は除外（先月末までに取得した資格のみ）
      if (acquiredCert.acquiredDate.isBefore(thisMonthStart)) {
        final cert = CertificationData.getCertificationById(acquiredCert.certId);
        if (cert != null) {
          total += cert.allowance;
        }
      }
    }
    return total > 100000 ? 100000 : total;
  }

  /// 来月支給の手当を計算（今月末までに取得した資格すべて）
  int getNextMonthSalaryAllowance() {
    final now = DateTime.now();
    // 来月1日の0時0分
    final nextMonthStart = DateTime(
      now.month == 12 ? now.year + 1 : now.year,
      now.month == 12 ? 1 : now.month + 1,
      1,
    );
    
    int total = 0;
    for (final acquiredCert in _acquiredCerts) {
      // 期限切れの資格は除外
      if (acquiredCert.isExpired) {
        continue;
      }
      
      // 来月取得予定の資格は除外（今月末までに取得した資格のみ）
      if (acquiredCert.acquiredDate.isBefore(nextMonthStart)) {
        final cert = CertificationData.getCertificationById(acquiredCert.certId);
        if (cert != null) {
          total += cert.allowance;
        }
      }
    }
    return total > 100000 ? 100000 : total;
  }
}

