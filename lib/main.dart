import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'services/local/hive_store.dart';
import 'state/accounts_controller.dart';
import 'state/app_config.dart';
import 'state/auth_controller.dart';
import 'state/budgets_controller.dart';
import 'state/categories_controller.dart';
import 'state/notification_settings_controller.dart';
import 'state/transactions_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final store = HiveStore();
  await store.init();

  final appConfig = AppConfig.fromStore(store);
  final authController = AuthController(appConfig: appConfig);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: store),
        ChangeNotifierProvider.value(value: appConfig),
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider(
          create: (context) => AccountsController(store: store),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoriesController(store: store),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionsController(store: store),
        ),
        ChangeNotifierProvider(
          create: (context) => BudgetsController(store: store),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationSettingsController(store: store),
        ),
      ],
      child: const FinanceApp(),
    ),
  );
}
