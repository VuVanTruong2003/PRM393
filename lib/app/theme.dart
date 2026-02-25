import 'package:flutter/material.dart';

import '../core/app_ui.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F80ED)),
      scaffoldBackgroundColor: AppUI.softBg,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2F80ED),
        brightness: Brightness.dark,
      ),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}

