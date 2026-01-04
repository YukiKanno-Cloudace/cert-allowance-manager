import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../providers/cert_provider.dart';
import '../providers/notification_provider.dart';
import '../constants/certification_data.dart';
import '../models/certification.dart';
import '../models/acquired_cert.dart';
import '../widgets/summary_card.dart';
import '../widgets/cert_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/reminder_dialog.dart';
import 'add_cert_screen.dart';
import 'master_screen.dart';
import 'theme_selector_screen.dart';
import 'notification_settings_screen.dart';

/// ホーム画面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _notificationPermissionRequestedKey =
      'notification_permission_requested';

  @override
  void initState() {
    super.initState();
    // 初回読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<CertProvider>().initialize();

      // 初回起動時のみ通知許可をリクエスト
      await _requestNotificationPermissionOnFirstLaunch();
    });
  }

  /// 初回起動時に通知許可をリクエスト
  Future<void> _requestNotificationPermissionOnFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasRequested =
          prefs.getBool(_notificationPermissionRequestedKey) ?? false;

      if (!hasRequested && mounted) {
        // 初回起動時のみリクエスト
        final notificationProvider = context.read<NotificationProvider>();
        await notificationProvider.initialize();

        // 少し待ってからダイアログを表示（UIが落ち着いてから）
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          final granted = await notificationProvider.requestPermission();

          // リクエスト済みフラグを保存
          await prefs.setBool(_notificationPermissionRequestedKey, true);

          // 結果をユーザーに通知
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  granted ? '✅ 通知が有効になりました' : 'ℹ️ 通知は後から設定できます',
                ),
                backgroundColor: granted ? Colors.green : Colors.blue.shade700,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('初回通知許可リクエストエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('資格手当管理アプリ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemeSelectorScreen()),
              );
            },
            tooltip: 'テーマを変更',
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MasterScreen()),
              );
            },
            tooltip: '資格一覧',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'notifications') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationSettingsScreen()),
                );
              } else if (value == 'reset') {
                _showResetDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'notifications',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('通知設定'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('データをリセット'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CertProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAcquiredCerts(),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // サマリーセクション
                _buildSummarySection(provider),

                // アラートセクション
                AlertBanner(
                  expiringCerts: provider.getExpiringCerts(),
                  certifications: CertificationData.certifications,
                ),

                // フィルターボタン
                _buildFilterSection(provider),

                // 資格一覧
                _buildCertList(provider),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCertScreen()),
          );
          if (result == true) {
            context.read<CertProvider>().loadAcquiredCerts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('資格を追加'),
      ),
    );
  }

  Widget _buildSummarySection(CertProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // デスクトップ: 横並び
            return Row(
              children: [
                Expanded(
                  child: AllowanceSummaryCard(
                    nextAmount: provider.getNextSalaryAllowance(),
                    followingAmount: provider.getFollowingSalaryAllowance(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CertCountSummaryCard(
                    count: provider.acquiredCertsCount,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ExpiringCertsSummaryCard(
                    count: provider.getExpiringCertsCount(),
                  ),
                ),
              ],
            );
          } else {
            // モバイル: 縦並び
            return Column(
              children: [
                AllowanceSummaryCard(
                  nextAmount: provider.getNextSalaryAllowance(),
                  followingAmount: provider.getFollowingSalaryAllowance(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CertCountSummaryCard(
                        count: provider.acquiredCertsCount,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ExpiringCertsSummaryCard(
                        count: provider.getExpiringCertsCount(),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterSection(CertProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('すべて'),
            selected: provider.currentFilter == CertFilter.all,
            onSelected: (_) => provider.setFilter(CertFilter.all),
          ),
          ChoiceChip(
            label: const Text('更新必要'),
            selected: provider.currentFilter == CertFilter.expiring,
            onSelected: (_) => provider.setFilter(CertFilter.expiring),
          ),
          ChoiceChip(
            label: const Text('有効'),
            selected: provider.currentFilter == CertFilter.valid,
            onSelected: (_) => provider.setFilter(CertFilter.valid),
          ),
        ],
      ),
    );
  }

  Widget _buildCertList(CertProvider provider) {
    final filteredCerts = provider.getFilteredCerts();

    if (filteredCerts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                provider.currentFilter == CertFilter.all
                    ? 'まだ資格が登録されていません'
                    : '該当する資格がありません',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '取得済み資格 (${filteredCerts.length}件)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...filteredCerts.map((acquiredCert) {
            final cert = CertificationData.getCertificationById(
              acquiredCert.certId,
            );
            if (cert == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CertCard(
                certification: cert,
                acquiredCert: acquiredCert,
                onDelete: () => _showDeleteDialog(cert.id, cert.name),
                onSetReminder: () => _showReminderDialog(cert, acquiredCert),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showDeleteDialog(String certId, String certName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('資格を削除'),
        content: Text('「$certName」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<CertProvider>().removeCertification(certId);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('資格を削除しました')),
                );
              }
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(
      Certification cert, AcquiredCert acquiredCert) async {
    final result = await showDialog<DateTime>(
      context: context,
      builder: (context) => ReminderDialog(
        certification: cert,
        acquiredCert: acquiredCert,
      ),
    );

    if (result != null && mounted) {
      // 通知をスケジュール
      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.scheduleCustomReminder(
        certId: cert.id,
        certName: cert.name,
        reminderDate: result,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${DateFormat('yyyy/MM/dd HH:mm').format(result)} にリマインダーを設定しました',
            ),
          ),
        );
      }
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データをリセット'),
        content: const Text(
          'すべてのデータをリセットしてもよろしいですか？\nこの操作は取り消せません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<CertProvider>().resetAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('データをリセットしました')),
                );
              }
            },
            child: const Text('リセット', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
