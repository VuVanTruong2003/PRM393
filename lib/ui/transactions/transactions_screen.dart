import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/transaction_entry.dart';
import '../widgets/section_card.dart';
import '../../state/accounts_controller.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  _Range _range = _Range.all;

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionsController>();
    final categories = context.watch<CategoriesController>();
    final accounts = context.watch<AccountsController>();

    final now = DateTime.now();
    final items = tx.transactions
        .where((t) => t.type == TransactionType.expense)
        .where((t) {
      if (_range == _Range.today) {
        return t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day;
      }
      if (_range == _Range.week) {
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return !t.date.isBefore(start) && t.date.isBefore(end);
      }
      if (_range == _Range.month) {
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1);
        return !t.date.isBefore(start) && t.date.isBefore(end);
      }
      return true;
    })
        .where((t) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      final cat = categories.byId(t.categoryId)?.name.toLowerCase() ?? '';
      final acc = accounts.byId(t.accountId)?.name.toLowerCase() ?? '';
      final note = t.note.toLowerCase();
      return cat.contains(q) || acc.contains(q) || note.contains(q);
    })
        .toList(growable: false);

    int sumFor(_Range r) {
      Iterable<TransactionEntry> base = tx.transactions
          .where((t) => t.type == TransactionType.expense);
      if (r == _Range.today) {
        base = base.where((t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day);
      } else if (r == _Range.week) {
        final start = now.subtract(Duration(days: now.weekday - 1));
        final end = start.add(const Duration(days: 7));
        base = base.where((t) => !t.date.isBefore(start) && t.date.isBefore(end));
      } else if (r == _Range.month) {
        final start = DateTime(now.year, now.month);
        final end = DateTime(now.year, now.month + 1);
        base = base.where((t) => !t.date.isBefore(start) && t.date.isBefore(end));
      }
      return base.fold(0, (sum, t) => sum + t.amount);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiêu'),
        actions: [
          IconButton(
            tooltip: 'Lọc',
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          IconButton(
            tooltip: 'Thêm',
            onPressed: () => context.go('/transactions/new?type=expense'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Thống kê nhanh',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        title: 'Hôm nay',
                        value: Formatters.money(sumFor(_Range.today)),
                        subtitle: '${_countFor(tx, _Range.today, now)} giao dịch',
                        color: const Color(0xFFEAF2FF),
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        title: 'Tuần này',
                        value: Formatters.money(sumFor(_Range.week)),
                        subtitle: '${_countFor(tx, _Range.week, now)} giao dịch',
                        color: const Color(0xFFEAF7EE),
                        icon: Icons.date_range_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        title: 'Tháng này',
                        value: Formatters.money(sumFor(_Range.month)),
                        subtitle: '${_countFor(tx, _Range.month, now)} giao dịch',
                        color: const Color(0xFFFFF3E6),
                        icon: Icons.calendar_month_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm (danh mục, ví, ghi chú)...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _ChoiceChip(
                label: 'Tất cả',
                selected: _range == _Range.all,
                onTap: () => setState(() => _range = _Range.all),
              ),
              _ChoiceChip(
                label: 'Hôm nay',
                selected: _range == _Range.today,
                onTap: () => setState(() => _range = _Range.today),
              ),
              _ChoiceChip(
                label: 'Tuần này',
                selected: _range == _Range.week,
                onTap: () => setState(() => _range = _Range.week),
              ),
              _ChoiceChip(
                label: 'Tháng',
                selected: _range == _Range.month,
                onTap: () => setState(() => _range = _Range.month),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SectionCard(
            color: const Color(0xFF2E5B7D),
            child: Column(
              children: [
                const Text(
                  'Tổng chi tiêu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.money(
                    items.fold(0, (sum, t) => sum + t.amount),
                  ),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${items.length} giao dịch',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(child: Text('Chưa có dữ liệu phù hợp.')),
            )
          else
            for (final t in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ExpenseTile(
                  entry: t,
                  categoryName:
                      categories.byId(t.categoryId)?.name ?? 'Chưa chọn danh mục',
                  accountName:
                      accounts.byId(t.accountId)?.name ?? 'Chưa chọn ví',
                  onTap: () => context.go('/transactions/${t.id}/edit'),
                ),
              ),
        ],
      ),
    );
  }
}

int _countFor(TransactionsController tx, _Range r, DateTime now) {
  Iterable<TransactionEntry> base =
      tx.transactions.where((t) => t.type == TransactionType.expense);
  if (r == _Range.today) {
    base = base.where((t) =>
        t.date.year == now.year && t.date.month == now.month && t.date.day == now.day);
  } else if (r == _Range.week) {
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    base = base.where((t) => !t.date.isBefore(start) && t.date.isBefore(end));
  } else if (r == _Range.month) {
    final start = DateTime(now.year, now.month);
    final end = DateTime(now.year, now.month + 1);
    base = base.where((t) => !t.date.isBefore(start) && t.date.isBefore(end));
  }
  return base.length;
}

enum _Range { all, today, week, month }

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.entry,
    required this.categoryName,
    required this.accountName,
    required this.onTap,
  });

  final TransactionEntry entry;
  final String categoryName;
  final String accountName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == TransactionType.income;
    final amountColor = isIncome
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isIncome ? const Color(0xFFEAF7EE) : const Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(isIncome ? Icons.add : Icons.remove),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.day(entry.date)} • $accountName'
                    '${entry.note.isEmpty ? '' : ' • ${entry.note}'}',
                    style: TextStyle(color: Theme.of(context).hintColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              (isIncome ? '+' : '-') + Formatters.money(entry.amount),
              style: TextStyle(fontWeight: FontWeight.w900, color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}

