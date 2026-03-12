import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../../core/formatters.dart';
import '../../models/budget.dart';
import '../../models/transaction_entry.dart';
import '../../state/accounts_controller.dart';
import '../../state/auth_controller.dart';
import '../../state/budgets_controller.dart';
import '../../state/transactions_controller.dart';
import '../../state/categories_controller.dart';
import '../widgets/animated_appear.dart';
import '../widgets/gradient_header.dart';
import '../widgets/home_widgets.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tx = context.watch<TransactionsController>();
    final categories = context.watch<CategoriesController>();
    final accounts = context.watch<AccountsController>();
    final budgets = context.watch<BudgetsController>();

    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final monthExpense = tx.totalExpenseForMonth(month);
    final monthIncome = tx.totalIncomeForMonth(month);
    final monthTransactions = tx.forMonth(month);
    final todayTransactions = monthTransactions
        .where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day)
        .toList(growable: false);
    final todayExpense = todayTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
    final recentTransactions = tx.transactions.take(3).toList(growable: false);

    final monthBudgets = budgets.forMonth(month);
    final budgetSpent = _budgetSpentByCategory(monthTransactions);
    final budgetUsage = _budgetUsage(monthBudgets, budgetSpent);
    final budgetAlert = monthBudgets
        .where((b) {
          final spent = budgetSpent[b.categoryId] ?? 0;
          return spent >= (b.limit * 0.8).round();
        })
        .toList(growable: false);

    final greeting = _greeting(now);
    final name = auth.user?.displayName?.trim().isNotEmpty == true
        ? auth.user!.displayName!.trim()
        : (auth.user?.email?.split('@').first ?? 'Bạn');

    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '☀️  $greeting',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hôm nay ${Formatters.day(now)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  child: Text(
                    name.isEmpty ? 'U' : name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                AnimatedAppear(
                  child: SectionCard(
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppUI.pastelBlue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.calendar_month_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hôm nay',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${Formatters.weekdayVi(now)}, ${Formatters.dayNumber(now)} tháng ${now.month}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Năm ${now.year}',
                                style: TextStyle(color: Theme.of(context).hintColor),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppUI.pastelGreen,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0x22000000)),
                          ),
                          child: const Text(
                            'Chi tiêu\nthông minh',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedAppear(
                  delay: const Duration(milliseconds: 70),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.flash_on_outlined),
                            SizedBox(width: 8),
                            Text(
                              'Thao tác nhanh',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.55,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            AnimatedAppear(
                              delay: const Duration(milliseconds: 120),
                              child: _QuickTile(
                                color: AppUI.pastelGreen,
                                icon: Icons.payments_outlined,
                                label: 'Thêm chi tiêu',
                                onTap: () => context.go('/transactions/new?type=expense'),
                              ),
                            ),
                            AnimatedAppear(
                              delay: const Duration(milliseconds: 160),
                              child: _QuickTile(
                                color: AppUI.pastelBlue,
                                icon: Icons.savings_outlined,
                                label: 'Tạo ngân sách',
                                onTap: () => context.go('/budgets'),
                              ),
                            ),
                            AnimatedAppear(
                              delay: const Duration(milliseconds: 200),
                              child: _QuickTile(
                                color: AppUI.pastelOrange,
                                icon: Icons.bar_chart_outlined,
                                label: 'Xem báo cáo',
                                onTap: () => context.go('/reports'),
                              ),
                            ),
                            AnimatedAppear(
                              delay: const Duration(milliseconds: 240),
                              child: _QuickTile(
                                color: AppUI.pastelPurple,
                                icon: Icons.settings_outlined,
                                label: 'Cài đặt',
                                onTap: () => context.go('/settings'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedAppear(
                  delay: const Duration(milliseconds: 120),
                  child: Text(
                    'Tổng quan nhanh',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedAppear(
                  delay: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      Expanded(
                        child: HomeMetricCard(
                          title: 'Thu tháng này',
                          value: Formatters.money(monthIncome),
                          subtitle:
                              '${monthTransactions.where((t) => t.type == TransactionType.income).length} giao dịch',
                          icon: Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                          onTap: () => context.go('/reports'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HomeMetricCard(
                          title: 'Chi tháng này',
                          value: Formatters.money(monthExpense),
                          subtitle:
                              '${monthTransactions.where((t) => t.type == TransactionType.expense).length} giao dịch',
                          icon: Icons.remove,
                          color: Theme.of(context).colorScheme.error,
                          onTap: () => context.go('/transactions'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedAppear(
                  delay: const Duration(milliseconds: 190),
                  child: Row(
                    children: [
                      Expanded(
                        child: HomeMetricCard(
                          title: 'Chi hôm nay',
                          value: Formatters.money(todayExpense),
                          subtitle: '${todayTransactions.length} giao dịch',
                          icon: Icons.today_outlined,
                          color: const Color(0xFF2F80ED),
                          onTap: () => context.go('/transactions'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HomeMetricCard(
                          title: 'Ngân sách đã dùng',
                          value: '${(budgetUsage * 100).toStringAsFixed(0)}%',
                          subtitle: monthBudgets.isEmpty
                              ? 'Chưa tạo ngân sách'
                              : '${monthBudgets.length} danh mục',
                          icon: Icons.savings_outlined,
                          color: Colors.orange,
                          onTap: () => context.go('/budgets'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedAppear(
                  delay: const Duration(milliseconds: 230),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: HomeInsightCard(
                      key: ValueKey(
                        '${budgetAlert.length}-$monthIncome-$monthExpense-${monthTransactions.length}',
                      ),
                      title: budgetAlert.isNotEmpty
                          ? 'Cảnh báo ngân sách'
                          : 'Smart insights',
                      message: budgetAlert.isNotEmpty
                          ? _budgetAlertMessage(budgetAlert, categories)
                          : _smartInsight(
                              monthIncome: monthIncome,
                              monthExpense: monthExpense,
                              txCount: monthTransactions.length,
                            ),
                      color: budgetAlert.isNotEmpty
                          ? Colors.orange
                          : const Color(0xFF1B7F3A),
                      icon: budgetAlert.isNotEmpty
                          ? Icons.warning_amber_rounded
                          : Icons.lightbulb_outline,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedAppear(
                  delay: const Duration(milliseconds: 270),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Giao dịch gần đây',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/transactions'),
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: recentTransactions.isEmpty
                      ? const SectionCard(
                          key: ValueKey('recent-empty'),
                          child: Text(
                            'Chưa có giao dịch nào. Hãy bắt đầu thêm chi tiêu đầu tiên.',
                          ),
                        )
                      : Column(
                          key: ValueKey('recent-${recentTransactions.length}'),
                          children: [
                            for (var i = 0; i < recentTransactions.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: AnimatedAppear(
                                  delay: Duration(milliseconds: 300 + (i * 50)),
                                  child: RecentTransactionCard(
                                    entry: recentTransactions[i],
                                    categoryName: categories
                                            .byId(recentTransactions[i].categoryId)
                                            ?.name ??
                                        'Khác',
                                    accountName: accounts
                                            .byId(recentTransactions[i].accountId)
                                            ?.name ??
                                        'Ví',
                                    onTap: () => context.go(
                                      '/transactions/${recentTransactions[i].id}/edit',
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _greeting(DateTime now) {
  final h = now.hour;
  if (h < 11) return 'Chào buổi sáng';
  if (h < 14) return 'Chào buổi trưa';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x22000000)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, int> _budgetSpentByCategory(List<TransactionEntry> entries) {
  final result = <String, int>{};
  for (final entry in entries) {
    if (entry.type != TransactionType.expense) continue;
    result[entry.categoryId] = (result[entry.categoryId] ?? 0) + entry.amount;
  }
  return result;
}

double _budgetUsage(List<Budget> budgets, Map<String, int> spentByCategory) {
  if (budgets.isEmpty) return 0;
  var totalBudget = 0;
  var totalSpent = 0;
  for (final b in budgets) {
    totalBudget += b.limit;
    totalSpent += spentByCategory[b.categoryId] ?? 0;
  }
  if (totalBudget <= 0) return 0;
  return (totalSpent / totalBudget).clamp(0.0, 1.0);
}

String _budgetAlertMessage(List<Budget> alerts, CategoriesController categories) {
  final first = alerts.first;
  final name = categories.byId(first.categoryId)?.name ?? 'Danh mục';
  if (alerts.length == 1) {
    return '$name đang sắp chạm hoặc vượt ngân sách tháng này. Hãy xem lại chi tiêu để cân đối tốt hơn.';
  }
  return '${alerts.length} danh mục đang sắp chạm hoặc vượt ngân sách. Bạn nên kiểm tra mục Ngân sách ngay.';
}

String _smartInsight({
  required int monthIncome,
  required int monthExpense,
  required int txCount,
}) {
  if (txCount == 0) {
    return 'Bạn chưa có giao dịch nào trong tháng này. Hãy ghi lại chi tiêu đầu tiên để bắt đầu theo dõi tài chính.';
  }
  if (monthIncome == 0 && monthExpense > 0) {
    return 'Tháng này bạn mới ghi nhận chi tiêu. Thêm thu nhập sẽ giúp báo cáo và cân đối ngân sách chính xác hơn.';
  }
  final net = monthIncome - monthExpense;
  if (net >= 0) {
    return 'Bạn đang tiết kiệm được ${Formatters.money(net)} trong tháng này. Đây là tín hiệu tài chính tích cực.';
  }
  return 'Chi tiêu hiện cao hơn thu nhập ${Formatters.money(net.abs())}. Bạn nên kiểm tra lại báo cáo để tối ưu ngân sách.';
}

