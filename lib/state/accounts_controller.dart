import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/account.dart';
import '../services/local/hive_store.dart';

class AccountsController extends ChangeNotifier {
  AccountsController({required HiveStore store}) : _store = store {
    _boxListenable = _store.accountsBox.listenable();
    _boxListenable.addListener(_reload);
    _reload();
  }

  final HiveStore _store;
  late final ValueListenable<Box<Map>> _boxListenable;
  final _uuid = const Uuid();

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  Account? byId(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  void _reload() {
    final items = _store.accountsBox.values
        .map((m) => Account.fromMap(m))
        .toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _accounts = items;
    notifyListeners();
  }

  Future<void> create({
    required String name,
    required int balanceStart,
  }) async {
    final now = DateTime.now();
    final account = Account(
      id: _uuid.v4(),
      name: name.trim(),
      balanceStart: balanceStart,
      createdAt: now,
    );
    await _store.accountsBox.put(account.id, account.toMap());
  }

  Future<void> update(Account account) async {
    await _store.accountsBox.put(account.id, account.toMap());
  }

  Future<void> delete(String id) async {
    await _store.accountsBox.delete(id);
  }

  @override
  void dispose() {
    _boxListenable.removeListener(_reload);
    super.dispose();
  }
}

