import 'package:flutter/material.dart';

import '../services/local/hive_store.dart';

class AppConfig extends ChangeNotifier {
  AppConfig({
    required HiveStore store,
    required ThemeMode themeMode,
  })  : _store = store,
        _themeMode = themeMode;

  static const _kThemeMode = 'themeMode';

  final HiveStore _store;
  ThemeMode _themeMode;

  static AppConfig fromStore(HiveStore store) {
    final rawTheme = store.getSetting<String>(_kThemeMode);
    final themeMode = switch (rawTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return AppConfig(store: store, themeMode: themeMode);
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _store.setSetting(_kThemeMode, _encodeThemeMode(mode));
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

