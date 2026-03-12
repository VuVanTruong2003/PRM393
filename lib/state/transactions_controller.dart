import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_entry.dart';
import '../services/remote/firestore_collection_service.dart';
import 'auth_controller.dart';

class TransactionsController extends ChangeNotifier {
  TransactionsController({
    required AuthController authController,
  })  : _authController = authController,
        _remote = FirestoreCollectionService<TransactionEntry>(
          collectionName: 'transactions',
          fromMap: TransactionEntry.fromMap,
          getId: (value) => value.id,
          toMap: (value) => value.toMap(),
          orderByField: 'date',
          descending: true,
        ) {
    _authController.addListener(_syncDataSource);
    _syncDataSource();
  }

  final AuthController _authController;
  final FirestoreCollectionService<TransactionEntry> _remote;
  final _uuid = const Uuid();
  StreamSubscription<List<TransactionEntry>>? _remoteSub;

  List<TransactionEntry> _transactions = const [];
  List<TransactionEntry> get transactions => _transactions;

  TransactionEntry? byId(String id) {
    for (final t in _transactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  void _syncDataSource() {
    if (_authController.user == null) {
      _remoteSub?.cancel();
      _remoteSub = null;
      _transactions = const [];
      notifyListeners();
      return;
    }

    if (_remoteSub != null) return;
    final userId = _authController.user!.uid;
    _remoteSub = _remote.watchAll(userId).listen((items) {
      _transactions = items;
      notifyListeners();
    });
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
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, entry);
  }

  Future<void> update(TransactionEntry entry) async {
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, entry);
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

