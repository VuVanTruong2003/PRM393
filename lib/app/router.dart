import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../state/app_config.dart';
import '../state/auth_controller.dart';
import '../models/transaction_entry.dart';
import '../ui/accounts/accounts_screen.dart';
import '../ui/auth/login_screen.dart';
import '../ui/budgets/budgets_screen.dart';
import '../ui/categories/categories_screen.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/reports/reports_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/shell/shell_scaffold.dart';
import '../ui/transactions/edit_transaction_screen.dart';
import '../ui/transactions/transactions_screen.dart';

class AppRouter {
  GoRouter router({
    required AuthController auth,
    required AppConfig config,
  }) {
    return GoRouter(
      initialLocation: '/dashboard',
      refreshListenable: Listenable.merge([auth, config]),
      redirect: (context, state) {
        final isLoggingIn = state.matchedLocation == '/login';
        final isSignedIn = auth.isSignedIn;

        if (!isSignedIn) {
          return isLoggingIn ? null : '/login';
        }

        if (isLoggingIn) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => ShellScaffold(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/transactions',
              builder: (context, state) => const TransactionsScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) {
                    final qp = state.uri.queryParameters;
                    final typeRaw = qp['type'];
                    final initialType = typeRaw == null
                        ? null
                        : (typeRaw == 'income'
                            ? TransactionType.income
                            : TransactionType.expense);
                    return EditTransactionScreen(
                      initialType: initialType,
                      initialCategoryId: qp['categoryId'],
                    );
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  builder: (context, state) =>
                      EditTransactionScreen(id: state.pathParameters['id']),
                ),
              ],
            ),
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsScreen(),
            ),
            GoRoute(
              path: '/budgets',
              builder: (context, state) => const BudgetsScreen(),
            ),
            GoRoute(
              path: '/accounts',
              builder: (context, state) => const AccountsScreen(),
            ),
            GoRoute(
              path: '/categories',
              builder: (context, state) => const CategoriesScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

