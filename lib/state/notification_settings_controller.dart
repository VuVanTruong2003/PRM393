import 'package:flutter/material.dart';

import '../services/local/hive_store.dart';

class NotificationSettingsController extends ChangeNotifier {
  NotificationSettingsController({required HiveStore store}) : _store = store {
    _load();
  }

  final HiveStore _store;

  static const _kMorningEnabled = 'notifMorningEnabled';
  static const _kMorningTime = 'notifMorningTime'; // HH:mm
  static const _kExpenseEnabled = 'notifExpenseEnabled';
  static const _kExpenseTime = 'notifExpenseTime'; // HH:mm
  static const _kBudgetEnabled = 'notifBudgetEnabled';
  static const _kBudgetThreshold = 'notifBudgetThreshold'; // percent 0-100
  static const _kWeeklyEnabled = 'notifWeeklyEnabled';

  bool _morningEnabled = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 7, minute: 0);
  bool _expenseEnabled = true;
  TimeOfDay _expenseTime = const TimeOfDay(hour: 20, minute: 0);
  bool _budgetEnabled = true;
  int _budgetThreshold = 80;
  bool _weeklyEnabled = true;

  bool get morningEnabled => _morningEnabled;
  TimeOfDay get morningTime => _morningTime;
  bool get expenseEnabled => _expenseEnabled;
  TimeOfDay get expenseTime => _expenseTime;
  bool get budgetEnabled => _budgetEnabled;
  int get budgetThreshold => _budgetThreshold;
  bool get weeklyEnabled => _weeklyEnabled;

  void _load() {
    _morningEnabled = _store.getSetting<bool>(_kMorningEnabled) ?? true;
    _expenseEnabled = _store.getSetting<bool>(_kExpenseEnabled) ?? true;
    _budgetEnabled = _store.getSetting<bool>(_kBudgetEnabled) ?? true;
    _weeklyEnabled = _store.getSetting<bool>(_kWeeklyEnabled) ?? true;

    _budgetThreshold = _store.getSetting<int>(_kBudgetThreshold) ?? 80;

    _morningTime = _parseTime(_store.getSetting<String>(_kMorningTime)) ??
        const TimeOfDay(hour: 7, minute: 0);
    _expenseTime = _parseTime(_store.getSetting<String>(_kExpenseTime)) ??
        const TimeOfDay(hour: 20, minute: 0);
  }

  Future<void> setMorningEnabled(bool v) async {
    _morningEnabled = v;
    await _store.setSetting(_kMorningEnabled, v);
    notifyListeners();
  }

  Future<void> setMorningTime(TimeOfDay v) async {
    _morningTime = v;
    await _store.setSetting(_kMorningTime, _formatTime(v));
    notifyListeners();
  }

  Future<void> setExpenseEnabled(bool v) async {
    _expenseEnabled = v;
    await _store.setSetting(_kExpenseEnabled, v);
    notifyListeners();
  }

  Future<void> setExpenseTime(TimeOfDay v) async {
    _expenseTime = v;
    await _store.setSetting(_kExpenseTime, _formatTime(v));
    notifyListeners();
  }

  Future<void> setBudgetEnabled(bool v) async {
    _budgetEnabled = v;
    await _store.setSetting(_kBudgetEnabled, v);
    notifyListeners();
  }

  Future<void> setBudgetThreshold(int v) async {
    _budgetThreshold = v.clamp(0, 100);
    await _store.setSetting(_kBudgetThreshold, _budgetThreshold);
    notifyListeners();
  }

  Future<void> setWeeklyEnabled(bool v) async {
    _weeklyEnabled = v;
    await _store.setSetting(_kWeeklyEnabled, v);
    notifyListeners();
  }

  static TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

