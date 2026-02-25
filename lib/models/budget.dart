class Budget {
  const Budget({
    required this.id,
    required this.monthKey,
    required this.categoryId,
    required this.limit,
    required this.createdAt,
  });

  // Format: yyyy-MM (e.g. 2026-02)
  final String monthKey;
  final String id;
  final String categoryId;
  final int limit;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'monthKey': monthKey,
        'categoryId': categoryId,
        'limit': limit,
        'createdAt': createdAt.toIso8601String(),
      };

  static Budget fromMap(Map map) {
    return Budget(
      id: map['id'] as String,
      monthKey: map['monthKey'] as String,
      categoryId: map['categoryId'] as String,
      limit: (map['limit'] as num).toInt(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

