import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../services/local/hive_store.dart';

class CategoriesController extends ChangeNotifier {
  CategoriesController({required HiveStore store}) : _store = store {
    _boxListenable = _store.categoriesBox.listenable();
    _boxListenable.addListener(_reload);
    _reload();
  }

  final HiveStore _store;
  late final ValueListenable<Box<Map>> _boxListenable;
  final _uuid = const Uuid();

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

  void _reload() {
    final items = _store.categoriesBox.values
        .map((m) => Category.fromMap(m))
        .toList(growable: false)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _categories = items;
    notifyListeners();
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
    await _store.categoriesBox.put(category.id, category.toMap());
  }

  Future<void> update(Category category) async {
    await _store.categoriesBox.put(category.id, category.toMap());
  }

  Future<void> delete(String id) async {
    await _store.categoriesBox.delete(id);
  }

  @override
  void dispose() {
    _boxListenable.removeListener(_reload);
    super.dispose();
  }
}

