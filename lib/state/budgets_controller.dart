import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/budget.dart';
import '../services/remote/firestore_collection_service.dart';
import 'auth_controller.dart';

class BudgetsController extends ChangeNotifier {
  BudgetsController({
    required AuthController authController,
  })  : _authController = authController,
        _remote = FirestoreCollectionService<Budget>(
          collectionName: 'budgets',
          fromMap: Budget.fromMap,
          getId: (value) => value.id,
          toMap: (value) => value.toMap(),
          orderByField: 'createdAt',
        ) {
    _authController.addListener(_syncDataSource);
    _syncDataSource();
  }

  final AuthController _authController;
  final FirestoreCollectionService<Budget> _remote;
  final _uuid = const Uuid();
  StreamSubscription<List<Budget>>? _remoteSub;

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

  void _syncDataSource() {
    if (_authController.user == null) {
      _remoteSub?.cancel();
      _remoteSub = null;
      _budgets = const [];
      notifyListeners();
      return;
    }

    if (_remoteSub != null) return;
    final userId = _authController.user!.uid;
    _remoteSub = _remote.watchAll(userId).listen((items) {
      _budgets = items;
      notifyListeners();
    });
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
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, budget);
  }

  Future<void> update(Budget budget) async {
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, budget);
  }

  Future<void> delete(String id) async {
    if (_authController.user == null) return;
    await _remote.delete(_authController.user!.uid, id);
  }

  @override
  void dispose() {
    _remoteSub?.cancel();
    _authController.removeListener(_syncDataSource);
    super.dispose();
  }
}

