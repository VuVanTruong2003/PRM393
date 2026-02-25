import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/budget.dart';
import '../services/local/hive_store.dart';

class BudgetsController extends ChangeNotifier {
  BudgetsController({required HiveStore store}) : _store = store {
    _boxListenable = _store.budgetsBox.listenable();
    _boxListenable.addListener(_reload);
    _reload();
  }

  final HiveStore _store;
  late final ValueListenable<Box<Map>> _boxListenable;
  final _uuid = const Uuid();

  List<Budget> _budgets = const [];
  List<Budget> get budgets => _budgets;

  static String monthKey(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}';

  List<Budget> forMonth(DateTime month) {
    final key = monthKey(month);
    final items =
        _budgets.where((b) => b.monthKey == key).toList(growable: false);
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  Budget? byId(String id) {
    for (final b in _budgets) {
      if (b.id == id) return b;
    }
    return null;
  }

  void _reload() {
    final items = _store.budgetsBox.values
        .map((m) => Budget.fromMap(m))
        .toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _budgets = items;
    notifyListeners();
  }

  Future<void> create({
    required DateTime month,
    required String categoryId,
    required int limit,
  }) async {
    final now = DateTime.now();
    final budget = Budget(
      id: _uuid.v4(),
      monthKey: monthKey(month),
      categoryId: categoryId,
      limit: limit,
      createdAt: now,
    );
    await _store.budgetsBox.put(budget.id, budget.toMap());
  }

  Future<void> update(Budget budget) async {
    await _store.budgetsBox.put(budget.id, budget.toMap());
  }

  Future<void> delete(String id) async {
    await _store.budgetsBox.delete(id);
  }

  @override
  void dispose() {
    _boxListenable.removeListener(_reload);
    super.dispose();
  }
}

