import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_ui.dart';
import '../../core/formatters.dart';
import '../../models/transaction_entry.dart';
import '../../state/accounts_controller.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';
import '../widgets/animated_appear.dart';
import '../widgets/section_card.dart';

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
    final filteredTotal = items.fold(0, (sum, t) => sum + t.amount);
    final groupedItems = _groupByDate(items);

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
            onPressed: () => _showFilterHelp(context),
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
          AnimatedAppear(
            child: SectionCard(
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
                          color: AppUI.pastelBlue,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          title: 'Tuần này',
                          value: Formatters.money(sumFor(_Range.week)),
                          subtitle: '${_countFor(tx, _Range.week, now)} giao dịch',
                          color: AppUI.pastelGreen,
                          icon: Icons.date_range_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          title: 'Tháng này',
                          value: Formatters.money(sumFor(_Range.month)),
                          subtitle: '${_countFor(tx, _Range.month, now)} giao dịch',
                          color: AppUI.pastelOrange,
                          icon: Icons.calendar_month_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedAppear(
            delay: const Duration(milliseconds: 60),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm (danh mục, ví, ghi chú)...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedAppear(
            delay: const Duration(milliseconds: 110),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _AnimatedFilterChip(
                    label: 'Tất cả',
                    selected: _range == _Range.all,
                    onTap: () => setState(() => _range = _Range.all),
                  ),
                  const SizedBox(width: 8),
                  _AnimatedFilterChip(
                    label: 'Hôm nay',
                    selected: _range == _Range.today,
                    onTap: () => setState(() => _range = _Range.today),
                  ),
                  const SizedBox(width: 8),
                  _AnimatedFilterChip(
                    label: 'Tuần này',
                    selected: _range == _Range.week,
                    onTap: () => setState(() => _range = _Range.week),
                  ),
                  const SizedBox(width: 8),
                  _AnimatedFilterChip(
                    label: 'Tháng',
                    selected: _range == _Range.month,
                    onTap: () => setState(() => _range = _Range.month),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedAppear(
            delay: const Duration(milliseconds: 160),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3C72A3), Color(0xFF2E5B7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 10),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
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
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: filteredTotal.toDouble()),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          Formatters.money(value.round()),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${items.length} giao dịch',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: items.isEmpty
                ? SectionCard(
                    key: const ValueKey('empty'),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        const Icon(Icons.receipt_long_outlined, size: 42),
                        const SizedBox(height: 10),
                        const Text(
                          'Chưa có dữ liệu phù hợp.',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hãy thêm một khoản chi hoặc đổi bộ lọc để xem dữ liệu.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () => context.go('/transactions/new?type=expense'),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm chi tiêu'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    key: ValueKey('list-${_range.name}-${_query.trim()}-${items.length}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < groupedItems.length; i++) ...[
                        Padding(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 12, bottom: 8),
                          child: Text(
                            _groupLabel(groupedItems[i].date, now),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        for (var j = 0; j < groupedItems[i].entries.length; j++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AnimatedAppear(
                              delay: Duration(milliseconds: 60 * (j + (i * 2))),
                              child: _ExpenseTile(
                                entry: groupedItems[i].entries[j],
                                categoryName: categories
                                        .byId(groupedItems[i].entries[j].categoryId)
                                        ?.name ??
                                    'Chưa chọn danh mục',
                                accountName: accounts
                                        .byId(groupedItems[i].entries[j].accountId)
                                        ?.name ??
                                    'Chưa chọn ví',
                                onTap: () => context.go(
                                  '/transactions/${groupedItems[i].entries[j].id}/edit',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Bộ lọc nhanh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text('Bạn có thể lọc theo hôm nay, tuần này, tháng này và tìm kiếm theo danh mục, ví hoặc ghi chú.'),
          ],
        ),
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

class _DateGroup {
  const _DateGroup({required this.date, required this.entries});

  final DateTime date;
  final List<TransactionEntry> entries;
}

List<_DateGroup> _groupByDate(List<TransactionEntry> items) {
  final map = <DateTime, List<TransactionEntry>>{};
  for (final item in items) {
    final key = DateTime(item.date.year, item.date.month, item.date.day);
    map.putIfAbsent(key, () => <TransactionEntry>[]).add(item);
  }
  final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final key in keys) _DateGroup(date: key, entries: map[key]!),
  ];
}

String _groupLabel(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);
  if (d == today) return 'Hôm nay';
  if (d == yesterday) return 'Hôm qua';
  return '${Formatters.weekdayVi(date)}, ${Formatters.day(date)}';
}

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

class _AnimatedFilterChip extends StatelessWidget {
  const _AnimatedFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
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
    final amountColor = Theme.of(context).colorScheme.error;

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
                color: const Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.remove),
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
              '-${Formatters.money(entry.amount)}',
              style: TextStyle(fontWeight: FontWeight.w900, color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}

