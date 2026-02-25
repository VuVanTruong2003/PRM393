class Account {
  const Account({
    required this.id,
    required this.name,
    required this.balanceStart,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int balanceStart;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'balanceStart': balanceStart,
        'createdAt': createdAt.toIso8601String(),
      };

  static Account fromMap(Map map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      balanceStart: (map['balanceStart'] as num).toInt(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

