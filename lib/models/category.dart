enum CategoryType { income, expense }

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String name;
  final CategoryType type;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'createdAt': createdAt.toIso8601String(),
      };

  static Category fromMap(Map map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      type: CategoryType.values.byName(map['type'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

