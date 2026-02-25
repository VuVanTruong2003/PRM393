import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_entry.dart';
import '../services/local/hive_store.dart';

class TransactionsController extends ChangeNotifier {
  TransactionsController({required HiveStore store}) : _store = store {
    _boxListenable = _store.transactionsBox.listenable();
    _boxListenable.addListener(_reload);
    _reload();
  }

  final HiveStore _store;
  late final ValueListenable<Box<Map>> _boxListenable;
  final _uuid = const Uuid();

  List<TransactionEntry> _transactions = const [];
  List<TransactionEntry> get transactions => _transactions;

  TransactionEntry? byId(String id) {
    for (final t in _transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  void _reload() {
    final items = _store.transactionsBox.values
        .map((m) => TransactionEntry.fromMap(m))
        .toList(growable: false)
      ..sort((a, b) => b.date.compareTo(a.date));
    _transactions = items;
    notifyListeners();
  }

  List<TransactionEntry> forMonth(DateTime month) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return _transactions
        .where((t) => !t.date.isBefore(start) && t.date.isBefore(end))
        .toList(growable: false);
  }

  int totalIncomeForMonth(DateTime month) {
    return forMonth(month)
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  int totalExpenseForMonth(DateTime month) {
    return forMonth(month)
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  Future<void> create({
    required TransactionType type,
    required String accountId,
    required String categoryId,
    required int amount,
    required DateTime date,
    required String note,
  }) async {
    final now = DateTime.now();
    final entry = TransactionEntry(
      id: _uuid.v4(),
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      date: date,
      note: note.trim(),
      attachmentUrls: const [],
      createdAt: now,
    );
    await _store.transactionsBox.put(entry.id, entry.toMap());
  }

  Future<void> update(TransactionEntry entry) async {
    await _store.transactionsBox.put(entry.id, entry.toMap());
  }

  Future<void> delete(String id) async {
    await _store.transactionsBox.delete(id);
  }

  @override
  void dispose() {
    _boxListenable.removeListener(_reload);
    super.dispose();
  }
}

