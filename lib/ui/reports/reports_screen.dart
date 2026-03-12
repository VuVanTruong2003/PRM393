import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/transaction_entry.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';
import '../widgets/animated_appear.dart';
import '../widgets/section_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionsController>();
    final categories = context.watch<CategoriesController>();

    final prevMonth = DateTime(_month.year, _month.month - 1);
    final expenseThis = tx.totalExpenseForMonth(_month);
    final expensePrev = tx.totalExpenseForMonth(prevMonth);

    final diffPct = expensePrev == 0
        ? null
        : ((expenseThis - expensePrev) / expensePrev) * 100.0;

    final monthTx = tx.forMonth(_month);
    final sums = <String, int>{};
    var total = 0;
    for (final t in monthTx) {
      if (t.type != TransactionType.expense) continue;
      sums[t.categoryId] = (sums[t.categoryId] ?? 0) + t.amount;
      total += t.amount;
    }
    final top = sums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < top.length && i < 6; i++) {
      final e = top[i];
      final name = categories.byId(e.key)?.name ?? 'Khác';
      final pct = total == 0 ? 0.0 : (e.value / total) * 100.0;
      sections.add(
        PieChartSectionData(
          value: e.value.toDouble(),
          title: '${pct.toStringAsFixed(1)}%',
          radius: 55,
          color: colors[i % colors.length],
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          badgeWidget: _LegendDot(label: name, color: colors[i % colors.length]),
          badgePositionPercentageOffset: 1.35,
        ),
      );
    }
    final animationKey =
        '${_month.year}-${_month.month}-$expensePrev-$expenseThis-$total-${sections.length}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        actions: [
          IconButton(
            tooltip: 'Chia sẻ',
            onPressed: () {},
            icon: const Icon(Icons.ios_share_outlined),
          ),
          _MonthDropdown(
            month: _month,
            onChanged: (m) => setState(() => _month = m),
          ),
          IconButton(
            tooltip: 'Chọn tháng',
            onPressed: () => _pickMonth(context),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AnimatedAppear(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tháng ${_month.month}/${_month.year}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedAppear(
            delay: const Duration(milliseconds: 70),
            child: SectionCard(
              color: const Color(0xFFEAF7EE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'So sánh tháng',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.trending_down, color: Color(0xFF1B7F3A)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          diffPct == null
                              ? 'So sánh tháng'
                              : (diffPct <= 0
                                  ? 'Chi tiêu giảm'
                                  : 'Chi tiêu tăng'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF1B7F3A),
                          ),
                        ),
                      ),
                      if (diffPct != null)
                        TweenAnimationBuilder<double>(
                          key: ValueKey('pct-$animationKey'),
                          tween: Tween<double>(begin: 0, end: diffPct.abs()),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '${value.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                color: Color(0xFF1B7F3A),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniMetric(
                          title: 'Tháng trước',
                          amount: expensePrev,
                          color: Colors.blue,
                          animationKey: 'prev-$animationKey',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniMetric(
                          title: 'Tháng này',
                          amount: expenseThis,
                          color: Colors.orange,
                          animationKey: 'now-$animationKey',
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
            delay: const Duration(milliseconds: 130),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xu hướng chi tiêu',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhấn vào cột để xem chi tiết',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('bar-$animationKey'),
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeOutCubic,
                      builder: (context, progress, child) {
                        return BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: true),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: true, reservedSize: 40),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (v, meta) {
                                    final label =
                                        v == 0 ? 'Tháng trước' : 'Tháng này';
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(label),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: expensePrev * progress,
                                    color: Colors.blue,
                                    width: 26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: expenseThis * progress,
                                    color: Colors.orange,
                                    width: 26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedAppear(
            delay: const Duration(milliseconds: 190),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phân bổ chi tiêu theo danh mục',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhấn vào danh mục để xem chi tiết',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: sections.isEmpty
                        ? const Text(
                            'Chưa có dữ liệu chi tiêu cho tháng này.',
                            key: ValueKey('pie-empty'),
                          )
                        : SizedBox(
                            key: ValueKey('pie-$animationKey'),
                            height: 260,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              builder: (context, progress, child) {
                                return PieChart(
                                  PieChartData(
                                    sections: [
                                      for (final section in sections)
                                        section.copyWith(
                                          value: section.value * progress,
                                          title: progress > 0.85 ? section.title : '',
                                        ),
                                    ],
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  if (top.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Chi tiêu theo danh mục',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      key: ValueKey('total-$animationKey'),
                      tween: Tween<double>(begin: 0, end: total.toDouble()),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          'Tổng: ${Formatters.money(value.round())}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < top.length && i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AnimatedAppear(
                          delay: Duration(milliseconds: 240 + (i * 40)),
                          child: _CategoryProgressRow(
                            label: categories.byId(top[i].key)?.name ?? 'Khác',
                            amount: top[i].value,
                            total: total,
                            color: colors[i % colors.length],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày bất kỳ trong tháng',
    );
    if (picked == null) return;
    setState(() => _month = DateTime(picked.year, picked.month));
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.title,
    required this.amount,
    required this.color,
    required this.animationKey,
  });

  final String title;
  final int amount;
  final Color color;
  final String animationKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          key: ValueKey(animationKey),
          tween: Tween<double>(begin: 0, end: amount.toDouble()),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Text(
              Formatters.money(value.round()),
              style: TextStyle(fontWeight: FontWeight.w900, color: color),
            );
          },
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  const _MonthDropdown({required this.month, required this.onChanged});

  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = <DateTime>[];
    for (var i = 0; i < 12; i++) {
      months.add(DateTime(now.year, now.month - i));
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<DateTime>(
        borderRadius: BorderRadius.circular(16),
        value: months.firstWhere(
          (m) => m.year == month.year && m.month == month.month,
          orElse: () => months.first,
        ),
        items: [
          for (final m in months)
            DropdownMenuItem(
              value: m,
              child: Text('Tháng ${m.month}/${m.year}'),
            ),
        ],
        onChanged: (v) {
          if (v == null) return;
          onChanged(DateTime(v.year, v.month));
        },
      ),
    );
  }
}

class _CategoryProgressRow extends StatelessWidget {
  const _CategoryProgressRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  final String label;
  final int amount;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : amount / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              Formatters.money(amount),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

