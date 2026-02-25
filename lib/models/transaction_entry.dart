enum TransactionType { income, expense }

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.type,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.note,
    required this.attachmentUrls,
    required this.createdAt,
  });

  final String id;
  final TransactionType type;
  final String accountId;
  final String categoryId;
  final int amount;
  final DateTime date;
  final String note;
  final List<String> attachmentUrls;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'accountId': accountId,
        'categoryId': categoryId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
        'attachmentUrls': attachmentUrls,
        'createdAt': createdAt.toIso8601String(),
      };

  static TransactionEntry fromMap(Map map) {
    final raw = map['attachmentUrls'];
    final attachmentUrls = raw is List
        ? raw.whereType<String>().toList(growable: false)
        : const <String>[];
    return TransactionEntry(
      id: map['id'] as String,
      type: TransactionType.values.byName(map['type'] as String),
      accountId: map['accountId'] as String,
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toInt(),
      date: DateTime.parse(map['date'] as String),
      note: (map['note'] as String?) ?? '',
      attachmentUrls: attachmentUrls,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

