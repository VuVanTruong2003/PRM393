import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/app_config.dart';
import '../state/auth_controller.dart';
import 'router.dart';
import 'theme.dart';

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  late final AppRouter _appRouter;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final config = context.watch<AppConfig>();

    _router ??= _appRouter.router(auth: auth, config: config);
    return MaterialApp.router(
      title: 'Personal Finance',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: config.themeMode,
      routerConfig: _router,
    );
  }
}

