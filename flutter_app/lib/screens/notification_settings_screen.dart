import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/cert_provider.dart';

/// 通知設定画面
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知設定'),
      ),
      body: Consumer2<NotificationProvider, CertProvider>(
        builder: (context, notificationProvider, certProvider, child) {
          if (!notificationProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = notificationProvider.settings;
          final totalAllowance = certProvider.getNextMonthSalaryAllowance();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 通知許可セクション
              _buildPermissionCard(context, notificationProvider),

              const SizedBox(height: 16),

              // 給料日通知セクション
              _buildSalaryDaySection(
                context,
                notificationProvider,
                settings,
                totalAllowance,
              ),

              const SizedBox(height: 16),

              // 資格更新通知セクション
              _buildRenewalSection(context, notificationProvider, settings),

              const SizedBox(height: 16),

              // カスタム催促通知セクション
              _buildCustomReminderSection(
                  context, notificationProvider, settings),

              const SizedBox(height: 16),

              // テスト通知ボタン
              _buildTestNotificationButton(context, notificationProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context,
    NotificationProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '通知許可',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '通知を受け取るには、アプリの通知許可が必要です。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final granted = await provider.requestPermission();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        granted
                            ? '✅ 通知許可が有効になりました'
                            : '❌ 通知許可が拒否されました。システム設定から許可してください。',
                      ),
                      backgroundColor: granted ? Colors.green : Colors.red,
                      duration: Duration(seconds: granted ? 2 : 4),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('通知許可を確認'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryDaySection(
    BuildContext context,
    NotificationProvider provider,
    settings,
    int totalAllowance,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '給料日通知',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: settings.salaryDayNotificationEnabled,
                  onChanged: (value) {
                    provider.toggleSalaryDayNotification(value, totalAllowance);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '毎月指定した日に資格手当の金額を通知します。',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('給料日: '),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: settings.salaryDay.toDouble(),
                    min: 1,
                    max: 31,
                    divisions: 30,
                    label: '${settings.salaryDay}日',
                    onChanged: settings.salaryDayNotificationEnabled
                        ? (value) {
                            provider.setSalaryDay(
                                value.toInt(), totalAllowance);
                          }
                        : null,
                  ),
                ),
                Text(
                  '${settings.salaryDay}日',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (settings.salaryDayNotificationEnabled) ...[
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '毎月${settings.salaryDay}日 午前9時に通知されます',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRenewalSection(
    BuildContext context,
    NotificationProvider provider,
    settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.update, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '資格更新通知',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: settings.renewalNotificationEnabled,
                  onChanged: (value) {
                    provider.toggleRenewalNotification(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '資格の更新可能期間になったら自動的に通知します。',
              style: TextStyle(color: Colors.grey),
            ),
            if (settings.renewalNotificationEnabled) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '更新可能期間（有効期限の180日前/60日前）に通知されます',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReminderSection(
    BuildContext context,
    NotificationProvider provider,
    settings,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm, color: Colors.red),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'カスタム催促通知',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: settings.customReminderEnabled,
                  onChanged: (value) {
                    provider.toggleCustomReminder(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '各資格に対して個別に催促日時を設定できます（未実装）。',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNotificationButton(
    BuildContext context,
    NotificationProvider provider,
  ) {
    final certProvider = Provider.of<CertProvider>(context, listen: false);
    final totalAllowance = certProvider.getTotalAllowance();

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'テスト通知',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '各通知をテストできます（1分後に通知が届きます）',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // 即座のテスト通知
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await provider.showTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ テスト通知を送信しました'),
                        backgroundColor: Colors.blue,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ 失敗: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('即座にテスト通知'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            const Text(
              'バックグラウンド通知テスト（1分後）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),

            // 1. バックグラウンドテスト
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await provider.scheduleTestNotificationInOneMinute();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ 1分後にテスト通知が届きます'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ 失敗: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.schedule),
              label: const Text('1. バックグラウンド通知'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),

            const SizedBox(height: 8),

            // 2. 給料日通知テスト
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await provider.testSalaryDayNotification(totalAllowance);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ 1分後に給料日通知が届きます'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ 失敗: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.attach_money),
              label: Text('2. 給料日通知（¥$totalAllowance）'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),

            const SizedBox(height: 8),

            // 3. 資格更新通知テスト
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await provider.testRenewalNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ 1分後に資格更新通知が届きます'),
                        backgroundColor: Colors.deepOrange,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ 失敗: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.update),
              label: const Text('3. 資格更新通知'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
