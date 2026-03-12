import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../services/remote/firestore_collection_service.dart';
import 'auth_controller.dart';

class CategoriesController extends ChangeNotifier {
  CategoriesController({
    required AuthController authController,
  })  : _authController = authController,
        _remote = FirestoreCollectionService<Category>(
          collectionName: 'categories',
          fromMap: Category.fromMap,
          getId: (value) => value.id,
          toMap: (value) => value.toMap(),
          orderByField: 'createdAt',
        ) {
    _authController.addListener(_syncDataSource);
    _syncDataSource();
  }

  final AuthController _authController;
  final FirestoreCollectionService<Category> _remote;
  final _uuid = const Uuid();
  StreamSubscription<List<Category>>? _remoteSub;

  List<Category> _categories = const [];
  List<Category> get categories => _categories;

  List<Category> byType(CategoryType type) =>
      _categories.where((c) => c.type == type).toList(growable: false);

  Category? byId(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _syncDataSource() {
    if (_authController.user == null) {
      _remoteSub?.cancel();
      _remoteSub = null;
      _categories = const [];
      notifyListeners();
      return;
    }

    if (_remoteSub != null) return;
    final userId = _authController.user!.uid;
    _remoteSub = _remote.watchAll(userId).listen((items) {
      _categories = items;
      notifyListeners();
    });
  }

  Future<void> create({
    required String name,
    required CategoryType type,
  }) async {
    final now = DateTime.now();
    final category = Category(
      id: _uuid.v4(),
      name: name.trim(),
      type: type,
      createdAt: now,
    );
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, category);
  }

  Future<void> update(Category category) async {
    if (_authController.user == null) return;
    await _remote.upsert(_authController.user!.uid, category);
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

