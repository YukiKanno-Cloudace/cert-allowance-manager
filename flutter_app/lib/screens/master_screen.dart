import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cert_provider.dart';
import '../constants/certification_data.dart';
import '../constants/app_theme.dart';

/// 資格マスター画面
class MasterScreen extends StatelessWidget {
  const MasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('対象資格一覧'),
      ),
      body: Consumer<CertProvider>(
        builder: (context, provider, child) {
          final categorized = CertificationData.getCertificationsByCategory();
          final categories = categorized.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final certs = categorized[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...certs.map((cert) {
                    final isAcquired = provider.isCertAcquired(cert.id);
                    return _buildCertItem(context, cert, isAcquired);
                  }),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCertItem(
    BuildContext context,
    certification,
    bool isAcquired,
  ) {
    return Card(
      color: isAcquired
          ? AppTheme.successColor.withOpacity(0.1)
          : Colors.white,
      child: ListTile(
        leading: Icon(
          isAcquired ? Icons.check_circle : Icons.circle_outlined,
          color: isAcquired ? AppTheme.successColor : Colors.grey,
          size: 32,
        ),
        title: Text(
          certification.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('月額手当: ¥${NumberFormat('#,###').format(certification.allowance)}'),
            Text('有効期限: ${certification.validYears}年'),
          ],
        ),
        trailing: isAcquired
            ? Chip(
                label: const Text(
                  '取得済み',
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: AppTheme.successColor,
                labelStyle: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }
}

