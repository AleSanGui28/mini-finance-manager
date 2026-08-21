import 'package:flutter/material.dart';

import '../../expenses/data/repository/expense_repository.dart';
import '../../expenses/domain/expense.dart';
import '../../incomes/data/repository/income_repository.dart';
import '../../incomes/domain/income.dart';
import '../../shared/domain/money_currency.dart';
import '../domain/balance_calculator.dart';
import '../domain/balance_status.dart';
import '../domain/balance_summary.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({
    super.key,
    required this.incomeRepository,
    required this.expenseRepository,
  });

  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Balance'), elevation: 0),
      body: StreamBuilder<List<Income>>(
        stream: incomeRepository.watchIncomes(),
        builder: (context, incomeSnapshot) {
          if (incomeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (incomeSnapshot.hasError) {
            return Center(child: Text('Error: ${incomeSnapshot.error}'));
          }

          return StreamBuilder<List<Expense>>(
            stream: expenseRepository.watchExpenses(),
            builder: (context, expenseSnapshot) {
              if (expenseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (expenseSnapshot.hasError) {
                return Center(child: Text('Error: ${expenseSnapshot.error}'));
              }

              final summaries = BalanceCalculator.build(
                incomes: incomeSnapshot.data ?? [],
                expenses: expenseSnapshot.data ?? [],
              );

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: summaries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _BalanceSummaryCard(summary: summaries[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BalanceSummaryCard extends StatelessWidget {
  const _BalanceSummaryCard({required this.summary});

  final BalanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(summary.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, color: statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    summary.currency.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: summary.status, color: statusColor),
              ],
            ),
            const SizedBox(height: 20),
            _BalanceMetric(
              label: 'Total ingresos',
              value: _formatAmount(summary.currency, summary.totalIncomes),
            ),
            const SizedBox(height: 12),
            _BalanceMetric(
              label: 'Total gastos',
              value: _formatAmount(summary.currency, summary.totalExpenses),
            ),
            const Divider(height: 32),
            _BalanceMetric(
              label: 'Balance',
              value: _formatAmount(summary.currency, summary.balance),
              valueStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BalanceStatus status) {
    switch (status) {
      case BalanceStatus.surplus:
        return Colors.green;
      case BalanceStatus.deficit:
        return Colors.red;
      case BalanceStatus.neutral:
        return Colors.blueGrey;
    }
  }

  String _formatAmount(MoneyCurrency currency, double amount) {
    final sign = amount < 0 ? '-' : '';
    return '$sign${currency.symbol}${amount.abs().toStringAsFixed(2)}';
  }
}

class _BalanceMetric extends StatelessWidget {
  const _BalanceMetric({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style:
              valueStyle ??
              Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final BalanceStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
