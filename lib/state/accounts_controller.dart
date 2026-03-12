import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/account.dart';
import '../services/remote/firestore_collection_service.dart';
import 'auth_controller.dart';

class AccountsController extends ChangeNotifier {
  AccountsController({
    required AuthController authController,
  })  : _authController = authController,
        _remote = FirestoreCollectionService<Account>(
          collectionName: 'accounts',
          fromMap: Account.fromMap,
          getId: (value) => value.id,
          toMap: (value) => value.toMap(),
          orderByField: 'createdAt',
        ) {
    _authController.addListener(_syncDataSource);
    _syncDataSource();
  }

  final AuthController _authController;
  final FirestoreCollectionService<Account> _remote;
  final _uuid = const Uuid();
  StreamSubscription<List<Account>>? _remoteSub;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  Account? byId(String id) {
    for (final a in _accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  void _syncDataSource() {
    if (_authController.user == null) {
      _remoteSub?.cancel();
      _remoteSub = null;
      _accounts = const [];
      notifyListeners();
      return;
    }

    if (_remoteSub != null) return;
    final userId = _authController.user!.uid;
    _remoteSub = _remote.watchAll(userId).listen((items) {
      _accounts = items;
      notifyListeners();
    });
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
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, account);
  }

  Future<void> update(Account account) async {
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, account);
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

