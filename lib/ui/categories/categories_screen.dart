import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../state/categories_controller.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryType _type = CategoryType.expense;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CategoriesController>();
    final categories = controller.byType(_type);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục'),
        actions: [
          IconButton(
            tooltip: 'Thêm danh mục',
            onPressed: () => _showCategoryDialog(context, type: _type),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(
                  value: CategoryType.expense,
                  label: Text('Chi'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: CategoryType.income,
                  label: Text('Thu'),
                  icon: Icon(Icons.add),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('Chưa có danh mục.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = categories[index];
                      return ListTile(
                        title: Text(c.name),
                        trailing: IconButton(
                          tooltip: 'Xoá',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.delete(c.id),
                        ),
                        onTap: () => _showCategoryDialog(
                          context,
                          type: c.type,
                          existing: c,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    required CategoryType type,
    Category? existing,
  }) async {
    final controller = context.read<CategoriesController>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Thêm danh mục' : 'Sửa danh mục'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên danh mục'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tên danh mục' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CategoryType>(
                key: ValueKey(type),
                initialValue: type,
                items: const [
                  DropdownMenuItem(
                    value: CategoryType.expense,
                    child: Text('Chi'),
                  ),
                  DropdownMenuItem(
                    value: CategoryType.income,
                    child: Text('Thu'),
                  ),
                ],
                onChanged: null,
                decoration: const InputDecoration(labelText: 'Loại'),
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

              if (existing == null) {
                await controller.create(name: name, type: type);
              } else {
                await controller.update(
                  Category(
                    id: existing.id,
                    name: name.trim(),
                    type: existing.type,
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
  }
}

