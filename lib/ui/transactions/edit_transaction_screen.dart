import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/transaction_entry.dart';
import '../../state/accounts_controller.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        actions: [
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (accounts.isEmpty || categoriesController.categories.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Bạn cần tạo ít nhất 1 ví và 1 danh mục trước khi thêm giao dịch.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<TransactionType>(
                  key: ValueKey('type-${_type.name}'),
                  initialValue: _type,
                  items: const [
                    DropdownMenuItem(
                      value: TransactionType.expense,
                      child: Text('Chi'),
                    ),
                    DropdownMenuItem(
                      value: TransactionType.income,
                      child: Text('Thu'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _type = v;
                      _categoryId = null;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Loại'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tiền'),
                  validator: (v) {
                    final parsed = int.tryParse((v ?? '').trim());
                    if (parsed == null || parsed <= 0) return 'Nhập số tiền hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('account-${_accountId ?? "null"}'),
                  initialValue: _accountId,
                  items: [
                    for (final a in accounts)
                      DropdownMenuItem(value: a.id, child: Text(a.name)),
                  ],
                  onChanged: (v) => setState(() => _accountId = v),
                  decoration: const InputDecoration(labelText: 'Ví'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Chọn ví' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('category-${_categoryId ?? "null"}'),
                  initialValue: _categoryId,
                  items: [
                    for (final c in categories)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Chọn danh mục' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ngày'),
                  subtitle: Text(Formatters.day(_date)),
                  trailing: const Icon(Icons.calendar_month_outlined),
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
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _AttachmentsCard(
                  urls: _attachmentUrls,
                  onAdd: () {
                    // TODO: Cloudinary upload + picker (sẽ làm ở bước tiếp theo)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Chưa bật upload ảnh. Bước tiếp theo mình sẽ tích hợp Cloudinary.',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;
                      final amount = int.parse(_amountController.text.trim());

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
                    },
                    child: Text(isEditing ? 'Lưu' : 'Tạo giao dịch'),
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

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard({required this.urls, required this.onAdd});

  final List<String> urls;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hóa đơn/Ảnh (tuỳ chọn)',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (urls.isEmpty)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onAdd,
                child: Container(
                  height: 90,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x22000000)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined),
                      SizedBox(height: 6),
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
      ),
    );
  }
}

