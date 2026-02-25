import 'package:hive/hive.dart';

class HiveStore {
  static const _settingsBoxName = 'settings';
  static const _accountsBoxName = 'accounts';
  static const _categoriesBoxName = 'categories';
  static const _transactionsBoxName = 'transactions';
  static const _budgetsBoxName = 'budgets';

  late final Box<dynamic> _settings;
  late final Box<Map> _accounts;
  late final Box<Map> _categories;
  late final Box<Map> _transactions;
  late final Box<Map> _budgets;

  Future<void> init() async {
    _settings = await Hive.openBox<dynamic>(_settingsBoxName);
    _accounts = await Hive.openBox<Map>(_accountsBoxName);
    _categories = await Hive.openBox<Map>(_categoriesBoxName);
    _transactions = await Hive.openBox<Map>(_transactionsBoxName);
    _budgets = await Hive.openBox<Map>(_budgetsBoxName);
  }

  T? getSetting<T>(String key) => _settings.get(key) as T?;

  Future<void> setSetting(String key, dynamic value) => _settings.put(key, value);

  Box<dynamic> get settingsBox => _settings;
  Box<Map> get accountsBox => _accounts;
  Box<Map> get categoriesBox => _categories;
  Box<Map> get transactionsBox => _transactions;
  Box<Map> get budgetsBox => _budgets;
}

