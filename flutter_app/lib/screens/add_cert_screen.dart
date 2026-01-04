import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cert_provider.dart';
import '../constants/certification_data.dart';
import '../models/certification.dart';
import '../constants/app_theme.dart';

/// 資格追加画面
class AddCertScreen extends StatefulWidget {
  const AddCertScreen({super.key});

  @override
  State<AddCertScreen> createState() => _AddCertScreenState();
}

class _AddCertScreenState extends State<AddCertScreen> {
  Certification? _selectedCert;
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('資格を追加'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '資格情報を入力',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 24),

                    // 資格選択
                    _buildCertificationSelector(),

                    const SizedBox(height: 24),

                    // 取得日選択
                    _buildDatePicker(),

                    const SizedBox(height: 24),

                    // 選択された資格の情報
                    if (_selectedCert != null) _buildCertInfo(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 追加ボタン
            ElevatedButton(
              onPressed: _addCertification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('資格を追加', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationSelector() {
    final provider = context.watch<CertProvider>();
    final availableCerts = CertificationData.certifications.where((cert) {
      return !provider.isCertAcquired(cert.id);
    }).toList();

    return InkWell(
      onTap: () => _showCertificationPicker(availableCerts),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '資格を選択',
          hintText: '資格を選択してください',
          prefixIcon: const Icon(Icons.school),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          errorText: _selectedCert == null && _formKey.currentState?.validate() == false
              ? '資格を選択してください'
              : null,
        ),
        child: Text(
          _selectedCert?.name ?? '資格を選択してください',
          style: _selectedCert == null
              ? const TextStyle(color: Colors.grey)
              : null,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _showCertificationPicker(List<Certification> availableCerts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '資格を選択',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: availableCerts.isEmpty
                      ? const Center(
                          child: Text('すべての資格が登録済みです'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: availableCerts.length,
                          itemBuilder: (context, index) {
                            final cert = availableCerts[index];
                            return ListTile(
                              leading: Icon(
                                Icons.workspace_premium,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text(
                                cert.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${cert.category} - ¥${NumberFormat('#,###').format(cert.allowance)}/月 - ${cert.validYears}年',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCert = cert;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDatePicker() {
    final formatter = DateFormat('yyyy年MM月dd日');

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('ja'),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '取得日',
          hintText: '取得日を選択してください',
          prefixIcon: Icon(Icons.calendar_today),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(formatter.format(_selectedDate)),
      ),
    );
  }

  Widget _buildCertInfo() {
    final cert = _selectedCert!;
    final expiryDate = DateTime(
      _selectedDate.year + cert.validYears,
      _selectedDate.month,
      _selectedDate.day,
    );
    final formatter = DateFormat('yyyy年MM月dd日');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '資格情報',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          _infoRow('資格名', cert.name),
          _infoRow('カテゴリ', cert.category),
          _infoRow('月額手当', '¥${NumberFormat('#,###').format(cert.allowance)}'),
          _infoRow('有効期限', '${cert.validYears}年'),
          _infoRow('有効期限日', formatter.format(expiryDate)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTheme.captionStyle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
              maxLines: null,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addCertification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCert == null) return;

    final provider = context.read<CertProvider>();
    final success = await provider.addCertification(
      _selectedCert!.id,
      _selectedDate,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('資格を追加しました')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('この資格はすでに登録されています'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

