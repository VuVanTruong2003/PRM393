import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/transaction_entry.dart';
import '../../state/budgets_controller.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';
import '../widgets/section_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final budgetsController = context.watch<BudgetsController>();
    final categoriesController = context.watch<CategoriesController>();
    final txController = context.watch<TransactionsController>();

    final budgets = budgetsController.forMonth(_month);
    final expenseTx = txController
        .forMonth(_month)
        .where((t) => t.type == TransactionType.expense)
        .toList(growable: false);

    int spentFor(String categoryId) {
      var sum = 0;
      for (final t in expenseTx) {
        if (t.categoryId == categoryId) sum += t.amount;
      }
      return sum;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân sách'),
        actions: [
          IconButton(
            tooltip: 'Tháng',
            onPressed: () => _pickMonth(context),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: 'Thêm ngân sách',
            onPressed: () => _showBudgetDialog(context, month: _month),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tháng ${Formatters.month(_month)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => _pickMonth(context),
                  child: const Text('Đổi'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (budgets.isEmpty)
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chưa có ngân sách',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text('Hãy tạo ngân sách theo danh mục để theo dõi chi tiêu.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _showBudgetDialog(context, month: _month),
                    child: const Text('Tạo ngân sách'),
                  ),
                ],
              ),
            )
          else
            for (final b in budgets)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BudgetTile(
                  budget: b,
                  category: categoriesController.byId(b.categoryId),
                  spent: spentFor(b.categoryId),
                  onEdit: () => _showBudgetDialog(
                    context,
                    month: _month,
                    existing: b,
                  ),
                  onDelete: () => budgetsController.delete(b.id),
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

  Future<void> _showBudgetDialog(
    BuildContext context, {
    required DateTime month,
    Budget? existing,
  }) async {
    final budgetsController = context.read<BudgetsController>();
    final categoriesController = context.read<CategoriesController>();

    final expenseCategories = categoriesController.byType(CategoryType.expense);
    String? categoryId = existing?.categoryId ?? (expenseCategories.isEmpty ? null : expenseCategories.first.id);
    final limitController = TextEditingController(
      text: existing?.limit.toString() ?? '0',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Tạo ngân sách' : 'Sửa ngân sách'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: categoryId,
                items: [
                  for (final c in expenseCategories)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) => categoryId = v,
                validator: (v) => (v == null || v.isEmpty) ? 'Chọn danh mục' : null,
                decoration: const InputDecoration(labelText: 'Danh mục'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: limitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hạn mức (VND)'),
                validator: (v) {
                  final parsed = int.tryParse((v ?? '').trim());
                  if (parsed == null || parsed <= 0) return 'Nhập số hợp lệ';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final limit = int.tryParse(limitController.text.trim());
              if (limit == null) return;
              final selectedCategoryId = categoryId!;

              if (existing == null) {
                await budgetsController.create(
                  month: month,
                  categoryId: selectedCategoryId,
                  limit: limit,
                );
              } else {
                await budgetsController.update(
                  Budget(
                    id: existing.id,
                    monthKey: existing.monthKey,
                    categoryId: selectedCategoryId,
                    limit: limit,
                    createdAt: existing.createdAt,
                  ),
                );
              }

              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    limitController.dispose();
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.category,
    required this.spent,
    required this.onEdit,
    required this.onDelete,
  });

  final Budget budget;
  final Category? category;
  final int spent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final pct = budget.limit <= 0 ? 0.0 : (spent / budget.limit).clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;
    final warn = spent >= (budget.limit * 0.8).round();
    final over = spent > budget.limit;

    final color = over
        ? cs.error
        : warn
            ? Colors.orange
            : cs.primary;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category?.name ?? 'Danh mục',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Sửa',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Xoá',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${Formatters.money(spent)} / ${Formatters.money(budget.limit)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          if (over || warn) ...[
            const SizedBox(height: 8),
            Text(
              over
                  ? 'Bạn đã vượt ngân sách.'
                  : 'Bạn sắp hết ngân sách (>= 80%).',
              style: TextStyle(color: color),
            ),
          ],
        ],
      ),
    );
  }
}

