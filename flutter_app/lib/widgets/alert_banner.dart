import 'package:flutter/material.dart';
import '../models/acquired_cert.dart';
import '../models/certification.dart';
import '../constants/app_theme.dart';

/// アラートバナーウィジェット
class AlertBanner extends StatelessWidget {
  final List<AcquiredCert> expiringCerts;
  final List<Certification> certifications;

  const AlertBanner({
    super.key,
    required this.expiringCerts,
    required this.certifications,
  });

  @override
  Widget build(BuildContext context) {
    if (expiringCerts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppTheme.warningColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '更新が必要な資格があります',
                  style: AppTheme.titleStyle.copyWith(
                    color: AppTheme.warningColor.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...expiringCerts.map((cert) {
            final certification = certifications.firstWhere(
              (c) => c.id == cert.certId,
            );
            final statusMessage = cert.getExpiryStatusMessage(certification.validYears);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.circle, 
                    size: 8, 
                    color: cert.isExpired ? AppTheme.errorColor : AppTheme.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${certification.name} - $statusMessage',
                      style: AppTheme.bodyStyle,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

