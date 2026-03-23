import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction_entry.dart';
import '../../state/accounts_controller.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';
import '../widgets/section_card.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({
    super.key,
    this.id,
    this.initialType,
    this.initialCategoryId,
  });

  final String? id;
  final TransactionType? initialType;
  final String? initialCategoryId;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _accountId;
  String? _categoryId;
  DateTime _date = DateTime.now();
  bool _loadedExisting = false;
  bool _loadedInitials = false;
  List<String> _attachmentUrls = const [];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedInitials) {
      _type = widget.initialType ?? _type;
      _categoryId = widget.initialCategoryId ?? _categoryId;
      _loadedInitials = true;
    }

    if (_loadedExisting) return;
    final tx = context.read<TransactionsController>();
    final existing = widget.id == null ? null : tx.byId(widget.id!);
    if (existing == null) return;

    _type = existing.type;
    _accountId = existing.accountId;
    _categoryId = existing.categoryId;
    _date = existing.date;
    _amountController.text = existing.amount.toString();
    _noteController.text = existing.note;
    _attachmentUrls = existing.attachmentUrls;
    _loadedExisting = true;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountsController>().accounts;
    final categoriesController = context.watch<CategoriesController>();
    final txController = context.watch<TransactionsController>();

    final isEditing = widget.id != null;
    final categoryType =
        _type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    final categories = categoriesController.byType(categoryType);
    final canCreate = accounts.isNotEmpty && categories.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        actions: [
          TextButton(
            onPressed: canCreate ? () => _submit(context, txController, isEditing) : null,
            child: const Text('Lưu'),
          ),
          if (isEditing)
            IconButton(
              tooltip: 'Xoá',
              onPressed: () async {
                await txController.delete(widget.id!);
                if (context.mounted) context.pop();
              },
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: canCreate ? () => _submit(context, txController, isEditing) : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(isEditing ? 'Lưu giao dịch' : 'Thêm giao dịch'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          if (!canCreate) ...[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn cần tạo ít nhất 1 ví và 1 danh mục trước khi thêm giao dịch.',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/accounts'),
                          child: const Text('Tạo ví'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go('/categories'),
                          child: const Text('Tạo danh mục'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TypeChip(
                          label: 'Chi tiêu',
                          selected: _type == TransactionType.expense,
                          onTap: () => setState(() {
                            _type = TransactionType.expense;
                            _categoryId = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _TypeChip(
                          label: 'Thu nhập',
                          selected: _type == TransactionType.income,
                          onTap: () => setState(() {
                            _type = TransactionType.income;
                            _categoryId = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel('Số tiền ${_type == TransactionType.expense ? 'chi tiêu' : 'thu nhập'}'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    hintText: 'Nhập số tiền',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    final parsed = int.tryParse((v ?? '').trim());
                    if (parsed == null || parsed <= 0) return 'Nhập số tiền hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _FieldLabel('Danh mục'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey('category-${_categoryId ?? "null"}'),
                  initialValue: _categoryId,
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: canCreate ? (v) => setState(() => _categoryId = v) : null,
                  decoration: const InputDecoration(
                    hintText: 'Chọn danh mục',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Chọn danh mục' : null,
                ),
                const SizedBox(height: 16),
                _FieldLabel('Ví'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey('account-${_accountId ?? "null"}'),
                  initialValue: _accountId,
                  items: [
                    for (final a in accounts)
                      DropdownMenuItem(value: a.id, child: Text(a.name)),
                  ],
                  onChanged: canCreate ? (v) => setState(() => _accountId = v) : null,
                  decoration: const InputDecoration(
                    hintText: 'Chọn ví',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Chọn ví' : null,
                ),
                const SizedBox(height: 16),
                _FieldLabel('Ngày ${_type == TransactionType.expense ? 'chi tiêu' : 'ghi nhận'}'),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: _date,
                    );
                    if (picked == null) return;
                    setState(() => _date = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(
                      Formatters.day(_date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel('Mô tả (tuỳ chọn)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mô tả...',
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _AttachmentsCard(
                  urls: _attachmentUrls,
                  onAdd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chưa bật upload ảnh. Bước tiếp theo mình sẽ tích hợp Cloudinary.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    TransactionsController txController,
    bool isEditing,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null) return;

    if (isEditing) {
      final old = txController.byId(widget.id!);
      if (old == null) return;
      await txController.update(
        TransactionEntry(
          id: old.id,
          type: _type,
          accountId: _accountId!,
          categoryId: _categoryId!,
          amount: amount,
          date: _date,
          note: _noteController.text,
          attachmentUrls: _attachmentUrls,
          createdAt: old.createdAt,
        ),
      );
    } else {
      await txController.create(
        type: _type,
        accountId: _accountId!,
        categoryId: _categoryId!,
        amount: amount,
        date: _date,
        note: _noteController.text,
      );
    }

    if (context.mounted) context.pop();
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
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
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard({required this.urls, required this.onAdd});

  final List<String> urls;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hóa đơn/Ảnh (tuỳ chọn)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (urls.isEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onAdd,
              child: Container(
                height: 124,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 32),
                    SizedBox(height: 8),
                    Text('Thêm ảnh hóa đơn'),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final _ in urls)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_outlined),
                  ),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

