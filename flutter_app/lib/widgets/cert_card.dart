import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/certification.dart';
import '../models/acquired_cert.dart';
import '../constants/app_theme.dart';

/// 資格カードウィジェット
class CertCard extends StatelessWidget {
  final Certification certification;
  final AcquiredCert acquiredCert;
  final VoidCallback? onDelete;
  final VoidCallback? onSetReminder;

  const CertCard({
    super.key,
    required this.certification,
    required this.acquiredCert,
    this.onDelete,
    this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy/MM/dd');
    final daysUntilExpiry = acquiredCert.getDaysUntilExpiry();
    final isExpired = daysUntilExpiry < 0;
    final isExpiring = acquiredCert.needsRenewal && !isExpired;
    final statusMessage = acquiredCert.getExpiryStatusMessage(certification.validYears);
    
    // 色分け: 期限切れ=赤、更新必要=オレンジ、通常=なし
    final borderColor = isExpired
        ? AppTheme.errorColor
        : isExpiring
            ? AppTheme.warningColor
            : null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderColor != null
            ? BorderSide(color: borderColor, width: 3)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトルとカテゴリ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certification.name,
                        style: AppTheme.titleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          certification.category,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        labelStyle: const TextStyle(color: AppTheme.primaryColor),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // 詳細情報
            Row(
              children: [
                Expanded(
                  child: _DetailItem(
                    label: '取得日',
                    value: formatter.format(acquiredCert.acquiredDate),
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: '有効期限',
                    value: formatter.format(acquiredCert.expiryDate),
                    valueColor: isExpired
                        ? AppTheme.errorColor
                        : isExpiring
                            ? AppTheme.warningColor
                            : null,
                    badge: statusMessage,
                    badgeColor: isExpired
                        ? AppTheme.errorColor
                        : isExpiring
                            ? AppTheme.warningColor
                            : Colors.grey,
                  ),
                ),
                Expanded(
                  child: _DetailItem(
                    label: '月額手当',
                    value: '¥${NumberFormat('#,###').format(certification.allowance)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // リマインダー設定ボタン
            if (!isExpired) ...[
              const Divider(),
              InkWell(
                onTap: onSetReminder,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.alarm_add,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '更新リマインダーを設定',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 詳細項目ウィジェット
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final String? badge;
  final Color? badgeColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.captionStyle,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (badgeColor ?? AppTheme.warningColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badgeColor ?? AppTheme.warningColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

