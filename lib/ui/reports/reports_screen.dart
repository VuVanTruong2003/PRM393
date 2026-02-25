import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/transaction_entry.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';
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
          SectionCard(
            color: const Color(0xFFEAF7EE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      Text(
                        '${diffPct.abs().toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Color(0xFF1B7F3A),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MiniMetric(
                        title: 'Tháng trước',
                        value: Formatters.money(expensePrev),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniMetric(
                        title: 'Tháng này',
                        value: Formatters.money(expenseThis),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'So sánh tháng',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: BarChart(
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
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final label = v == 0 ? 'Tháng trước' : 'Tháng này';
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
                              toY: expensePrev.toDouble(),
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
                              toY: expenseThis.toDouble(),
                              color: Colors.orange,
                              width: 26,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                const Text(
                  'Phân bổ chi tiêu theo danh mục',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (sections.isEmpty)
                  const Text('Chưa có dữ liệu chi tiêu cho tháng này.')
                else
                  SizedBox(
                    height: 260,
                    child: PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
              ],
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
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w900, color: color),
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

