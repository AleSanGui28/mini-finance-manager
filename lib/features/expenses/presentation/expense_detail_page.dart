import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../shared/domain/money_currency.dart';
import '../data/repository/expense_repository.dart';
import '../domain/expense.dart';
import '../domain/expense_frequency.dart';
import '../domain/expense_type.dart';
import '../domain/fixed_expense_category.dart';
import 'add_expense_page.dart';

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({
    super.key,
    required this.expenseRepository,
    required this.paymentAccountRepository,
    required this.expense,
  });

  final ExpenseRepository expenseRepository;
  final PaymentAccountRepository paymentAccountRepository;
  final Expense expense;

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: const Text('Seguro que deseas eliminar este gasto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await expenseRepository.deleteExpense(expense.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gasto eliminado')));

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del gasto')),
      body: SafeArea(
        child: StreamBuilder<List<PaymentAccount>>(
          stream: paymentAccountRepository.watchPaymentAccounts(),
          builder: (context, snapshot) {
            final accountsById = {
              for (final account in snapshot.data ?? []) account.id: account,
            };
            final account = accountsById[expense.paymentAccountId];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getExpenseIcon(expense.type),
                                size: 40,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatAmount(expense),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      expense.type.label,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          _buildDetailRow('Fecha', _formatDate(expense.date)),
                          const SizedBox(height: 12),
                          _buildDetailRow('Cuenta', _accountLabel(account)),
                          if ((expense.description ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Descripcion',
                              expense.description!,
                            ),
                          ],
                          if (expense.type == ExpenseType.fixed) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Categoria fija',
                              expense.fixedCategory?.label ?? 'Sin categoria',
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Frecuencia',
                              expense.frequency?.label ?? 'Sin frecuencia',
                            ),
                            if ((expense.customFrequencyDescription ?? '')
                                .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                'Descripcion de frecuencia',
                                expense.customFrequencyDescription!,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (context) => AddExpensePage(
                                      expenseRepository: expenseRepository,
                                      paymentAccountRepository:
                                          paymentAccountRepository,
                                      expense: expense,
                                    ),
                                  ),
                                );

                            if (updated == true && context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _handleDelete(context),
                          icon: const Icon(Icons.delete),
                          label: const Text('Eliminar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  String _accountLabel(PaymentAccount? account) {
    return account?.alias ?? 'Cuenta no encontrada';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(Expense expense) {
    return '${expense.currency.symbol}${expense.amount.toStringAsFixed(2)}';
  }

  IconData _getExpenseIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.fixed:
        return Icons.event_repeat;
      case ExpenseType.sporadic:
        return Icons.shopping_bag_outlined;
    }
  }
}
