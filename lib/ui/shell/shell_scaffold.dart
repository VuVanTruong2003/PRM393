import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../models/transaction_entry.dart';
import '../../state/categories_controller.dart';
import '../../state/transactions_controller.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const _tabs = <_NavTab>[
    _NavTab(label: 'Trang chủ', icon: Icons.home_outlined, path: '/dashboard'),
    _NavTab(label: 'Chi tiêu', icon: Icons.receipt_long_outlined, path: '/transactions'),
    _NavTab(label: 'Báo cáo', icon: Icons.bar_chart_outlined, path: '/reports'),
    _NavTab(label: 'Cài đặt', icon: Icons.settings_outlined, path: '/settings'),
  ];

  int _locationToIndex(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _locationToIndex(location);

    void onSelect(int index) => context.go(_tabs[index].path);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;

        if (!wide) {
          return Scaffold(
            body: child,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showQuickAdd(context),
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BottomTab(
                        selected: selectedIndex == 0,
                        icon: _tabs[0].icon,
                        label: _tabs[0].label,
                        onTap: () => onSelect(0),
                      ),
                      _BottomTab(
                        selected: selectedIndex == 1,
                        icon: _tabs[1].icon,
                        label: _tabs[1].label,
                        onTap: () => onSelect(1),
                      ),
                      const SizedBox(width: 48), // space for FAB
                      _BottomTab(
                        selected: selectedIndex == 2,
                        icon: _tabs[2].icon,
                        label: _tabs[2].label,
                        onTap: () => onSelect(2),
                      ),
                      _BottomTab(
                        selected: selectedIndex == 3,
                        icon: _tabs[3].icon,
                        label: _tabs[3].label,
                        onTap: () => onSelect(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onSelect,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final tab in _tabs)
                    NavigationRailDestination(
                      icon: Icon(tab.icon),
                      label: Text(tab.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showQuickAdd(BuildContext context) async {
    // Quick add focuses on expense like the reference UI.
    final categoriesController = context.read<CategoriesController>();
    final expenseCategories = categoriesController.byType(CategoryType.expense);
    final txController = context.read<TransactionsController>();
    final tx = txController.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList(growable: false);

    final freq = <String, int>{};
    for (final t in tx) {
      freq[t.categoryId] = (freq[t.categoryId] ?? 0) + 1;
    }
    final popularIds = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final popular = <String>[];
    for (final e in popularIds) {
      if (popular.length >= 8) break;
      popular.add(e.key);
    }

    String? nameFor(String id) =>
        categoriesController.byId(id)?.name ??
        expenseCategories.where((c) => c.id == id).map((c) => c.name).firstOrNull;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Thêm nhanh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in popular)
                    ActionChip(
                      label: Text(nameFor(id) ?? 'Danh mục'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/transactions/new?categoryId=$id&type=expense');
                      },
                    ),
                  if (popular.isEmpty)
                    for (final c in expenseCategories.take(6))
                      ActionChip(
                        label: Text(c.name),
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go(
                            '/transactions/new?categoryId=${c.id}&type=expense',
                          );
                        },
                      ),
                  ActionChip(
                    label: const Text('Thêm chi tiêu'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/transactions/new?type=expense');
                    },
                  ),
                  ActionChip(
                    label: const Text('Thêm thu nhập'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/transactions/new?type=income');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

extension on Iterable<String> {
  String? get firstOrNull {
    for (final v in this) {
      return v;
    }
    return null;
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon, required this.path});

  final String label;
  final IconData icon;
  final String path;
}

class _BottomTab extends StatelessWidget {
  const _BottomTab({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, height: 1.0, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

