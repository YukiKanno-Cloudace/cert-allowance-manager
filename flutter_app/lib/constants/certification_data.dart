import '../models/certification.dart';

/// 資格マスターデータ（18資格）
class CertificationData {
  static const List<Certification> certifications = [
    // Google Cloud - Foundational / Associate (3年)
    Certification(
      id: 'cdl',
      name: 'Cloud Digital Leader',
      category: 'Google Cloud',
      allowance: 5000,
      validYears: 3,
    ),
    Certification(
      id: 'gail',
      name: 'Generative AI Leader',
      category: 'Google Cloud',
      allowance: 5000,
      validYears: 3,
    ),
    Certification(
      id: 'ace',
      name: 'Associate Cloud Engineer',
      category: 'Google Cloud',
      allowance: 5000,
      validYears: 3,
    ),
    Certification(
      id: 'agwa',
      name: 'Associate Google Workspace Administrator',
      category: 'Google Cloud',
      allowance: 5000,
      validYears: 3,
    ),
    Certification(
      id: 'adp',
      name: 'Associate Data Practitioner',
      category: 'Google Cloud',
      allowance: 5000,
      validYears: 3,
    ),

    // Google Cloud - Professional (2年)
    Certification(
      id: 'pca',
      name: 'Professional Cloud Architect',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pdbe',
      name: 'Professional Database Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pcdev',
      name: 'Professional Cloud Developer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pde',
      name: 'Professional Data Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pcdoe',
      name: 'Professional Cloud DevOps Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pcse',
      name: 'Professional Cloud Security Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pcne',
      name: 'Professional Cloud Network Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'pmle',
      name: 'Professional Machine Learning Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),
    Certification(
      id: 'psoe',
      name: 'Professional Security Operations Engineer',
      category: 'Google Cloud',
      allowance: 10000,
      validYears: 2,
    ),

    // その他
    Certification(
      id: 'pcoa',
      name: 'Professional ChromeOS Administrator',
      category: 'Chrome OS',
      allowance: 5000,
      validYears: 3,
    ),
    Certification(
      id: 'ckad',
      name: 'Certified Kubernetes Application Developer',
      category: 'CNCF',
      allowance: 10000,
      validYears: 3,
    ),
    Certification(
      id: 'cka',
      name: 'Certified Kubernetes Administrator',
      category: 'CNCF',
      allowance: 10000,
      validYears: 3,
    ),
    Certification(
      id: 'pmp',
      name: 'PMP',
      category: 'PMI',
      allowance: 10000,
      validYears: 3,
    ),
  ];

  /// IDで資格を検索
  static Certification? getCertificationById(String id) {
    try {
      return certifications.firstWhere((cert) => cert.id == id);
    } catch (e) {
      return null;
    }
  }

  /// カテゴリで資格をグループ化
  static Map<String, List<Certification>> getCertificationsByCategory() {
    final Map<String, List<Certification>> result = {};
    for (final cert in certifications) {
      if (!result.containsKey(cert.category)) {
        result[cert.category] = [];
      }
      result[cert.category]!.add(cert);
    }
    return result;
  }

  /// 全カテゴリのリストを取得
  static List<String> getAllCategories() {
    return certifications
        .map((cert) => cert.category)
        .toSet()
        .toList()
      ..sort();
  }
}

