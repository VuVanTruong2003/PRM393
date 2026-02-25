import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/formatters.dart';
import '../../models/account.dart';
import '../../state/accounts_controller.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AccountsController>();
    final accounts = controller.accounts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví'),
        actions: [
          IconButton(
            tooltip: 'Thêm ví',
            onPressed: () => _showAccountDialog(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: accounts.isEmpty
          ? const Center(child: Text('Chưa có ví.'))
          : ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: accounts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final a = accounts[index];
                return ListTile(
                  title: Text(a.name),
                  subtitle: Text('Số dư ban đầu: ${Formatters.money(a.balanceStart)}'),
                  trailing: IconButton(
                    tooltip: 'Xoá',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.delete(a.id),
                  ),
                  onTap: () => _showAccountDialog(context, existing: a),
                );
              },
            ),
    );
  }

  Future<void> _showAccountDialog(
    BuildContext context, {
    Account? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final balanceController = TextEditingController(
      text: existing?.balanceStart.toString() ?? '0',
    );
    final formKey = GlobalKey<FormState>();

    final controller = context.read<AccountsController>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Thêm ví' : 'Sửa ví'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên ví'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tên ví' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số dư ban đầu'),
                validator: (v) =>
                    int.tryParse((v ?? '').trim()) == null ? 'Nhập số' : null,
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
              final name = nameController.text;
              final balanceStart = int.parse(balanceController.text.trim());

              if (existing == null) {
                await controller.create(name: name, balanceStart: balanceStart);
              } else {
                await controller.update(
                  Account(
                    id: existing.id,
                    name: name.trim(),
                    balanceStart: balanceStart,
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

    nameController.dispose();
    balanceController.dispose();
  }
}

