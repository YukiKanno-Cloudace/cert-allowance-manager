import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/acquired_cert.dart';
import '../models/certification.dart';

/// リマインダー設定ダイアログ
class ReminderDialog extends StatefulWidget {
  final Certification certification;
  final AcquiredCert acquiredCert;

  const ReminderDialog({
    super.key,
    required this.certification,
    required this.acquiredCert,
  });

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  int _selectedTab = 0; // 0: 日数指定, 1: 日時指定
  int _daysBeforeExpiry = 30; // デフォルト30日前
  DateTime? _selectedDateTime;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    // デフォルトの日時を30日前に設定
    final expiryDate = widget.acquiredCert.expiryDate;
    _selectedDateTime = expiryDate.subtract(Duration(days: _daysBeforeExpiry));
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy/MM/dd');
    final expiryDate = widget.acquiredCert.expiryDate;
    final daysUntilExpiry = widget.acquiredCert.getDaysUntilExpiry();

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('更新リマインダー設定'),
          const SizedBox(height: 4),
          Text(
            widget.certification.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          const SizedBox(height: 4),
          Text(
            '有効期限: ${formatter.format(expiryDate)} (あと$daysUntilExpiry日)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タブ切り替え
            Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: '日数指定',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    label: '日時指定',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 日数指定
            if (_selectedTab == 0) ...[
              const Text('有効期限の何日前に通知しますか？'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _daysBeforeExpiry.toDouble(),
                      min: 1,
                      max: 180,
                      divisions: 179,
                      label: '$_daysBeforeExpiry日前',
                      onChanged: (value) {
                        setState(() {
                          _daysBeforeExpiry = value.toInt();
                          _selectedDateTime = expiryDate.subtract(
                            Duration(days: _daysBeforeExpiry),
                          );
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '$_daysBeforeExpiry日前',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${formatter.format(_selectedDateTime!)} 09:00 に通知',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 日時指定
            if (_selectedTab == 1) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('通知日'),
                subtitle: Text(
                  _selectedDateTime != null
                      ? formatter.format(_selectedDateTime!)
                      : '選択してください',
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime ?? now,
                    firstDate: now,
                    lastDate: expiryDate,
                  );
                  if (picked != null) {
                    setState(() => _selectedDateTime = picked);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('通知時刻'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedDateTime != null
                            ? '${formatter.format(_selectedDateTime!)} ${_selectedTime.format(context)} に通知'
                            : '日付を選択してください',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _selectedDateTime != null
              ? () {
                  final notificationDateTime = DateTime(
                    _selectedDateTime!.year,
                    _selectedDateTime!.month,
                    _selectedDateTime!.day,
                    _selectedTab == 0 ? 9 : _selectedTime.hour,
                    _selectedTab == 0 ? 0 : _selectedTime.minute,
                  );
                  Navigator.of(context).pop(notificationDateTime);
                }
              : null,
          child: const Text('設定'),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}







