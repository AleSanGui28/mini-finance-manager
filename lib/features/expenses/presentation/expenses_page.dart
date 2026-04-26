import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../data/repository/expense_repository.dart';
import '../domain/expense.dart';
import '../domain/expense_frequency.dart';
import '../domain/expense_type.dart';
import '../domain/fixed_expense_category.dart';
import 'add_expense_page.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({
    super.key,
    required this.expenseRepository,
    required this.paymentAccountRepository,
  });

  final ExpenseRepository expenseRepository;
  final PaymentAccountRepository paymentAccountRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos'), elevation: 0),
      body: StreamBuilder<List<Expense>>(
        stream: expenseRepository.watchExpenses(),
        builder: (context, expenseSnapshot) {
          if (expenseSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseSnapshot.hasError) {
            return Center(child: Text('Error: ${expenseSnapshot.error}'));
          }

          final expenses = expenseSnapshot.data ?? [];
          final totalAmount = expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          return StreamBuilder<List<PaymentAccount>>(
            stream: paymentAccountRepository.watchPaymentAccounts(),
            builder: (context, accountSnapshot) {
              final accounts = accountSnapshot.data ?? [];
              final accountsById = {
                for (final account in accounts) account.id: account,
              };

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total de gastos',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'CRC ${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (expenses.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay gastos registrados',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          final account =
                              accountsById[expense.paymentAccountId];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 0,
                            ),
                            child: ListTile(
                              leading: Icon(
                                expense.type == ExpenseType.fixed
                                    ? Icons.event_repeat
                                    : Icons.shopping_bag_outlined,
                                color: Colors.red,
                              ),
                              title: Text(
                                'CRC ${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_buildSubtitle(expense, account)),
                                  if ((expense.description ?? '').isNotEmpty)
                                    Text(
                                      expense.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text(_formatDate(expense.date)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddExpensePage(
                expenseRepository: expenseRepository,
                paymentAccountRepository: paymentAccountRepository,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar gasto'),
      ),
    );
  }

  String _buildSubtitle(Expense expense, PaymentAccount? account) {
    final accountLabel = account?.alias ?? 'Cuenta no encontrada';

    if (expense.type == ExpenseType.sporadic) {
      return '${expense.type.label} - $accountLabel';
    }

    final categoryLabel = expense.fixedCategory?.label ?? 'Sin categoria';
    final frequencyLabel = expense.frequency?.label ?? 'Sin frecuencia';
    return '${expense.type.label} - $categoryLabel - '
        '$frequencyLabel - $accountLabel';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
