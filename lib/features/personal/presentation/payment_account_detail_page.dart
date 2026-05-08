import 'package:flutter/material.dart';

import '../data/repository/payment_account_repository.dart';
import '../domain/payment_account.dart';
import '../domain/payment_account_type.dart';
import 'add_payment_account_page.dart';

class PaymentAccountDetailPage extends StatelessWidget {
  const PaymentAccountDetailPage({
    super.key,
    required this.repository,
    required this.paymentAccount,
  });

  final PaymentAccountRepository repository;
  final PaymentAccount paymentAccount;

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('Seguro que deseas eliminar esta cuenta de pago?'),
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
      await repository.deletePaymentAccount(paymentAccount.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cuenta de pago eliminada')));

      Navigator.of(context).pop(true);
    } on PaymentAccountDeleteBlockedException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
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
      appBar: AppBar(title: const Text('Detalle de cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            _getAccountIcon(paymentAccount.type),
                            size: 40,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  paymentAccount.alias,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  paymentAccount.type.label,
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
                      _buildDetailRow('Banco/Entidad', paymentAccount.bankName),
                      const SizedBox(height: 12),
                      _buildDetailRow('Alias', paymentAccount.alias),
                      const SizedBox(height: 12),
                      _buildDetailRow('Tipo', paymentAccount.type.label),
                      if (paymentAccount.cardLastDigits != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Ultimos 4 digitos',
                          '**** ${paymentAccount.cardLastDigits}',
                        ),
                      ],
                      if (paymentAccount.iban != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'IBAN',
                          _maskedIban(paymentAccount.iban!),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Creada',
                        _formatDate(paymentAccount.createdAt),
                      ),
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
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => AddPaymentAccountPage(
                              repository: repository,
                              paymentAccount: paymentAccount,
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

  IconData _getAccountIcon(PaymentAccountType type) {
    switch (type) {
      case PaymentAccountType.bankAccount:
        return Icons.account_balance;
      case PaymentAccountType.debitCard:
        return Icons.credit_card;
      case PaymentAccountType.creditCard:
        return Icons.credit_card;
      case PaymentAccountType.cash:
        return Icons.payments;
      case PaymentAccountType.other:
        return Icons.payment;
    }
  }

  String _maskedIban(String iban) {
    if (iban.length <= 4) {
      return iban;
    }

    return '${''.padLeft(iban.length - 4, '*')}${iban.substring(iban.length - 4)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
