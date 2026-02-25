import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../../core/formatters.dart';
import '../../state/auth_controller.dart';
import '../../state/transactions_controller.dart';
import '../../state/categories_controller.dart';
import '../widgets/gradient_header.dart';
import '../widgets/section_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final tx = context.watch<TransactionsController>();
    context.watch<CategoriesController>(); // keep reactive for future use

    final now = DateTime.now();
    final month = DateTime(now.year, now.month);
    final monthExpense = tx.totalExpenseForMonth(month);
    final monthIncome = tx.totalIncomeForMonth(month);

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
                SectionCard(
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
                            Text(
                              'Tháng ${month.month}/${month.year}',
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                      Container(
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
                const SizedBox(height: 16),
                SectionCard(
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
                          _QuickTile(
                            color: AppUI.pastelGreen,
                            icon: Icons.payments_outlined,
                            label: 'Thêm chi tiêu',
                            onTap: () => context.go('/transactions/new?type=expense'),
                          ),
                          _QuickTile(
                            color: AppUI.pastelBlue,
                            icon: Icons.savings_outlined,
                            label: 'Tạo ngân sách',
                            onTap: () => context.go('/budgets'),
                          ),
                          _QuickTile(
                            color: AppUI.pastelOrange,
                            icon: Icons.bar_chart_outlined,
                            label: 'Xem báo cáo',
                            onTap: () => context.go('/reports'),
                          ),
                          _QuickTile(
                            color: AppUI.pastelPurple,
                            icon: Icons.settings_outlined,
                            label: 'Cài đặt',
                            onTap: () => context.go('/settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tổng quan nhanh',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatPill(
                        title: 'Thu tháng này',
                        value: Formatters.money(monthIncome),
                        icon: Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatPill(
                        title: 'Chi tháng này',
                        value: Formatters.money(monthExpense),
                        icon: Icons.remove,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
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

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

