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
import '../ui/profile/profile_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/shell/shell_scaffold.dart';
import '../ui/splash/splash_screen.dart';
import '../ui/transactions/edit_transaction_screen.dart';
import '../ui/transactions/transactions_screen.dart';

class AppRouter {
  GoRouter router({
    required AuthController auth,
    required AppConfig config,
  }) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: Listenable.merge([auth, config]),
      redirect: (context, state) {
        final isLoggingIn = state.matchedLocation == '/login';
        final isSplash = state.matchedLocation == '/splash';
        final isSignedIn = auth.isSignedIn;

        if (isSplash) return null;

        if (!isSignedIn) {
          return isLoggingIn ? null : '/login';
        }

        if (isLoggingIn) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) =>
              _fadePage(state: state, child: const SplashScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              _fadePage(state: state, child: const LoginScreen()),
        ),
        ShellRoute(
          builder: (context, state, child) => ShellScaffold(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) =>
                  _tabPage(state: state, child: const DashboardScreen()),
            ),
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) =>
                  _tabPage(state: state, child: const TransactionsScreen()),
              routes: [
                GoRoute(
                  path: 'new',
                  pageBuilder: (context, state) {
                    final qp = state.uri.queryParameters;
                    final typeRaw = qp['type'];
                    final initialType = typeRaw == null
                        ? null
                        : (typeRaw == 'income'
                            ? TransactionType.income
                            : TransactionType.expense);
                    return _upPage(
                      state: state,
                      child: EditTransactionScreen(
                        initialType: initialType,
                        initialCategoryId: qp['categoryId'],
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: ':id/edit',
                  pageBuilder: (context, state) => _upPage(
                    state: state,
                    child: EditTransactionScreen(id: state.pathParameters['id']),
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/reports',
              pageBuilder: (context, state) =>
                  _tabPage(state: state, child: const ReportsScreen()),
            ),
            GoRoute(
              path: '/budgets',
              pageBuilder: (context, state) =>
                  _slidePage(state: state, child: const BudgetsScreen()),
            ),
            GoRoute(
              path: '/accounts',
              pageBuilder: (context, state) =>
                  _slidePage(state: state, child: const AccountsScreen()),
            ),
            GoRoute(
              path: '/categories',
              pageBuilder: (context, state) =>
                  _slidePage(state: state, child: const CategoriesScreen()),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  _tabPage(state: state, child: const SettingsScreen()),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  _slidePage(state: state, child: const ProfileScreen()),
            ),
          ],
        ),
      ],
    );
  }

  CustomTransitionPage<void> _fadePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  CustomTransitionPage<void> _tabPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0.03, 0),
          end: Offset.zero,
        ).animate(curved);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }

  CustomTransitionPage<void> _slidePage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved);
        return SlideTransition(position: offset, child: child);
      },
    );
  }

  CustomTransitionPage<void> _upPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: offset, child: child),
        );
      },
    );
  }
}

