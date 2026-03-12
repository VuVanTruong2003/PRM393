import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../models/transaction_entry.dart';
import 'section_card.dart';

class HomeMetricCard extends StatelessWidget {
  const HomeMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SectionCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeInsightCard extends StatelessWidget {
  const HomeInsightCard({
    super.key,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });

  final String title;
  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: color.withValues(alpha: 0.12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentTransactionCard extends StatelessWidget {
  const RecentTransactionCard({
    super.key,
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

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            const SizedBox(width: 10),
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

