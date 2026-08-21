import 'package:flutter/material.dart';

import '../../personal/data/repository/payment_account_repository.dart';
import '../../personal/domain/payment_account.dart';
import '../../shared/domain/money_currency.dart';
import '../data/repository/income_repository.dart';
import '../domain/income.dart';
import '../domain/income_category.dart';
import 'add_income_page.dart';

class IncomeDetailPage extends StatelessWidget {
  final IncomeRepository repository;
  final PaymentAccountRepository paymentAccountRepository;
  final Income income;

  const IncomeDetailPage({
    super.key,
    required this.repository,
    required this.paymentAccountRepository,
    required this.income,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(Income income) {
    return '${income.currency.symbol}${income.amount.toStringAsFixed(2)}';
  }

  IconData _getCategoryIcon(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Icons.card_giftcard;
      case IncomeCategory.sinpe:
        return Icons.payment;
      case IncomeCategory.transaction:
        return Icons.swap_horiz;
      case IncomeCategory.other:
        return Icons.help_outline;
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ingreso'),
        content: const Text('Seguro que deseas eliminar este ingreso?'),
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
      await repository.deleteIncome(income.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingreso eliminado')));

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
      appBar: AppBar(title: const Text('Detalle del ingreso')),
      body: SafeArea(
        child: StreamBuilder<List<PaymentAccount>>(
          stream: paymentAccountRepository.watchPaymentAccounts(),
          builder: (context, snapshot) {
            final accountsById = {
              for (final account in snapshot.data ?? []) account.id: account,
            };
            final account = income.paymentAccountId == null
                ? null
                : accountsById[income.paymentAccountId];

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
                                _getCategoryIcon(income.category),
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatAmount(income),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      income.category.label,
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
                          _buildDetailRow('Fecha', _formatDate(income.date)),
                          const SizedBox(height: 12),
                          _buildDetailRow('Cuenta', _accountLabel(account)),
                          const SizedBox(height: 12),
                          if (income.description.isNotEmpty)
                            _buildDetailRow('Descripcion', income.description),
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
                                    builder: (context) => AddIncomePage(
                                      repository: repository,
                                      paymentAccountRepository:
                                          paymentAccountRepository,
                                      income: income,
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

  String _accountLabel(PaymentAccount? account) {
    if (income.paymentAccountId == null) {
      return 'Sin cuenta asignada';
    }

    return account?.alias ?? 'Cuenta no encontrada';
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
}
