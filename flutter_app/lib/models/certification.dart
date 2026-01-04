/// 資格マスターモデル
class Certification {
  final String id;
  final String name;
  final String category;
  final int allowance; // 月額手当
  final int validYears; // 有効期限（年数）

  const Certification({
    required this.id,
    required this.name,
    required this.category,
    required this.allowance,
    required this.validYears,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'allowance': allowance,
      'validYears': validYears,
    };
  }

  factory Certification.fromMap(Map<String, dynamic> map) {
    return Certification(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      allowance: map['allowance'] as int,
      validYears: map['validYears'] as int,
    );
  }

  @override
  String toString() {
    return 'Certification{id: $id, name: $name, category: $category, allowance: $allowance, validYears: $validYears}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Certification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

