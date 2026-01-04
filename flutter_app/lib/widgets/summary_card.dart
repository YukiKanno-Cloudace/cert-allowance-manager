import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';

/// サマリーカードウィジェット
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final bool isAlert;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppTheme.primaryColor;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isAlert ? AppTheme.errorColor : displayColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.captionStyle.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isAlert ? AppTheme.errorColor : displayColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTheme.captionStyle,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 金額表示用のサマリーカード
class AllowanceSummaryCard extends StatelessWidget {
  final int nextAmount;
  final int followingAmount;
  final int maxAmount;

  const AllowanceSummaryCard({
    super.key,
    required this.nextAmount,
    required this.followingAmount,
    this.maxAmount = 100000,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final now = DateTime.now();
    
    // 次回給料日（来月25日）
    final nextSalaryDate = DateTime(
      now.month == 12 ? now.year + 1 : now.year,
      now.month == 12 ? 1 : now.month + 1,
      25,
    );
    
    // 次々回給料日（再来月25日）
    final followingSalaryDate = DateTime(
      nextSalaryDate.month == 12 ? nextSalaryDate.year + 1 : nextSalaryDate.year,
      nextSalaryDate.month == 12 ? 1 : nextSalaryDate.month + 1,
      25,
    );

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '資格手当',
                    style: AppTheme.captionStyle.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 次回支給額
            Column(
              children: [
                Text(
                  '次回支給 (${nextSalaryDate.month}/${nextSalaryDate.day})',
                  style: AppTheme.captionStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${formatter.format(nextAmount)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // 次々回支給額
            Column(
              children: [
                Text(
                  '次々回支給 (${followingSalaryDate.month}/${followingSalaryDate.day})',
                  style: AppTheme.captionStyle.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${formatter.format(followingAmount)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '上限: ¥${formatter.format(maxAmount)}',
              style: AppTheme.captionStyle,
            ),
          ],
        ),
      ),
    );
  }
}

/// 資格数表示用のサマリーカード
class CertCountSummaryCard extends StatelessWidget {
  final int count;

  const CertCountSummaryCard({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: '取得資格数',
      value: count.toString(),
      subtitle: '資格',
      icon: Icons.workspace_premium,
    );
  }
}

/// アラート用のサマリーカード
class ExpiringCertsSummaryCard extends StatelessWidget {
  final int count;

  const ExpiringCertsSummaryCard({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SummaryCard(
      title: '更新必要',
      value: count.toString(),
      subtitle: '資格',
      icon: Icons.warning,
      isAlert: true,
    );
  }
}

