import 'package:flutter/material.dart';

import '../services/local/hive_store.dart';

class AppConfig extends ChangeNotifier {
  AppConfig({
    required HiveStore store,
    required ThemeMode themeMode,
    required bool useFirebase,
  })  : _store = store,
        _themeMode = themeMode,
        _useFirebase = useFirebase;

  static const _kThemeMode = 'themeMode';
  static const _kUseFirebase = 'useFirebase';

  final HiveStore _store;
  ThemeMode _themeMode;
  bool _useFirebase;

  static AppConfig fromStore(HiveStore store) {
    final rawTheme = store.getSetting<String>(_kThemeMode);
    final themeMode = switch (rawTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final useFirebase = store.getSetting<bool>(_kUseFirebase) ?? false;
    return AppConfig(store: store, themeMode: themeMode, useFirebase: useFirebase);
  }

  ThemeMode get themeMode => _themeMode;
  bool get useFirebase => _useFirebase;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _store.setSetting(_kThemeMode, _encodeThemeMode(mode));
    notifyListeners();
  }

  Future<void> setUseFirebase(bool value) async {
    _useFirebase = value;
    await _store.setSetting(_kUseFirebase, value);
    notifyListeners();
  }

  static String _encodeThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

