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
import 'state/profile_controller.dart';
import 'state/transactions_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final store = HiveStore();
  await store.init();

  final appConfig = AppConfig.fromStore(store);
  final authController = AuthController();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: store),
        ChangeNotifierProvider.value(value: appConfig),
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider(
          create: (context) => AccountsController(
            authController: authController,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoriesController(
            authController: authController,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionsController(
            authController: authController,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BudgetsController(
            authController: authController,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationSettingsController(store: store),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileController(authController: authController),
        ),
      ],
      child: const FinanceApp(),
    ),
  );
}
